//
//  State.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 11.11.2023.
//

import Foundation
import Combine

struct MainState {
    var sliderValue: CGFloat = 0
    var playButtonIsOn = false
    var forwardModifier: ForwardModifier = .x1
    var showMapDescription = false
    var showLoadingIndicator = false

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
            state.showLoadingIndicator = show
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
}
