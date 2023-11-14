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
    @Binding var markerLocation: CLLocationCoordinate2D
    @Binding var route: [Track]
    @Binding var startRouteAnimation: Bool
    @Binding var stopAnimation: Bool
    @Binding var forwardModifier: ForwardModifier

    @Binding var store: MainStore

    typealias UIViewControllerType = MapViewController

    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController(coordinator: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        uiViewController.setPolyline(polyline: polyline)
        uiViewController.zoomMapWithAnimation(zoom: zoom)
        if startRouteAnimation {
            uiViewController.startRoute(route: route)
        }
        if stopAnimation {
            uiViewController.stopAnimation()
        }
        uiViewController.setAnimationSpeed(forwardModifier)
        uiViewController.moveMarkerWithoutAnimation(to: markerLocation)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(store: store)
    }

    class Coordinator {
        var store: MainStore

        init(store: MainStore) {
            self.store = store
        }
    }
}

