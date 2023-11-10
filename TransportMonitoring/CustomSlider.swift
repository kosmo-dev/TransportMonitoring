//
//  CustomSlider.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI

struct CustomSlider: View {
    @Binding var sliderValue: CGFloat

    @State private var xOffset: CGFloat = 0
    @State private var lastOffset: CGFloat = 0
    var thumbSize: CGFloat = 20

    var leadingOffset: CGFloat = 5
    var trailingOffset: CGFloat = 5

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack(spacing: -2, content: {
                    Circle()
                        .frame(height: 6)
                        .modifier(ForegroundColor(color: .blue))
                    HStack(spacing: 0, content: {
                        Rectangle()
                            .frame(width: $sliderValue.wrappedValue.map(from: 0...100, to: 0...(geometry.size.width - self.thumbSize)), height: 3)
                            .modifier(ForegroundColor(color: .blue))
                        Rectangle()
                            .frame(height: 3)
                            .modifier(ForegroundColor(color: .gray))
                    })
                    Circle()
                        .frame(height: 6)
                        .modifier(ForegroundColor(color: .gray))
                })

                HStack {

                    Circle()
                        .frame(height: self.thumbSize)
                        .modifier(ForegroundColor(color: .blue))
                        .overlay(
                            Circle()
                                .stroke(lineWidth: 2)
                                .modifier(ForegroundColor(color: .black))
                        )
                        .offset(x: xOffset)
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    if abs(value.translation.width) < 0.1 {
                                        self.lastOffset = self.xOffset
                                    }
                                    let position = max(0, min( self.lastOffset + value.translation.width, geometry.size.width - self.thumbSize ))
                                    self.xOffset = position

                                    self.sliderValue = position.map(from: (0...geometry.size.width - thumbSize), to: 1...100)
                                }
                        )

                    Spacer()
                }
            }
        }
    }
}

#Preview {
    CustomSlider(sliderValue: .constant(0))
}

extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}
