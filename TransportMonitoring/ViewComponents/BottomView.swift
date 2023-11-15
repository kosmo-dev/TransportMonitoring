//
//  BottomView.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 14.11.2023.
//

import SwiftUI

struct BottomView: View {
    @EnvironmentObject var store: MainStore

    var body: some View {
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
                        .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
                    Spacer()
                }
                HStack {
                    Image(systemName: "calendar")
                        .modifier(ForegroundColor(color: .spImageGray))
                    Text("\(store.state.routeDays)")
                        .font(.system(size: 12))
                        .modifier(ForegroundColor(color: .spLabelBlack))
                        .lineLimit(0)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Image("distance")
                        .modifier(ForegroundColor(color: .spImageGray))
                    Text("\(store.state.distance) км")
                        .font(.system(size: 12))
                        .modifier(ForegroundColor(color: .spLabelBlack))
                    Spacer()
                    Image(systemName: "speedometer")
                        .modifier(ForegroundColor(color: .spImageGray))
                    Text("До \(store.state.maxSpeed) км/ч")
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
                            .font(.system(size: 20, weight: .semibold))
                            .modifier(ForegroundColor(color: .spBlue))
                    })
                    .frame(width: 30)
                    .padding()
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
                            .font(.system(size: 20, weight: .semibold))
                            .modifier(ForegroundColor(color: .spBlue))
                    })
                    .frame(width: 30)
                    .padding()
                }
            })
            .padding(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))
        }
    }
}

#Preview {
    BottomView().environmentObject(MainStore(initialState: MainState()))
}
