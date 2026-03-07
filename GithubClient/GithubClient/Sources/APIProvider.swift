//
//  APIProvider.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation

enum APIError: Error {
  case networkError(_ error: Error)
  case invalidRequest
  case invalidResponse
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
  
  func request<T: Decodable>(_ endpoint: TargetType, as type: T.Type = T.self) async throws(APIError) -> T {
    var request: URLRequest
    
    do {
      request = try endpoint.asURLRequest()
    } catch {
      throw .invalidRequest
    }
    
    authHeaderProvider?(endpoint)
      .forEach {
        request.addValue($1, forHTTPHeaderField: $0)
      }
    
    let data: Data
    let response: URLResponse
    do {
      (data, response) = try await session.data(for: request)
    } catch {
      throw .networkError(error)
    }
    
    guard let http = response as? HTTPURLResponse else {
      throw .invalidResponse
    }
    
    guard (200..<300).contains(http.statusCode) else {
      throw .httpError(http.statusCode)
    }
    
    do {
      return try decoder.decode(T.self, from: data)
    } catch {
      throw .decodingError
    }
  }
}
