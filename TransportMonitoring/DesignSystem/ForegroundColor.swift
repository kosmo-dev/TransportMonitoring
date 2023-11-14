//
//  ForegroundColor.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI

struct ForegroundColor: ViewModifier {
    let color: Color

    func body(content: Content) -> some View {
        if #available(iOS 15, *) {
            content.foregroundStyle(color)
        } else {
            content.foregroundColor(color)
        }
    }
}
