//
//  MapViewController.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 10.11.2023.
//

import UIKit
import GoogleMaps
import Combine

final class MapViewController: UIViewController {

    // MARK: - Private Properties
    private var coordinator: MapView.Coordinator
    private var map: GMSMapView?

    private var currentPolylineID: UUID = UUID()
    private var currentZoom: Float = 12
    private var currentLocation = CLLocationCoordinate2D(latitude: 55.755802, longitude: 37.617705)
    private var marker = GMSMarker(position: CLLocationCoordinate2D(latitude: 55.755802, longitude: 37.617705))
    private var animationStarted = false
    private var stopAnimationCalled = false
    private var animationSpeed: ForwardModifier = .x1

    // MARK: - Initializers
    init(coordinator: MapView.Coordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
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
        map?.delegate = self
    }

    // MARK: - Public MEthods
    func setPolyline(polyline: PolylineIdentifiable) {
        guard currentPolylineID != polyline.id else { return }
        polyline.polyline.map = map
        currentPolylineID = polyline.id
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
        animationStarted = true
        Task {
            var counter = 0

            var cancellable = coordinator.store.$state.sink { state in
                counter = state.trackCounter
            }

            var previousCoordinate = currentLocation

            while counter < route.count {
                if stopAnimationCalled {
                    break
                }
                await withCheckedContinuation { continuation in
                    let coordinates = route[counter].location.coordinates
                    let rotation = GeometryService.DegreeBearing(A: previousCoordinate, B: coordinates)

                    marker.rotation = rotation
                    setMarkerLocation(location: coordinates) { [weak self] in
                        let velocity = route[counter].velocity
                        self?.coordinator.store.send(.setCurrentVelocity(Int(velocity)))
                        self?.coordinator.store.send(.calculateSliderValue(counter + 1))
                        previousCoordinate = coordinates
                        continuation.resume()
                    }
                }
            }
            animationStarted = false
            stopAnimationCalled = false
            coordinator.store.send(.routeAnimationStoppedDelegate)
        }
    }

    // MARK: - Private Methods
    private func setMarkerLocation(location: CLLocationCoordinate2D, completion: @escaping () -> Void) {
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
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        if gesture {
            coordinator.store.send(.deactivateFollowTrack)
        }
    }
}
