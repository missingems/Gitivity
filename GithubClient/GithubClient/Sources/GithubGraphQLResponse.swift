//
//  GithubGraphQLResponse.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

struct GithubGraphQLResponse: Decodable {
  let payload: Data
  
  enum CodingKeys: String, CodingKey {
    case payload = "data"
  }
  
  struct Data: Decodable {
    let viewer: GitHubUser
    
    enum CodingKeys: String, CodingKey {
      case viewer
    }
  }
}
