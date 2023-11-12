//
//  NetworkClient.swift
//  TransportMonitoring
//
//  Created by Вадим Кузьмин on 11.11.2023.
//

import Foundation
import Combine
import UIKit

enum NetworkClientError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case parsingError
    case badUrlRequest
}

protocol NetworkClientProtocol {
//    func send<T:Decodable>(_ type: T.Type, request: NetworkRequest) -> AnyPublisher<T, Error>
    func send<T:Decodable>(_ type: T.Type, request: NetworkRequest) -> AnyPublisher<Data, Never>
}

struct NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    init(session: URLSession = URLSession.shared,
         decoder: JSONDecoder = JSONDecoder(),
         encoder: JSONEncoder = JSONEncoder()) {
        self.session = session
        self.decoder = decoder
        self.encoder = encoder
    }

    func send<T:Decodable>(_ type: T.Type, request: NetworkRequest) -> AnyPublisher<Data, Never> {
        guard let urlRequest = create(request: request) else {
            return Just(Data()).eraseToAnyPublisher()
        }
        return session.dataTaskPublisher(for: urlRequest)
            .map(\.data)
            .replaceError(with: Data())
            .eraseToAnyPublisher()
    }

    // MARK: - Private
    private func create(request: NetworkRequest) -> URLRequest? {
        guard let endpoint = request.endpoint else {
            assertionFailure("Empty endpoint")
            return nil
        }

        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = request.httpMethod.rawValue

        return urlRequest
    }

    private func handleResponse(data: Data, response: URLResponse) throws -> Data {
        guard let response = response as? HTTPURLResponse else {
            throw NetworkClientError.urlSessionError
        }
        guard 200..<300 ~= response.statusCode else {
            throw NetworkClientError.httpStatusCode(response.statusCode)
        }
        return data
    }
}
