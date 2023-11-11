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
    var polyline: GMSPolyline = GMSPolyline()

    enum ForwardModifier: Int {
        case x1 = 1
        case x4 = 4
        case x8 = 8
    }
}

final class MainStore: ObservableObject {
    @Published private(set) var state: MainState

    private var cancellables: Set<AnyCancellable> = []

    init(initialState: MainState) {
        self.state = initialState
    }

    enum Action {
        case playButtonTapped
        case forwardButtonTapped
        case mapDescriptionTapped
        case setSliderValue(CGFloat)
        case showLoadingIndicator(Bool)
        case setPolyline
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
            return nil
        case .forwardButtonTapped:
            state.forwardModifier = forwardModifierTapped(state.forwardModifier)
            return nil
        case .mapDescriptionTapped:
            state.showMapDescription.toggle()
            return nil
        case let .setSliderValue(value):
            state.sliderValue = value
            return nil
        case let .showLoadingIndicator(show):
//            state.showLoadingIndicator = show
            return nil
        case .setPolyline:
            state.polyline = makeMockPolyline()
            return nil
        }
    }

    private func forwardModifierTapped(_ forwardModifier: MainState.ForwardModifier) -> MainState.ForwardModifier {
        switch forwardModifier {
        case .x1:
            return .x4
        case .x4:
            return .x8
        case .x8:
            return .x1
        }
    }

    func makeMockPolyline() -> GMSPolyline {
        let path = GMSMutablePath()
        path.add(CLLocationCoordinate2D(latitude: 55.651365, longitude: 37.610225))
        path.add(CLLocationCoordinate2D(latitude: 55.6531333333333, longitude: 37.6128816666667))
        path.add(CLLocationCoordinate2D(latitude: 55.781505, longitude: 37.5999216666667))
        path.add(CLLocationCoordinate2D(latitude: 55.8070533333333, longitude: 37.5814233333333))
        path.add(CLLocationCoordinate2D(latitude: 55.7473433333333, longitude: 37.58251))
        path.add(CLLocationCoordinate2D(latitude: 55.8056216666667, longitude: 37.571535))
        path.add(CLLocationCoordinate2D(latitude: 55.8190983333333, longitude: 37.5746533333333))
        path.add(CLLocationCoordinate2D(latitude: 55.80008, longitude: 37.58368))
        path.add(CLLocationCoordinate2D(latitude: 55.78637, longitude: 37.5947966666667))
        return GMSPolyline(path: path)
    }
}
