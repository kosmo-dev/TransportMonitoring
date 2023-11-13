//
//  CustomSlider.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI

struct CustomSlider: View {
    @Binding var sliderValue: CGFloat
    @Binding var velocity: Int
    var thumbSize: CGFloat = 20

    @State private var lastOffset: CGFloat = 0
    @State private var geometrySize: CGSize = .zero

    private var xOffset: CGFloat {
        guard geometrySize != CGSize.zero else { return 0 }
        return sliderValue.map(from: 0...100, to: 0...(geometrySize.width - self.thumbSize - self.sliderPadding * 2))
    }

    var sliderPadding: CGFloat = 16

    var body: some View {
        GeometryReader { geometry in
            VStack {
                HStack {
                    Text("\(velocity)км/ч")
                        .offset(x: xOffset)
                        .modifier(ForegroundColor(color: .spGray2))
                    Spacer()
                }
                ZStack {
                    HStack(spacing: -2, content: {
                        Circle()
                            .frame(height: 6)
                            .modifier(ForegroundColor(color: .spBlue))
                        HStack(spacing: 0, content: {
                            Rectangle()
                                .frame(width: $sliderValue.wrappedValue.map(from: 0...100, to: 0...(geometry.size.width - self.thumbSize - self.sliderPadding * 2)), height: 3)
                                .modifier(ForegroundColor(color: .spBlue))
                            Rectangle()
                                .frame(height: 3)
                                .modifier(ForegroundColor(color: .spGray))
                        })
                        Circle()
                            .frame(height: 6)
                            .modifier(ForegroundColor(color: .spGray))
                    })

                    HStack {

                        Circle()
                            .frame(height: self.thumbSize)
                            .modifier(ForegroundColor(color: .spBlue))
                            .overlay(
                                Circle()
                                    .stroke(lineWidth: 2)
                                    .modifier(ForegroundColor(color: .white))
                            )
                            .offset(x: xOffset)
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        if abs(value.translation.width) < 0.1 {
                                            self.lastOffset = self.xOffset
                                        }
                                        let position = max(0, min( self.lastOffset + value.translation.width, geometry.size.width - self.thumbSize - self.sliderPadding * 2 ))
                                        self.sliderValue = position.map(from: (0...geometry.size.width - self.thumbSize  - self.sliderPadding * 2), to: 1...100)
                                    }
                            )

                        Spacer()
                    }
                }
                .padding(EdgeInsets(top: 0, leading: sliderPadding, bottom: 0, trailing: sliderPadding))
            }
            .onAppear(perform: {
                geometrySize = geometry.size
            })
        }
    }
}

#Preview {
    CustomSlider(sliderValue: .constant(0), velocity: .constant(65))
}

extension CGFloat {
    func map(from: ClosedRange<CGFloat>, to: ClosedRange<CGFloat>) -> CGFloat {
        let result = ((self - from.lowerBound) / (from.upperBound - from.lowerBound)) * (to.upperBound - to.lowerBound) + to.lowerBound
        return result
    }
}
