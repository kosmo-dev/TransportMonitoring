//
//  GeometryService.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 14.11.2023.
//

import Foundation
import GoogleMaps

struct GeometryService {
    static func haversine(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0  // Earth's radius in kilometers

        // Convert latitude and longitude from degrees to radians
        let lat1Rad = lat1 * .pi / 180.0
        let lon1Rad = lon1 * .pi / 180.0
        let lat2Rad = lat2 * .pi / 180.0
        let lon2Rad = lon2 * .pi / 180.0

        // Differences in coordinates
        let dlat = lat2Rad - lat1Rad
        let dlon = lon2Rad - lon1Rad

        // Haversine formula
        let a = sin(dlat / 2.0) * sin(dlat / 2.0) + cos(lat1Rad) * cos(lat2Rad) * sin(dlon / 2.0) * sin(dlon / 2.0)
        let c = 2.0 * atan2(sqrt(a), sqrt(1.0 - a))

        // Distance in kilometers
        let distance = R * c

        return distance
    }

    static func DegreeBearing(A: CLLocationCoordinate2D, B: CLLocationCoordinate2D) -> Double {
        var dlon = ToRad(degrees: B.longitude - A.longitude)
        let dPhi = log(tan(ToRad(degrees: B.latitude) / 2 + .pi / 4) / tan(ToRad(degrees: A.latitude) / 2 + .pi / 4))
        if  abs(dlon) > .pi {
            dlon = (dlon > 0) ? (dlon - 2 * .pi) : (2 * .pi + dlon)
        }
        return ToBearing(radians: atan2(dlon, dPhi))

        func ToRad(degrees: Double) -> Double {
            return degrees * ( .pi / 180)
        }

        func ToBearing(radians: Double) -> Double {
            return (ToDegrees(radians: radians) + 360).truncatingRemainder(dividingBy: 360)
        }

        func ToDegrees(radians: Double) -> Double{
            return radians * 180 / .pi
        }
    }
}
