//
//  MapButton.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI

struct MapButton: View {
    let imageSystemName: String
    let imageSize: CGFloat
    let imageWeight: Font.Weight
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 45, height: 45)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                    .modifier(ForegroundColor(color: .white))
                Image(systemName: imageSystemName)
                    .font(.system(size: imageSize, weight: imageWeight))
                    .padding()
                    .modifier(ForegroundColor(color: .gray))
            }
        })
    }
}

#Preview {
    MapButton(imageSystemName: "plus", imageSize: 23, imageWeight: .bold) {
        print("Button tapped")
    }
}
