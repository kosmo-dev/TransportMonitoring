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
                    Rectangle()
                        .frame(height: 0.5)
                        .modifier(ForegroundColor(color: .spBorderPurple))
                    ZStack {
                        VisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
                        VStack(spacing: 16, content: {
                            HStack {
                                Text("Бензовоз")
                                    .font(.system(size: 20, weight: .semibold))
                                    .modifier(ForegroundColor(color: .spLabelBlack))
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "calendar")
                                    .modifier(ForegroundColor(color: .spImageGray))
                                Text("16.08.2023 - 16.08.2023")
                                    .font(.system(size: 12))
                                    .modifier(ForegroundColor(color: .spLabelBlack))
                                    .lineLimit(0)
                                Spacer()
                                Image(systemName: "map")
                                    .modifier(ForegroundColor(color: .spImageGray))
                                Text("10 км")
                                    .font(.system(size: 12))
                                    .modifier(ForegroundColor(color: .spLabelBlack))
                                Spacer()
                                Image(systemName: "speedometer")
                                    .modifier(ForegroundColor(color: .spImageGray))
                                Text("До 98 км/ч")
                                    .font(.system(size: 12))
                                    .modifier(ForegroundColor(color: .spLabelBlack))
                            }
                            CustomSlider(sliderValue:
                                            Binding(get: { store.state.sliderValue },
                                                    set: { store.send(.setSliderValue($0)) }
                                                   ), 
                                         velocity:
                                            Binding(get: { store.state.currentVelocity },
                                                    set: { store.send(.setCurrentVelocity($0)) }
                                                   )
                            )
                            .frame(minHeight: 30, idealHeight: 50, maxHeight: 60)
                            HStack {
                                Button(action: {
                                    store.send(.forwardButtonTapped)
                                }, label: {
                                    Text("\(Int(store.state.forwardModifier.rawValue))x")
                                        .font(.system(size: 16, weight: .semibold))
                                        .modifier(ForegroundColor(color: .spBlue))
                                })
                                .frame(width: 36)
                                Spacer()
                                Button(action: {
                                    store.send(.playButtonTapped)
                                }, label: {
                                    Image(systemName: store.state.playButtonIsOn ? "pause.fill" : "play.fill")
                                        .font(.system(size: 36))
                                        .modifier(ForegroundColor(color: .spBlue))
                                })
                                .frame(height: 40)
                                Spacer()
                                Button(action: {
                                    store.send(.mapDescriptionTapped)
                                }, label: {
                                    Image(systemName: store.state.showMapDescription ? "info.circle.fill" : "info.circle")
                                        .modifier(ForegroundColor(color: .spBlue))
                                })
                                .frame(width: 44)
                            }
                        })
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))
                    }
                    .ignoresSafeArea()
                })
                if store.state.showMapDescription {
                    MapDescriptionView(viewIsAppeared:
                                        Binding(get: { store.state.showMapDescription },
                                                set: { _ in store.send(.mapDescriptionTapped) })
                    )
                }
                if store.state.showLoadingIndicator {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .modifier(ForegroundColor(color: .white))
                        ProgressView() {
                            Text("Loading")
                        }
                    }
                    .frame(width: 100, height: 100)
                }
            }
        }
        .onAppear(perform: {
            store.send(.showLoadingIndicator(true))
            store.send(.makeRequest)
        })
    }
}

#Preview {
    return MainView().environmentObject(MainStore(initialState: MainState(playButtonIsOn: false)))
}
