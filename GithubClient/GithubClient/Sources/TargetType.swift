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

enum Task {
  case plain
  case jsonBody(Encodable)
}

protocol TargetType {
  var baseURL: URL { get }
  var path: String { get }
  var method: HTTPMethod { get }
  var headers: [String: String] { get }
  var task: Task { get }
}

extension TargetType {
  func asURLRequest() throws -> URLRequest {
    let url = baseURL.appendingPathComponent(path)
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    headers.forEach { request.addValue($1, forHTTPHeaderField: $0) }
    
    if case .jsonBody(let body) = task {
      request.httpBody = try JSONSerialization.data(withJSONObject: body)
      
      if request.value(forHTTPHeaderField: "Content-Type") == nil {
        request.addValue(
          "application/json",
          forHTTPHeaderField: "Content-Type"
        )
      }
    }
    
    return request
  }
}
