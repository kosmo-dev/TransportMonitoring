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

    @Binding var trackCounter: Int
    @Binding var store: MainStore

    typealias UIViewControllerType = MapViewController

    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController(coordinator: context.coordinator)
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        print("updateUIViewController called")
        uiViewController.setPolyline(polyline: polyline)
        uiViewController.zoomMapWithAnimation(zoom: zoom)
        uiViewController.moveMapToLocationWithAnimation(cameraUpdate)
        if startRouteAnimation {
            print("startRouteAnimation \(startRouteAnimation)")
            uiViewController.startRoute(route: route)
        }

        if stopAnimation {
            uiViewController.stopAnimation()
        }
        uiViewController.setAnimationSpeed(forwardModifier)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(trackCounter: trackCounter, store: store)
    }

    class Coordinator {
        var trackCounter: Int
        var store: MainStore

        init(trackCounter: Int, store: MainStore) {
            self.trackCounter = trackCounter
            self.store = store
        }

        func updateTrackCounter(_ counter: Int) {
            print("coordinator tracker counter \(counter)")
            store.send(.calculateSliderValue(counter))
            let velocity = store.state.route[counter].velocity
            store.send(.setCurrentVelocity(Int(velocity)))
        }
    }
}

