//
//  MapView.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import SwiftUI
import GoogleMaps

struct MapView: UIViewControllerRepresentable {
    @Binding var polyline: GMSPolyline

    typealias UIViewControllerType = MapViewController

    func makeUIViewController(context: Context) -> MapViewController {
        return MapViewController()
    }
    
    func updateUIViewController(_ uiViewController: MapViewController, context: Context) {
        polyline.map = uiViewController.map
    }
}

