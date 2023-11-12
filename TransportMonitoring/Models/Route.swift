//
//  Route.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 11.11.2023.
//

import Foundation

struct Location: Codable {
    var timestamp: Date
    var latitude: Double
    var longitude: Double
}

struct Track {
    let lastLocation: Location
    let meters: Double
    let velocity: Double
    let acceleration: Double
}

import Foundation

enum RouteElement: Codable {
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Double.self) {
            self = .double(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(RouteElement.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for RouteElement"))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .double(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

typealias Route = [[RouteElement]]
