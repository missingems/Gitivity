//
//  GithubGraphQLResponse.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

struct GithubGraphQLResponse: Decodable {
  let data: Data
  
  struct Data: Decodable {
    let user: GitHubUser
  }
}
