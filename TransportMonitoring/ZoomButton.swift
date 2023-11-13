//
//  ZoomButton.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI

struct ZoomButton: View {
    let imageSystemName: String
    let imageSize: CGFloat
    let imageWeight: Font.Weight
    let imageColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action, label: {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 45, height: 45)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(lineWidth: 1)
                            .modifier(ForegroundColor(color: .spBorderPurple))
                    )
                    .modifier(ForegroundColor(color: .white))
                Image(systemName: imageSystemName)
                    .font(.system(size: imageSize, weight: imageWeight))
                    .padding()
                    .modifier(ForegroundColor(color: imageColor))
            }
        })
    }
}

#Preview {
    ZoomButton(imageSystemName: "plus", imageSize: 23, imageWeight: .bold, imageColor: .spImageGray) {
        print("Button tapped")
    }
}
