//
//  GithubServiceTests.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation
import Testing
@testable import GithubClient

@Suite("GitHubService")
struct GitHubServiceTests {
  @Test func returnsLastFiveDays() async throws {
    let result = try await makeService(counts: [1, 2, 3, 4, 5, 6, 7])
      .fetchLastFiveDaysContributions(for: "")
    #expect(result.map(\.count) == [3, 4, 5, 6, 7])
  }
  
  @Test func returnsExactlyFive() async throws {
    let result = try await makeService(counts: [1, 2, 3, 4, 5])
      .fetchLastFiveDaysContributions(for: "")
    #expect(result.map(\.count) == [1, 2, 3, 4, 5])
  }
  
  @Test func padsWithZeros_whenFewerThanFiveDays() async throws {
    let result = try await makeService(counts: [10, 20])
      .fetchLastFiveDaysContributions(for: "")
    #expect(result.map(\.count) == [0, 0, 0, 10, 20])
  }
  
  @Test("Always returns 5 elements", arguments: 0...7)
  func alwaysReturnsFiveElements(inputCount: Int) async throws {
    let result = try await makeService(counts: Array(repeating: 1, count: inputCount))
      .fetchLastFiveDaysContributions(for: "")
    #expect(result.count == 5)
  }
  
  @Test func propagatesNetworkError() async {
    let service = makeService(counts: [], error: URLError(.notConnectedToInternet))
    await #expect(throws: APIError.self) {
      try await service.fetchLastFiveDaysContributions(for: "")
    }
  }
  
  @Test func throwsHTTPError_on401() async {
    let service = makeService(counts: [], statusCode: 401)
    await #expect(throws: APIError.httpError(401)) {
      try await service.fetchLastFiveDaysContributions(for: "")
    }
  }
}

extension GitHubServiceTests {
  func makeCalendarJSON(counts: [Int]) -> Data {
    let days = counts
      .enumerated()
      .map { i, count in
        #"{"contributionCount":\#(count),"date":"2026-07-0\#(i + 1)"}"#
      }
      .joined(separator: ",")
    
    return Data("""
        {
          "data": {
            "viewer": {
              "contributionsCollection": {
                "contributionCalendar": {
                  "weeks": [{ "contributionDays": [\(days)] }]
                }
              }
            }
          }
        }
        """.utf8)
  }
  
  func makeService(counts: [Int], statusCode: Int = 200, error: Error? = nil) -> GitHubService {
    let session = MockNetworkSession()
    session.stubbedData = makeCalendarJSON(counts: counts)
    session.stubbedResponse = HTTPURLResponse(
      url: URL(string: "https://api.github.com")!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: nil
    )!
    session.stubbedError = error
    return GitHubService(provider: APIProvider(session: session))
  }
}
