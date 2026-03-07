//
//  GithubAuthService.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation
import AuthenticationServices

final class GitHubAuthService {
  private let clientID: String
  private let clientSecret: String
  private let redirectScheme: String
  private let provider: APIProvider
  private let webAuth: WebAuthSession
  private let tokenStore: TokenStore
  
  init(
    clientID: String,
    clientSecret: String,
    redirectScheme: String,
    provider: APIProvider,
    webAuth: WebAuthSession,
    tokenStore: TokenStore = KeychainTokenStore()
  ) {
    self.clientID = clientID
    self.clientSecret = clientSecret
    self.redirectScheme = redirectScheme
    self.provider = provider
    self.webAuth = webAuth
    self.tokenStore = tokenStore
  }
  
  func login(presentationAnchor: ASPresentationAnchor) async throws -> String {
    let code = try await authorize()
    let token = try await exchange(code: code)
    try tokenStore.save(token)
    return token
  }
  
  func storedToken() -> String? { tokenStore.load() }
  func logout() throws { try tokenStore.delete() }
  
  private func authorize() async throws -> String {
    var components = URLComponents(string: "https://github.com/login/oauth/authorize")!
    components.queryItems = [
      URLQueryItem(name: "client_id", value: clientID),
      URLQueryItem(name: "scope", value: "read:user"),
      URLQueryItem(name: "redirect_uri", value: "\(redirectScheme)://callback")
    ]
    
    let callbackURL = try await webAuth.authenticate(url: components.url!, callbackScheme: redirectScheme)
    guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
      .queryItems?.first(where: { $0.name == "code" })?.value
    else { throw AuthError.missingCode }
    return code
  }
  
  private func exchange(code: String) async throws -> String {
    let endpoint = GitHubEndpoint.exchangeOAuthCode(clientID: clientID, clientSecret: clientSecret, code: code)
    let response: OAuthTokenResponse = try await provider.request(endpoint)
    return response.accessToken
  }
}
