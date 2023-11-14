//
//  Track.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 14.11.2023.
//

import Foundation
import GoogleMaps

struct Track {
    let location: Location
    let meters: Double
    let velocity: Double
    let acceleration: Double
}

struct Location {
    var timestamp: Date
    var coordinates: CLLocationCoordinate2D
}
