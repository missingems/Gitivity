//
//  GitHubEndpoint.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation

enum GitHubEndpoint {
  case contributionCalendar(username: String)
  case exchangeOAuthCode(clientID: String, clientSecret: String, code: String)
}

extension GitHubEndpoint: TargetType {
  var baseURL: URL {
    return switch self {
    case .contributionCalendar: URL(string: "https://api.github.com")!
    case .exchangeOAuthCode: URL(string: "https://github.com")!
    }
  }
  
  var path: String {
    return switch self {
    case .contributionCalendar: "/graphql"
    case .exchangeOAuthCode: "/login/oauth/access_token"
    }
  }
  
  var method: HTTPMethod {
    return switch self {
    case .contributionCalendar, .exchangeOAuthCode: .post
    }
  }
  
  var headers: [String: String] {
    return switch self {
    case .contributionCalendar: ["Content-Type": "application/json"]
    case .exchangeOAuthCode: [
      "Content-Type": "application/json",
      "Accept": "application/json"
    ]
    }
  }
  
  var task: Task {
    return switch self {
    case let .contributionCalendar(username):
        .jsonBody(
          ContributionCalendarRequest(
            query: """
                query {
                  user(login: "\(username)") {
                    contributionsCollection {
                      contributionCalendar {
                        weeks {
                          contributionDays {
                            contributionCount
                            date
                          }
                        }
                      }
                    }
                  }
                }
                """
          )
        )
      
    case let .exchangeOAuthCode(clientID, clientSecret, code):
        .jsonBody(
          OAuthCodeRequest(
            clientId: clientID,
            clientSecret: clientSecret,
            code: code
          )
        )
    }
  }
}
