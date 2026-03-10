//
//  TargetType.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation

enum HTTPMethod: String {
  case get  = "GET"
  case post = "POST"
}

enum TargetTask {
  case plain
  case jsonBody(Encodable)
}

protocol TargetType {
  var baseURL: URL { get }
  var path: String { get }
  var method: HTTPMethod { get }
  var headers: [String: String] { get }
  var task: TargetTask { get }
}

extension TargetType {
  func asURLRequest() throws -> URLRequest {
    let url = baseURL.appendingPathComponent(path)
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
    
    if case let .jsonBody(body) = task {
      request.httpBody = try JSONEncoder().encode(body)
      request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    return request
  }
}
