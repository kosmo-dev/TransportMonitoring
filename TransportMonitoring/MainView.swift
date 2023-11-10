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
            VStack(spacing: 0, content: {
                ZStack {
                    Rectangle()
                        .modifier(ForegroundColor(color: .gray))
//                    MapView()
                    HStack {
                        Spacer()
                        VStack {
                            Spacer()
                            Spacer()
                            MapButton(imageSystemName: "plus", imageSize: 23, imageWeight: .bold, imageColor: .spImagePurple) {}
                            MapButton(imageSystemName: "minus", imageSize: 23, imageWeight: .bold, imageColor: .spImagePurple) {}
                            Spacer()
                            MapButton(imageSystemName: "eye", imageSize: 17, imageWeight: .regular, imageColor: .spImageGray) {}
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
                            CustomSlider(sliderValue: $sliderValue)
                                .frame(minHeight: 30, idealHeight: 50, maxHeight: 60)
                            HStack {
                                Button(action: {}, label: {
                                    Text("1x")
                                        .font(.system(size: 16, weight: .semibold))
                                        .modifier(ForegroundColor(color: .spBlue))
                                })
                                Spacer()
                                Button(action: {}, label: {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 36))
                                        .modifier(ForegroundColor(color: .spBlue))
                                })
                                Spacer()
                                Button(action: {}, label: {
                                    Image(systemName: "info.circle")
                                        .modifier(ForegroundColor(color: .spBlue))
                                })
                            }
                        })
                    .padding(EdgeInsets(top: 0, leading: 16, bottom: 20, trailing: 16))
                    }
                    .ignoresSafeArea()
            })
        }
    }
}

#Preview {
    MainView(sliderValue: 0)
}
