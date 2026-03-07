//
//  APIProvider.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation

enum APIError: Error, Equatable {
  case networkError
  case httpError(_ statusCode: Int)
  case decodingError
}

final class APIProvider {
  private let session: NetworkSession
  private let decoder: JSONDecoder
  private let authHeaderProvider: ((TargetType) -> [String: String])?
  
  init(
    session: NetworkSession = URLSession.shared,
    decoder: JSONDecoder = .init(),
    authHeaderProvider: ((TargetType) -> [String: String])? = nil
  ) {
    self.session = session
    self.decoder = decoder
    self.authHeaderProvider = authHeaderProvider
  }
  
  func request<T: Decodable>(_ endpoint: TargetType, as type: T.Type = T.self) async throws -> T {
    var request: URLRequest
    
    request = try endpoint.asURLRequest()
    
    authHeaderProvider?(endpoint)
      .forEach {
        request.addValue($1, forHTTPHeaderField: $0)
      }
    
    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await session.data(for: request)
    } catch {
      throw APIError.networkError
    }
    
    let statusCode = (response as? HTTPURLResponse)?.statusCode
    let valid = statusCode.map { value in
      return value >= 200 && value < 300
    }
    
    if valid == false {
      throw APIError.httpError(statusCode ?? -1)
    }
    
    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw APIError.decodingError
    }
  }
}
