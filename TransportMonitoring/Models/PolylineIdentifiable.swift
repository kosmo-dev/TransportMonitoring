//
//  PolylineIdentifiable.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 14.11.2023.
//

import Foundation
import GoogleMaps

struct PolylineIdentifiable {
    let id: UUID
    let polyline: GMSPolyline
}
