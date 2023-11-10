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
                            Button(action: {}, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 45, height: 45)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 0.5)
                                        )
                                        .modifier(ForegroundColor(color: .white))
                                    Image(systemName: "plus")
                                        .font(.system(size: 23, weight: .bold))
                                        .padding()
                                        .modifier(ForegroundColor(color: .gray))
                                }
                            })
                            Button(action: {}, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 45, height: 45)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 0.5)
                                        )
                                        .modifier(ForegroundColor(color: .white))
                                    Image(systemName: "minus")
                                        .font(.system(size: 23, weight: .bold))
                                        .padding()
                                        .modifier(ForegroundColor(color: .gray))
                                }
                            })
                            Spacer()
                            Button(action: {}, label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 45, height: 45)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 0.5)
                                        )
                                        .modifier(ForegroundColor(color: .white))
                                    Image(systemName: "eye")
                                        .padding()
                                        .modifier(ForegroundColor(color: .gray))
                                }
                            })
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
