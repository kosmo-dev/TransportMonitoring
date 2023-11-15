//
//  SplashScreen.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 15.11.2023.
//

import SwiftUI

struct SplashScreen: View {
    let fullText: String = "Transport Monitoring"
    let characterDelay: TimeInterval = 0.1

    @State private var displayedText = ""
    @State private var currentIndex = 0
    @State private var showProgressView = false

    var body: some View {
        VStack {
            Text(displayedText)
                .font(.system(size: 35, weight: .semibold))
                .font(.system(.title, design: .rounded))
                .onAppear {
                    let timer = Timer.scheduledTimer(withTimeInterval: characterDelay, repeats: true) { timer in
                        if currentIndex < fullText.count {
                            let index = fullText.index(fullText.startIndex, offsetBy: currentIndex)
                            displayedText += String(fullText[index])
                            currentIndex += 1
                        } else {
                            showProgressView = true
                            timer.invalidate()
                        }
                    }
                    timer.fire()
                }
            if showProgressView {
                ProgressView()
            }
        }
    }
}

#Preview {
    SplashScreen()
}
