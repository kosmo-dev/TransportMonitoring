//
//  MapViewController.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import UIKit
import GoogleMaps

final class MapViewController: UIViewController {

    var map: GMSMapView?

    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 55.694680, longitude: 37.556346, zoom: 15)
        map = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        if let map {
            self.view.addSubview(map)
        }
    }

    
}
