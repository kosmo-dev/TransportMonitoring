//
//  MainView.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI

struct MainView: View {
    @State var currentSpeed: Float = 0
    @State var sliderValue: CGFloat

    var body: some View {
        GeometryReader { geometry in

            VStack {
                ZStack {
                    Rectangle()
                        .modifier(ForegroundColor(color: .gray))
//                    MapView()
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Spacer()
                            MapButton(imageSystemName: "plus", imageSize: 23, imageWeight: .bold) {}
                            MapButton(imageSystemName: "minus", imageSize: 23, imageWeight: .bold) {}
                            Spacer()
                            MapButton(imageSystemName: "eye", imageSize: 17, imageWeight: .regular) {}
                        }
                    }
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 16, trailing: 16))
                }
                .ignoresSafeArea()
                .frame(height: geometry.size.height * 3/4)
                ZStack {
                    Rectangle()
                        .modifier(ForegroundColor(color: .white.opacity(0.95)))
                    VStack(spacing: 16, content: {
                            HStack {
                                Text("Бензовоз")
                                Spacer()
                            }
                            HStack {
                                Image(systemName: "calendar")
                                Text("16.08.2023 - 16.08.2023")
                                    .font(.system(size: 12))
                                    .lineLimit(0)
                                Spacer()
                                Image(systemName: "map")
                                Text("10 км")
                                    .font(.system(size: 12))
                                Spacer()
                                Image(systemName: "speedometer")
                                Text("До 98 км/ч")
                                    .font(.system(size: 12))
                            }
                            CustomSlider(sliderValue: $sliderValue)
                                .frame(minHeight: 30, idealHeight: 50, maxHeight: 60)
                            HStack {
                                Button(action: {}, label: {
                                    Text("1x")
                                        .font(.system(size: 16, weight: .semibold))
                                })
                                Spacer()
                                Button(action: {}, label: {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 36))
                                        .modifier(ForegroundColor(color: .blue))
                                })
                                Spacer()
                                Button(action: {}, label: {
                                    Image(systemName: "info.circle")
                                        .modifier(ForegroundColor(color: .blue))
                                })
                            }
                        })
                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 20, trailing: 16))
                    }
                    .ignoresSafeArea()
            }
        }
    }
}

#Preview {
    MainView(sliderValue: 0)
}
