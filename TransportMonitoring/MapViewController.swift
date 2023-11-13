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

    var currentPolylineID: UUID = UUID()
    var currentZoom: Float = 15
    var currentLocation = CLLocationCoordinate2D(latitude: 55.694680, longitude: 37.556346)
    var marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 55.694680, longitude: 37.556346))
    var animationStarted = false
    var stopAnimationCalled = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude, longitude: currentLocation.longitude, zoom: currentZoom)
        map = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        if let map {
            self.view.addSubview(map)
        }
        marker.map = map
    }

    func setPolyline(polyline: PolylineIdentifiable) {
        guard currentPolylineID != polyline.id else { return }
        polyline.polyline.map = map
        currentPolylineID = polyline.id
        print("polyline set")
    }


    func zoomMapWithAnimation(zoom: Float) {
        guard zoom != currentZoom else { return }
        map?.animate(toZoom: zoom)
        currentZoom = zoom
        print("zoom set")
    }

    func moveMapToLocationWithAnimation(_ location: CLLocationCoordinate2D) {
        guard currentLocation.latitude != location.latitude && currentLocation.longitude != location.longitude else { return }
        map?.animate(toLocation: location)
        currentLocation = location
        print("location set")
    }

    func setMarkerLocation(location: CLLocationCoordinate2D, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        CATransaction.setCompletionBlock {
            completion()
        }
        marker.layer.latitude = location.latitude
        marker.layer.longitude = location.longitude
        CATransaction.commit()
    }

    func stopAnimation() {
        stopAnimationCalled = true
    }

    func startRoute(route: [Track]) {
        guard !animationStarted else { return }
        print("start route")
        animationStarted = true
        if route.count > 20 {
            Task {
                var counter = 0
                while counter < 120 {
                    if stopAnimationCalled {
                        break
                    }
                    await withCheckedContinuation { continuation in
                        let coordinates = CLLocationCoordinate2D(latitude: route[counter].lastLocation.longitude, longitude: route[counter].lastLocation.latitude)
                        setMarkerLocation(location: coordinates) {
                            counter += 1
                            continuation.resume()
                        }
                    }
                }
                print("finish animation")
                animationStarted = false
                stopAnimationCalled = false
            }
        }
    }
}
