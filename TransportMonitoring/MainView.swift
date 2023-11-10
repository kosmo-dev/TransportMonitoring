//
//  MainView.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI

struct MainView: View {
    @State var currentSpeed: Float = 0

    var body: some View {
        VStack {
            Rectangle()
                .modifier(ForegroundColor(color: .gray))
//            MapView()
            ZStack {
                Rectangle()
                    .modifier(ForegroundColor(color: .white.opacity(0.95)))
                VStack {
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
                    Text("65 км/ч")
                    HStack(spacing: 0, content: {
                        Circle()
                            .frame(height: 6)
                            .modifier(ForegroundColor(color: .blue))
                        Rectangle()
                            .frame(height: 3)
                        Circle()
                            .frame(height: 6)
                        Circle()
                            .frame(height: 20)
                            .modifier(ForegroundColor(color: .blue))
                    })
                    HStack {
                        Button(action: {}, label: {
                            Text("1x")
                                .font(.system(size: 16, weight: .semibold))
                        })
                        Spacer()
                        Image(systemName: "play.fill")
                            .font(.system(size: 36))
                            .modifier(ForegroundColor(color: .blue))
                        Spacer()
                        Image(systemName: "info.circle")
                            .modifier(ForegroundColor(color: .blue))
                    }
                }
                .padding(EdgeInsets(top: 16, leading: 16, bottom: 4, trailing: 16))
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    MainView()
}
