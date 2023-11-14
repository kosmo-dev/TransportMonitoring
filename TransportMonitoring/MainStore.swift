//
//  State.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 11.11.2023.
//

import Foundation
import Combine
import GoogleMaps

struct MainState {
    var sliderValue: CGFloat = 0
    var playButtonIsOn = false
    var forwardModifier: ForwardModifier = .x1
    var showMapDescription = false
    var showLoadingIndicator = false
    var polyline: PolylineIdentifiable = PolylineIdentifiable(id: UUID(), polyline: GMSPolyline())
    var zoom: Float = 15
    var coordinates: [Track] = []
    var route: [Track] = []
    var markerLocation = CLLocationCoordinate2D(latitude: 55.694680, longitude: 37.556346)
    var startRouteAnimation = false
    var stopRouteAnimation = false
    var trackCounter = 0
    var currentVelocity = 0
    var followTrackIsOn = false
}

final class MainStore: ObservableObject {
    @Published private(set) var state: MainState

    private var cancellables: Set<AnyCancellable> = []

    let client = NetworkClient()
    

    init(initialState: MainState) {
        self.state = initialState
    }

    enum Action {
        case playButtonTapped
        case forwardButtonTapped
        case mapDescriptionTapped
        case setSliderValue(CGFloat)
        case showLoadingIndicator(Bool)
        case setRoute(polyline: GMSPolyline, route: [Track])
        case makeRequest
        case zoomInTapped
        case zoomOutTapped
        case followButtonTapped
        case calculateSliderValue(Int)
        case setCurrentVelocity(Int)
    }

