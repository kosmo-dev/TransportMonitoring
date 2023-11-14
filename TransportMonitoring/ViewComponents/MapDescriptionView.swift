//
//  MapDescriptionView.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI

struct MapDescriptionView: View {
    @Binding var viewIsAppeared: Bool

    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .systemMaterialLight))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.spBorderPurple, lineWidth: 1)
                )
            VStack(spacing: 8, content: {
                Text("Легенда")
                    .font(.system(size: 20, weight: .semibold))
                    .modifier(ForegroundColor(color: .spLabelBlack))
                VStack(alignment: .leading, content: {
                    Row(color: .spDarkBlue, minValue: 0, maxValue: 70)
                    Row(color: .spYellow, minValue: 70, maxValue: 90)
                    Row(color: .spRed, minValue: 90, maxValue: nil)
                })
                Rectangle()
                    .frame(height: 1)
                    .modifier(ForegroundColor(color: .spBorderPurple))
                Button(action: {
                    viewIsAppeared = false
                }, label: {
                    Text("Закрыть")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
                })
            })
        }
        .frame(height: 236)
        .padding()
        .offset(y: -20)
    }
}

#Preview {
    MapDescriptionView(viewIsAppeared: .constant(true))
}

struct Row: View {
    let color: Color
    let minValue: Int
    let maxValue: Int?

    var body: some View {
        HStack {
            Circle()
                .modifier(ForegroundColor(color: color))
                .overlay(
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                )
                .frame(height: 32)
            Text(" - ")
            if let maxValue {
                Text("от \(minValue) до \(maxValue) км/ч")
            } else {
                Text("более \(minValue) км/ч")
            }
        }
    }
}
