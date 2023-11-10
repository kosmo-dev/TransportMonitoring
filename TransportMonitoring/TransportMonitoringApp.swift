//
//  TransportMonitoringApp.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI
import UIKit
import GoogleMaps

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        GMSServices.provideAPIKey("AIzaSyBfPs2l6_1xu-zIeiquRtgBzJ5Guff1Cvc")
        return true
    }
}

@main
struct TransportMonitoringApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
