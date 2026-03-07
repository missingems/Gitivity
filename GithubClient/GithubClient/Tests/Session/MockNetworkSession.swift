//
//  MockNetworkSession.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation
@testable import GithubClient

final class MockNetworkSession: NetworkSession {
  var stubbedData: Data = Data()
  var stubbedResponse = HTTPURLResponse(
    url: URL(string: "https://api.github.com")!,
    statusCode: 200,
    httpVersion: nil,
    headerFields: nil
  )!
  var stubbedError: Error?
  
  private(set) var lastRequest: URLRequest?
  
  func data(for request: URLRequest) async throws -> (Data, URLResponse) {
    lastRequest = request
    if let error = stubbedError { throw error }
    return (stubbedData, stubbedResponse)
  }
}
