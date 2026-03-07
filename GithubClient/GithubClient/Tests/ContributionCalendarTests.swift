//
//  ContributionCalendarTests.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation
import Testing
@testable import GithubClient

@Suite("ContributionCalendar")
struct ContributionCalendarTests {
  @Test func baseURL() {
    let endpoint = GitHubEndpoint.contributionCalendar(username: "octocat")
    #expect(endpoint.baseURL.absoluteString == "https://api.github.com")
  }
  
  @Test func path() {
    let endpoint = GitHubEndpoint.contributionCalendar(username: "octocat")
    #expect(endpoint.path == "/graphql")
  }
  
  @Test func method() {
    let endpoint = GitHubEndpoint.contributionCalendar(username: "octocat")
    #expect(endpoint.method == .post)
  }
  
  @Test func bodyContainsUsername() throws {
    let username = "octocat"
    let endpoint = GitHubEndpoint.contributionCalendar(username: username)
    let request = try endpoint.asURLRequest()
    
    let body = try #require(request.httpBody)
    let json = try #require(JSONSerialization.jsonObject(with: body) as? [String: String])
    #expect(json["query"]?.contains(username) == true)
  }
  
  @Test func noAuthHeaderByDefault() throws {
    let endpoint = GitHubEndpoint.contributionCalendar(username: "octocat")
    let request = try endpoint.asURLRequest()
    #expect(request.value(forHTTPHeaderField: "Authorization") == nil)
  }
}
