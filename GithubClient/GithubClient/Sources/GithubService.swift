//
//  GithubService.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation

protocol GitHubServiceProtocol {
  func fetchLastFiveDaysContributions(for username: String) async throws -> [ContributionsCollection.Calendar.Day]
}

final class GitHubService: GitHubServiceProtocol {
  private let provider: APIProvider
  
  init(provider: APIProvider) {
    self.provider = provider
  }
  
  func fetchLastFiveDaysContributions(for username: String) async throws -> [ContributionsCollection.Calendar.Day] {
    let endpoint = GitHubEndpoint.contributionCalendar(username: username)
    let response: GithubGraphQLResponse = try await provider.request(endpoint)
    
    let allDays = response.data.user.contributionsCollection
      .calendar
      .weeks
      .flatMap {
        $0.days
      }
    
    let lastFive = allDays.suffix(5)
    let padding = (5 - lastFive.count)
    
    let paddedDays = (0..<max(0, padding)).map { _ in
      ContributionsCollection.Calendar.Day(count: 0)
    }
    
    return paddedDays + lastFive
  }
}
