//
//  MainView.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var store: MainStore

    var body: some View {
        Group {
            if store.state.showSplashScreen {
                SplashScreen()
                    .onAppear(perform: {
                        store.send(.makeRequest)
                    })
            } else {
                GeometryReader { geometry in
                    ZStack {
                        VStack(spacing: 0, content: {
                            ZStack {
                                MapView(
                                    polyline: Binding(get: { store.state.polyline }, set: { _ in }),
                                    zoom: Binding(get: { store.state.zoom}, set: { _ in }),
                                    markerLocation: Binding(get: { store.state.markerLocation }, set: { _ in }),
                                    route: Binding(get: { store.state.route }, set: { _ in }),
                                    startRouteAnimation: Binding(get: { store.state.startRouteAnimation }, set: { _ in }),
                                    stopAnimation: Binding(get: { store.state.stopRouteAnimation }, set: { _ in }),
                                    forwardModifier: Binding(get: { store.state.forwardModifier }, set: { _ in }),
                                    store: Binding(get: { store }, set: { _ in })
                                )
                                HStack {
                                    Spacer()
                                    VStack {
                                        Spacer()
                                        Spacer()
                                        ZoomButton(imageSystemName: "plus") {
                                            store.send(.zoomInTapped)
                                        }
                                        ZoomButton(imageSystemName: "minus") {
                                            store.send(.zoomOutTapped)
                                        }
                                        Spacer()
                                        FollowButton(buttonIsOn: Binding(
                                            get: { store.state.followTrackIsOn },
                                            set: { _ in })) {
                                                store.send(.followButtonTapped)
                                            }
                                    }
                                }
                                .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 16))
                            }
                            .ignoresSafeArea()
                            .frame(height: geometry.size.height * 3/4)
                            BottomView().environmentObject(store)
                                .ignoresSafeArea()
                        })
                        if store.state.showMapDescription {
                            VStack {
                                Spacer()
                                MapDescriptionView(viewIsAppeared:
                                                    Binding(get: { store.state.showMapDescription },
                                                            set: { _ in store.send(.mapDescriptionTapped) })
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    return MainView().environmentObject(MainStore(initialState: MainState(playButtonIsOn: false)))
}
