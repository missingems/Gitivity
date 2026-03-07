//
//  NetworkSession.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation

protocol NetworkSession {
  func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: NetworkSession {}
