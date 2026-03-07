//
//  GithubAuthService.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation
import AuthenticationServices

final class GitHubAuthService: NSObject {
  enum AuthError: Error {
    case userCancelled
    case missingCode
    case keychainFailure(OSStatus)
  }
  
  private let clientID: String
  private let clientSecret: String
  private let redirectScheme: String
  private let keychainKey = "github_access_token"
  private let provider: APIProvider
  
  init(clientID: String, clientSecret: String, redirectScheme: String, provider: APIProvider) {
    self.clientID = clientID
    self.clientSecret = clientSecret
    self.redirectScheme = redirectScheme
    self.provider = provider
  }
  
  func login(presentationAnchor: ASPresentationAnchor) async throws -> String {
    let code = try await authorize(presentationAnchor: presentationAnchor)
    let token = try await exchange(code: code)
    try save(token: token)
    return token
  }
  
  func storedToken() -> String? {
    let query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: keychainKey,
      kSecReturnData: true,
      kSecMatchLimit: kSecMatchLimitOne
    ]
    
    var result: AnyObject?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard
      status == errSecSuccess,
      let data = result as? Data,
      let token = String(data: data, encoding: .utf8)
    else {
      return nil
    }
    
    return token
  }
  
  func logout() throws(AuthError) {
    let query: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: keychainKey
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw .keychainFailure(status)
    }
  }
  
  private func authorize(presentationAnchor: ASPresentationAnchor) async throws -> String {
    var components = URLComponents(string: "https://github.com/login/oauth/authorize")!
    components.queryItems = [
      URLQueryItem(name: "client_id", value: clientID),
      URLQueryItem(name: "scope", value: "read:user"),
      URLQueryItem(name: "redirect_uri", value: "\(redirectScheme)://callback")
    ]
    
    return try await withCheckedThrowingContinuation { continuation in
      let session = ASWebAuthenticationSession(
        url: components.url!,
        callbackURLScheme: redirectScheme
      ) { callbackURL, error in
        if
          let error = error as? ASWebAuthenticationSessionError,
          error.code == .canceledLogin {
          continuation.resume(throwing: AuthError.userCancelled)
          return
        }
        
        guard let url = callbackURL,
              let code = URLComponents(url: url, resolvingAgainstBaseURL: false)?
          .queryItems?.first(where: { $0.name == "code" })?.value
        else {
          continuation.resume(throwing: AuthError.missingCode)
          return
        }
        
        continuation.resume(returning: code)
      }
      
      session.presentationContextProvider = self
      session.prefersEphemeralWebBrowserSession = false
      session.start()
    }
  }
  
  private func exchange(code: String) async throws -> String {
    try await provider.request(
      GitHubEndpoint.exchangeOAuthCode(
        clientID: clientID,
        clientSecret: clientSecret,
        code: code
      ),
      as: OAuthTokenResponse.self
    )
    .accessToken
  }
  
  private func save(token: String) throws(AuthError) {
    let deleteQuery: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: keychainKey
    ]
    
    SecItemDelete(deleteQuery as CFDictionary)
    
    let addQuery: [CFString: Any] = [
      kSecClass: kSecClassGenericPassword,
      kSecAttrAccount: keychainKey,
      kSecValueData: Data(token.utf8),
      kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
    ]
    
    let status = SecItemAdd(addQuery as CFDictionary, nil)
    
    guard status == errSecSuccess else {
      throw .keychainFailure(status)
    }
  }
}

extension GitHubAuthService: ASWebAuthenticationPresentationContextProviding {
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    ASPresentationAnchor()
  }
}
