//
//  MapViewController.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import UIKit
import GoogleMaps

final class MapViewController: UIViewController {

    var coordinator: MapView.Coordinator

    var map: GMSMapView?

    var currentPolylineID: UUID = UUID()
    var currentZoom: Float = 15
    var currentLocation = CLLocationCoordinate2D(latitude: 55.755802, longitude: 37.617705)
    var marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 55.755802, longitude: 37.617705))
    var animationStarted = false
    var stopAnimationCalled = false
    var locationCounter: Int?
    var animationSpeed: ForwardModifier = .x1

    init(coordinator: MapView.Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: currentLocation.latitude, longitude: currentLocation.longitude, zoom: currentZoom)
        map = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        if let map {
            self.view.addSubview(map)
        }
        marker.icon = UIImage(named: "marker")
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = map
    }

    func setPolyline(polyline: PolylineIdentifiable) {
        guard currentPolylineID != polyline.id else { return }
        polyline.polyline.map = map
        currentPolylineID = polyline.id
        print("polyline set")
    }

    func moveMarkerWithoutAnimation(to location: CLLocationCoordinate2D) {
        if currentLocation.latitude != location.latitude && currentLocation.longitude != location.longitude {
            marker.position = location
            currentLocation = location
        }
    }

    func zoomMapWithAnimation(zoom: Float) {
        guard zoom != currentZoom else { return }
        map?.animate(toZoom: zoom)
        currentZoom = zoom
        print("zoom set")
    }

    func setMarkerLocation(location: CLLocationCoordinate2D, completion: @escaping () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(1/animationSpeed.rawValue)
        CATransaction.setCompletionBlock {
            completion()
        }
        marker.layer.latitude = location.latitude
        marker.layer.longitude = location.longitude
        if coordinator.store.state.followTrackIsOn {
            let cameraUpdate = GMSCameraUpdate.setTarget(location)
            map?.animate(with: cameraUpdate)
        }
        CATransaction.commit()
    }

    func stopAnimation() {
        stopAnimationCalled = true
    }

    func setAnimationSpeed(_ forwardModifier: ForwardModifier) {
        guard animationSpeed != forwardModifier else { return }
        animationSpeed = forwardModifier
    }

    func startRoute(route: [Track]) {
        guard !animationStarted else { return }
        print("start route")
        animationStarted = true
        if route.count > 20 {
            Task {
                var counter = 0
                if let locationCounter {
                    counter = locationCounter
                }
                var previousCoordinate = currentLocation

                while counter < route.count - 1 {
                    if stopAnimationCalled {
                        break
                    }
                    await withCheckedContinuation { continuation in
                        let coordinates = route[counter].location.coordinates
                        let rotation = GeometryService.DegreeBearing(A: previousCoordinate, B: coordinates)

                        marker.rotation = rotation
                        setMarkerLocation(location: coordinates) { [weak self] in
                            self?.coordinator.store.send(.calculateSliderValue(counter))
                            let velocity = route[counter].velocity
                            self?.coordinator.store.send(.setCurrentVelocity(Int(velocity)))
                            counter += 1
                            previousCoordinate = coordinates
                            continuation.resume()
                        }
                    }
                }
                print("finish animation")
                locationCounter = counter
                animationStarted = false
                stopAnimationCalled = false
            }
        }
    }
}
