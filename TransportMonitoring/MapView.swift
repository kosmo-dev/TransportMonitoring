//
//  MapView.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI
import GoogleMaps

struct MapView: UIViewControllerRepresentable {
    @Binding var polyline: PolylineIdentifiable
    @Binding var zoom: Float
    @Binding var cameraUpdate: CLLocationCoordinate2D
    @Binding var route: [Track]
    @Binding var startRouteAnimation: Bool
    @Binding var stopAnimation: Bool
    @Binding var forwardModifier: ForwardModifier

    typealias UIViewControllerType = MapViewController

    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        uiViewController.setPolyline(polyline: polyline)
        uiViewController.zoomMapWithAnimation(zoom: zoom)
        uiViewController.moveMapToLocationWithAnimation(cameraUpdate)
        print("startRouteAnimation \(startRouteAnimation)")
        if startRouteAnimation {
            uiViewController.startRoute(route: route)
        }

        if stopAnimation {
            uiViewController.stopAnimation()
        }
        uiViewController.setAnimationSpeed(forwardModifier)
    }
}

