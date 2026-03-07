//
//  APIProviderTests.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation
import Testing
@testable import GithubClient

@Suite("APIProvider")
struct APIProviderTests {
  @Test func decodesValidResponse() async throws {
    let (provider, _) = makeProvider(data: Data(#"{"name":"octocat"}"#.utf8))
    
    struct Simple: Decodable { let name: String }
    let result: Simple = try await provider.request(
      GitHubEndpoint.contributionCalendar(username: "octocat")
    )
    #expect(result.name == "octocat")
  }
  
  @Test func throwsHTTPError_on404() async {
    let (provider, _) = makeProvider(statusCode: 404)
    
    struct Simple: Decodable { let name: String }
    await #expect(throws: APIError.httpError(404)) {
      let _: Simple = try await provider.request(
        GitHubEndpoint.contributionCalendar(username: "octocat")
      )
    }
  }
  
  @Test func throwsHTTPError_on401() async {
    let (provider, _) = makeProvider(statusCode: 401)
    
    struct Simple: Decodable { let name: String }
    await #expect(throws: APIError.httpError(401)) {
      let _: Simple = try await provider.request(
        GitHubEndpoint.contributionCalendar(username: "octocat")
      )
    }
  }
  
  @Test func throwsDecodingError_onMalformedJSON() async {
    let (provider, _) = makeProvider(data: Data("not json".utf8))
    
    struct Simple: Decodable { let name: String }
    await #expect(throws: APIError.decodingError) {
      let _: Simple = try await provider.request(
        GitHubEndpoint.contributionCalendar(username: "octocat")
      )
    }
  }
  
  @Test func injectsAuthHeader() async throws {
    let (provider, session) = makeProvider(
      data: Data(#"{"name":"octocat"}"#.utf8),
      authHeaders: ["Authorization": "Bearer test_token"]
    )
    
    struct Simple: Decodable { let name: String }
    let _: Simple = try await provider.request(
      GitHubEndpoint.contributionCalendar(username: "octocat")
    )
    #expect(session.lastRequest?.value(forHTTPHeaderField: "Authorization") == "Bearer test_token")
  }
  
  @Test func propagatesNetworkError() async {
    struct DummyError: Error {}
    let (provider, _) = makeProvider(error: DummyError())
    
    struct Simple: Decodable { let name: String }
    await #expect(throws: APIError.self) {
      let _: Simple = try await provider.request(
        GitHubEndpoint.contributionCalendar(username: "octocat")
      )
    }
  }
}

extension APIProviderTests {
  func makeProvider(
    data: Data = Data(),
    statusCode: Int = 200,
    error: Error? = nil,
    authHeaders: [String: String] = [:]
  ) -> (APIProvider, MockNetworkSession) {
    let session = MockNetworkSession()
    session.stubbedData = data
    session.stubbedResponse = HTTPURLResponse(
      url: URL(string: "https://api.github.com")!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: nil
    )!
    session.stubbedError = error
    let provider = APIProvider(session: session) { _ in authHeaders }
    return (provider, session)
  }
}
