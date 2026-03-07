//
//  OAuthCodeRequest.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

struct OAuthCodeRequest: Encodable {
  let clientId: String
  let clientSecret: String
  let code: String
  
  enum CodingKeys: String, CodingKey {
    case clientId = "client_id"
    case clientSecret = "client_secret"
    case code
  }
}
