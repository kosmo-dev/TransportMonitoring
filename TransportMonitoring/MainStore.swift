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
    var showSplashScreen = true
    var polyline: PolylineIdentifiable = PolylineIdentifiable(id: UUID(), polyline: GMSPolyline())
    var zoom: Float = 12
    var route: [Track] = []
    var markerLocation = CLLocationCoordinate2D()
    var startRouteAnimation = false
    var stopRouteAnimation = false
    var trackCounter = 0
    var currentVelocity = 0
    var followTrackIsOn = false
    var routeDays: String = ""
    var distance: Int = 0
    var maxSpeed: Int = 0
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
        case showSplashScreen(Bool)
        case setRouteParameters(polyline: GMSPolyline, route: [Track], distance: Double, maxSpeed: Double)
        case makeRequest
        case zoomInTapped
        case zoomOutTapped
        case followButtonTapped
        case calculateSliderValue(Int)
        case setCurrentVelocity(Int)
        case routeAnimationStoppedDelegate
        case deactivateFollowTrack
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
            if state.startRouteAnimation == false {
                state.startRouteAnimation = true
                state.stopRouteAnimation = false
            } else {
                state.startRouteAnimation = false
                state.stopRouteAnimation = true
            }
            return nil

        case .forwardButtonTapped:
            state.forwardModifier = forwardModifierTapped(state.forwardModifier)
            return nil

        case .mapDescriptionTapped:
            state.showMapDescription.toggle()
            return nil

        case let .setSliderValue(value):
            guard !state.route.isEmpty else { return nil }
            state.sliderValue = value
            var counter = Int(value / CGFloat(100) * CGFloat(state.route.count))
            if counter > (state.route.count - 1) {
                counter = state.route.count - 1
            }
            let location = state.route[counter].location
            let clLocation = CLLocationCoordinate2D(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude)
            let velocity = state.route[counter].velocity
            state.markerLocation = clLocation
            state.currentVelocity = Int(velocity)
            state.trackCounter = counter
            return nil

        case let .showSplashScreen(show):
            state.showSplashScreen = show
            return nil

        case .followButtonTapped:
            if !state.followTrackIsOn {
                state.zoom = state.zoom + 1.5
            }
            state.followTrackIsOn.toggle()
            return nil

        case let .setRouteParameters(polyline: polyline, route: route, distance: distance, maxSpeed: maxSpeed):
            state.polyline = PolylineIdentifiable(id: UUID(), polyline: polyline)
            state.route = route
            state.distance = Int(distance)
            state.maxSpeed = Int(maxSpeed)
            state.routeDays = calculateRouteDays(route: route)
            return Just(())
                .map { Action.showSplashScreen(false) }
                .eraseToAnyPublisher()

        case let .calculateSliderValue(counter):
            state.sliderValue = CGFloat(counter) / CGFloat(state.route.count) * 100
            state.trackCounter = counter
            return nil

        case let .setCurrentVelocity(velocity):
            state.currentVelocity = velocity
            return nil

        case .makeRequest:
            return client.send(request: RouteRequest())
                .map { [weak self] data in
                    guard let self else { return ([Location]()) }
                    var locations: [[RouteElement]] = []
                    do {
                        locations = try JSONDecoder().decode([[RouteElement]].self, from: data)
                    } catch {
                        print("error in decoding")
                    }
                    let coordinates = coordinatesDecoder(locations: locations)
                    return coordinates
                }
                .receive(on: DispatchQueue.main)
                .map { coordinates in
                    let calculation = self.physicalCalculation(coordinates)
                    let polyline = GMSPolyline(path: calculation.path)
                    let colors = self.polylineColorizer(track: calculation.track)
                    polyline.spans = colors
                    polyline.strokeWidth = 1
                    return (polyline, calculation.track, calculation.distance, calculation.maxVelocity)
                }
                .map({ (polyline, route, distance, maxVelocity) in
                    Action.setRouteParameters(polyline: polyline, route: route, distance: distance, maxSpeed: maxVelocity)
                })
                .eraseToAnyPublisher()

        case .zoomInTapped:
            state.zoom += 1
            return nil

        case .zoomOutTapped:
            state.zoom -= 1
            return nil
            
        case .routeAnimationStoppedDelegate:
            state.stopRouteAnimation = false
            return nil

        case .deactivateFollowTrack:
            state.followTrackIsOn = false
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

    private func physicalCalculation(_ coordinates: [Location]) -> (track: [Track], path: GMSMutablePath, distance: Double, maxVelocity: Double) {
        var track: [Track] = []
        var previousVelocity: Double = 0
        var previous: Location? = nil
        var distance: Double = 0
        let path = GMSMutablePath()
        var maxVelocity: Double = 0

        for coordinate in coordinates {
            if let _previous = previous {
                let distanceBetween2 = GeometryService.haversine(lat1: _previous.coordinates.latitude, lon1: _previous.coordinates.longitude, lat2: coordinate.coordinates.latitude, lon2: coordinate.coordinates.longitude)

                let seconds = coordinate.timestamp.timeIntervalSince(_previous.timestamp)
                let meters = distanceBetween2 * 1000
                let velocity = meters / seconds * 3.6
                let acceleration = (velocity / 3.6 - previousVelocity / 3.6) / seconds

                if acceleration < 5.5 && acceleration > -5.5 && velocity < 250 {
                    if velocity > maxVelocity {
                        maxVelocity = velocity
                    }
                    track.append(Track(location: Location(timestamp: coordinate.timestamp, coordinates: CLLocationCoordinate2D(latitude: coordinate.coordinates.latitude, longitude: coordinate.coordinates.longitude)), meters: meters, velocity: velocity, acceleration: acceleration))
                    distance += distanceBetween2
                    path.add(CLLocationCoordinate2D(latitude: coordinate.coordinates.latitude, longitude: coordinate.coordinates.longitude))
                }
                previousVelocity = velocity
            }
            previous = Location(timestamp: coordinate.timestamp, coordinates: CLLocationCoordinate2D(latitude: coordinate.coordinates.latitude, longitude: coordinate.coordinates.longitude))
        }

        return (track: track, path: path, distance: distance, maxVelocity: maxVelocity)
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

    private func calculateRouteDays(route: [Track]) -> String {
        let calendar = Calendar.current
        let firstDay = route.first?.location.timestamp ?? Date()
        let lastDay = route.last?.location.timestamp ?? Date()
        let firstDayComponents = calendar.dateComponents([.day, .month, .year], from: firstDay)
        let lastDayComponents = calendar.dateComponents([.day, .month, .year], from: lastDay)
        return "\(firstDayComponents.day ?? 01).\(firstDayComponents.month ?? 01).\(firstDayComponents.year ?? 1970) - \(lastDayComponents.day ?? 01).\( lastDayComponents.month ?? 01).\(lastDayComponents.year ?? 1970)"
    }
}
