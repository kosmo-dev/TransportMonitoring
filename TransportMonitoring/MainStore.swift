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
    var markerLocation = CLLocationCoordinate2D()
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
            let location = state.coordinates[counter].location
            let clLocation = CLLocationCoordinate2D(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude)
            let velocity = state.coordinates[counter].velocity
            state.markerLocation = clLocation
            state.currentVelocity = Int(velocity)
            state.trackCounter = counter
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
            return client.send(request: RouteRequest())
                .receive(on: DispatchQueue.main)
                .map { [weak self] data in
                    guard let self else { return (GMSPolyline(), []) }
                    var locations: [[RouteElement]] = []
                    print(data)
                    do {
                        locations = try JSONDecoder().decode([[RouteElement]].self, from: data)
                    } catch {
                        print("error in decoding")
                    }
                    let coordinates = coordinatesDecoder(locations: locations)
                    let calculation = self.physicalCalculation(coordinates)
                    let polyline = GMSPolyline(path: calculation.path)
                    let colors = self.polylineColorizer(track: calculation.track)
                    polyline.spans = colors
                    polyline.strokeWidth = 2
                    return (polyline, calculation.track)
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

    private func coordinatesDecoder(locations: [[RouteElement]]) -> [Location] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

        var coordinates: [Location] = []

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
                        longitude = double
                    } else {
                        latitude = double
                    }
                case .string(let string):
                    counter = 0
                    if let decodedDate = dateFormatter.date(from: string) {
                        date = decodedDate
                    }
                }
            }
            coordinates.append(Location(timestamp: date, coordinates: CLLocationCoordinate2D(latitude: latitude, longitude: longitude)))
        }
        return coordinates
    }

    private func physicalCalculation(_ coordinates: [Location]) -> (track: [Track], path: GMSMutablePath, distance: Double) {
        var track: [Track] = []
        var previousVelocity: Double = 0
        var previous: Location? = nil
        var distance: Double = 0
        let path = GMSMutablePath()

        for coordinate in coordinates {
            if let _previous = previous {
                let distanceBetween2 = GeometryService.haversine(lat1: _previous.coordinates.latitude, lon1: _previous.coordinates.longitude, lat2: coordinate.coordinates.latitude, lon2: coordinate.coordinates.longitude)

                let seconds = coordinate.timestamp.timeIntervalSince(_previous.timestamp)
                let meters = distanceBetween2 * 1000
                let velocity = meters / seconds * 3.6
                let acceleration = (velocity / 3.6 - previousVelocity / 3.6) / seconds

                if acceleration < 5.5 && acceleration > -5.5 {
                    track.append(Track(location: Location(timestamp: coordinate.timestamp, coordinates: CLLocationCoordinate2D(latitude: coordinate.coordinates.latitude, longitude: coordinate.coordinates.longitude)), meters: meters, velocity: velocity, acceleration: acceleration))
                    distance += distanceBetween2
                    path.add(CLLocationCoordinate2D(latitude: coordinate.coordinates.latitude, longitude: coordinate.coordinates.longitude))
                }
                previousVelocity = velocity
            }
            previous = Location(timestamp: coordinate.timestamp, coordinates: CLLocationCoordinate2D(latitude: coordinate.coordinates.latitude, longitude: coordinate.coordinates.longitude))
        }

        return (track: track, path: path, distance: distance)
    }

    private func polylineColorizer(track: [Track]) -> [GMSStyleSpan] {
        let blueColor = GMSStrokeStyle.solidColor(.spDarkBlue)
        let yellowColor = GMSStrokeStyle.solidColor(.spYellow)
        let redColor = GMSStrokeStyle.solidColor(.spRed)

        var previousColor = blueColor
        var previousCounter = 0
        var colors: [GMSStyleSpan] = []

        for segment in track {
            switch segment.velocity {
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
        return colors
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
}
