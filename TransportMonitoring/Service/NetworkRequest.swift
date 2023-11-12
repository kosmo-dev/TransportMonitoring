//
//  NetworkRequest.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 11.11.2023.
//

import Foundation

enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

protocol NetworkRequest {
    var endpoint: URL? { get }
    var httpMethod: HttpMethod { get }
}

extension NetworkRequest {
    var httpMethod: HttpMethod { .get }
}

struct RouteRequest: NetworkRequest {
    var endpoint: URL? = URL(string: "https://dev5.skif.pro/coordinates.json")
}
