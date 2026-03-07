//
//  OAuthTokenResponse.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

struct OAuthTokenResponse: Decodable {
  let accessToken: String
  
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
  }
}
