//
//  ExchangeOAuthCodeTests.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation
import Testing
@testable import GithubClient

@Suite("ExchangeOAuthCode")
struct ExchangeOAuthCodeTests {
  @Test func baseURL() {
    let endpoint = GitHubEndpoint.exchangeOAuthCode(
      clientID: "id", clientSecret: "secret", code: "code123"
    )
    #expect(endpoint.baseURL.absoluteString == "https://github.com")
  }
  
  @Test func bodyContainsAllFields() throws {
    let endpoint = GitHubEndpoint.exchangeOAuthCode(
      clientID: "myID", clientSecret: "mySecret", code: "abc"
    )
    let request = try endpoint.asURLRequest()
    let body = try #require(request.httpBody)
    let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: String])
    
    #expect(json["client_id"] == "myID")
    #expect(json["client_secret"] == "mySecret")
    #expect(json["code"] == "abc")
  }
}
