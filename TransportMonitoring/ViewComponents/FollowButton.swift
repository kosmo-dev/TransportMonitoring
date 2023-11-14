//
//  FollowButton.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 14.11.2023.
//

import SwiftUI

struct FollowButton: View {
    @Binding var buttonIsOn: Bool

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
                    .modifier(ForegroundColor(color: buttonIsOn ? .spBlue : .white))
                Image(systemName: "eye")
                    .font(.system(size: 17, weight: .regular))
                    .padding()
                    .modifier(ForegroundColor(color: buttonIsOn ? .white : .spImageGray))
            }
        })
    }
}

#Preview {
    FollowButton(buttonIsOn: .constant(false)) {}
}