    func send(_ action: Action) {
        guard let effect = reducer(state: &state, action: action) else {
            return
        }

        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &cancellables)

    }

    private func reducer(state: inout MainState, action: Action) -> AnyPublisher<Action, Never>? {
        switch action {
        case .playButtonTapped:
            state.playButtonIsOn.toggle()
            state.markerLocation = CLLocationCoordinate2D(latitude: state.coordinates[2].lastLocation.longitude, longitude: state.coordinates[2].lastLocation.latitude)
            state.route = state.coordinates
            if state.startRouteAnimation == false {
                state.startRouteAnimation = true
                state.stopRouteAnimation = false
            } else {
                state.stopRouteAnimation = true
                state.startRouteAnimation = false
            }
            return nil
        case .forwardButtonTapped:
            state.forwardModifier = forwardModifierTapped(state.forwardModifier)
            return nil
        case .mapDescriptionTapped:
            state.showMapDescription.toggle()
            return nil
        case let .setSliderValue(value):
            state.sliderValue = value
            var counter = Int(value / CGFloat(100) * CGFloat(state.coordinates.count))
            if counter > (state.coordinates.count - 1) {
                counter = state.coordinates.count - 1
            }
            let location = state.coordinates[counter].lastLocation
            let clLocation = CLLocationCoordinate2D(latitude: location.longitude, longitude: location.latitude)
            let velocity = state.coordinates[counter].velocity
            state.markerLocation = clLocation
            state.currentVelocity = Int(velocity)
            return nil
        case let .showLoadingIndicator(show):
            state.showLoadingIndicator = show
            return nil
        case .followButtonTapped:
            state.zoom = 18
            state.followTrackIsOn.toggle()
            return nil
        case let .setRoute(polyline: polyline, route: route):
            state.polyline = PolylineIdentifiable(id: UUID(), polyline: polyline)
            state.coordinates = route
            return Just(())
                .map { Action.showLoadingIndicator(false) }
                .eraseToAnyPublisher()
        case let .calculateSliderValue(counter):
            state.sliderValue = CGFloat(counter) / CGFloat(state.route.count) * 100
            print("slider: \(state.sliderValue)")
            return nil
        case let .setCurrentVelocity(velocity):
            state.currentVelocity = velocity
            return nil
        case .makeRequest:
            return client.send([Location].self, request: RouteRequest())
                .receive(on: DispatchQueue.main)
                .map { data in
                    var locations: [[RouteElement]] = []
                    print(data)
                    do {
                        locations = try JSONDecoder().decode(Route.self, from: data)
                    } catch {
                        print("error in decoding")
                    }

                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

                    let path = GMSMutablePath()
                    var distance: Double = 0
                    var previous: Location? = nil
                    var route: [Track] = []
                    var colors: [GMSStyleSpan] = []

                    let blueColor = GMSStrokeStyle.solidColor(.spDarkBlue)
                    let yellowColor = GMSStrokeStyle.solidColor(.spYellow)
                    let redColor = GMSStrokeStyle.solidColor(.spRed)

                    let blueSpan = GMSStyleSpan(style: blueColor)
                    let yellowSpan = GMSStyleSpan(style: yellowColor)
                    let redSpan = GMSStyleSpan(style: redColor)

                    var previousColor = blueColor
                    var previousCounter = 0

                    for location in locations {

                        var latitude = CLLocationDegrees()
                        var longitude = CLLocationDegrees()
                        var date = Date()

                        var counter = 0
                        for element in location {
                            switch element {
                            case .double(let double):
                                counter += 1
                                if counter == 1 {
                                    latitude = double
                                } else {
                                    longitude = double
                                }
                            case .string(let string):
                                counter = 0
                                if let decodedDate = dateFormatter.date(from: string) {
                                    date = decodedDate
                                }
                            }
                        }
                        if let _previous = previous {
                            let distanceBetween2 = self.haversine(lat1: _previous.latitude, lon1: _previous.longitude, lat2: latitude, lon2: longitude)

                            let seconds = date.timeIntervalSince(_previous.timestamp)
                            let meters = distanceBetween2 * 1000
                            let velocity = meters / seconds * 3.6
                            let acceleration = meters / ( seconds * seconds )

                            if acceleration < 5.55 {
                                route.append(Track(lastLocation: Location(timestamp: date, latitude: latitude, longitude: longitude), meters: meters, velocity: velocity, acceleration: acceleration))
                                distance += distanceBetween2
                                path.add(CLLocationCoordinate2D(latitude: longitude, longitude: latitude))

                                switch velocity {
                                case 0...70:
                                    if previousColor == blueColor {
                                        previousCounter += 1
                                    } else {
                                        colors.append(GMSStyleSpan(style: previousColor, segments: Double(previousCounter)))
                                        previousColor = blueColor
                                        previousCounter = 1
                                    }
                                case 71...90:
                                    if previousColor == yellowColor {
                                        previousCounter += 1
                                    } else {
                                        colors.append(GMSStyleSpan(style: previousColor, segments: Double(previousCounter)))
                                        previousColor = yellowColor
                                        previousCounter = 1
                                    }
                                default:
                                    if previousColor == redColor {
                                        previousCounter += 1
                                    } else {
                                        colors.append(GMSStyleSpan(style: previousColor, segments: Double(previousCounter)))
                                        previousColor = redColor
                                        previousCounter = 1
                                    }
                                }
                            }
                        }
                        previous = Location(timestamp: date, latitude: latitude, longitude: longitude)
                    }
                    let polyline = GMSPolyline(path: path)
                    polyline.spans = colors
                    polyline.strokeWidth = 2
                    return (polyline, route)
                }
                .map({ (polyline, route) in
                    Action.setRoute(polyline: polyline, route: route)
                })
                .eraseToAnyPublisher()
        case .zoomInTapped:
            state.zoom += 1
            return nil
        case .zoomOutTapped:
            state.zoom -= 1
            return nil
        }
    }

    private func forwardModifierTapped(_ forwardModifier: ForwardModifier) -> ForwardModifier {
        switch forwardModifier {
        case .x1:
            return .x4
        case .x4:
            return .x8
        case .x8:
            return .x1
        }
    }

    private func haversine(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0  // Earth's radius in kilometers

        // Convert latitude and longitude from degrees to radians
        let lat1Rad = lat1 * .pi / 180.0
        let lon1Rad = lon1 * .pi / 180.0
        let lat2Rad = lat2 * .pi / 180.0
        let lon2Rad = lon2 * .pi / 180.0

        // Differences in coordinates
        let dlat = lat2Rad - lat1Rad
        let dlon = lon2Rad - lon1Rad

        // Haversine formula
        let a = sin(dlat / 2.0) * sin(dlat / 2.0) + cos(lat1Rad) * cos(lat2Rad) * sin(dlon / 2.0) * sin(dlon / 2.0)
        let c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))

        // Distance in kilometers
        let distance = R * c

        return distance
    }
}
