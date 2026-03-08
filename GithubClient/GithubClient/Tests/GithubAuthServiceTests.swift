//
//  GithubAuthServiceTests.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation
import Testing
@testable import GithubClient

final class MockWebAuthSession: WebAuthSession {
  var stubbedURL: URL?
  var stubbedError: Error?
  
  func authenticate(url: URL, callbackScheme: String) async throws -> URL {
    if let error = stubbedError { throw error }
    return try #require(stubbedURL)
  }
}

final class MockTokenStore: TokenStore {
  var storage: String?
  var saveError: Error?
  var deleteError: Error?
  
  func save(_ token: String) throws {
    if let error = saveError { throw error }
    storage = token
  }
  
  func load() -> String? { storage }
  
  func delete() throws {
    if let error = deleteError { throw error }
    storage = nil
  }
}

// MARK: - Tests

@Suite("GitHubAuthService")
struct GitHubAuthServiceTests {
  
  func makeService(
    callbackURL: URL? = URL(string: "mygithubapp://callback?code=abc123"),
    webAuthError: Error? = nil,
    oauthResponseData: Data = Data(#"{"access_token":"token_xyz"}"#.utf8),
    statusCode: Int = 200
  ) -> (GitHubAuthService, MockTokenStore) {
    let webAuth = MockWebAuthSession()
    webAuth.stubbedURL = callbackURL
    webAuth.stubbedError = webAuthError
    
    let session = MockNetworkSession()
    session.stubbedData = oauthResponseData
    session.stubbedResponse = HTTPURLResponse(
      url: URL(string: "https://github.com")!,
      statusCode: statusCode,
      httpVersion: nil,
      headerFields: nil
    )!
    
    let tokenStore = MockTokenStore()
    let provider = APIProvider(session: session)
    
    let service = GitHubAuthService(
      clientID: "testClientID",
      clientSecret: "testClientSecret",
      redirectScheme: "mygithubapp",
      provider: provider,
      webAuth: webAuth,
      tokenStore: tokenStore
    )
    return (service, tokenStore)
  }
  
  @Test func login_savesTokenToStore() async throws {
    let (service, tokenStore) = makeService()
    let token = try await service.login(presentationAnchor: .init())
    #expect(token == "token_xyz")
    #expect(tokenStore.storage == "token_xyz")
  }
  
  @Test func login_throwsUserCancelled_whenWebAuthCancels() async {
    let (service, _) = makeService(webAuthError: AuthError.userCancelled)
    await #expect(throws: AuthError.userCancelled) {
      try await service.login(presentationAnchor: .init())
    }
  }
  
  @Test func login_throwsMissingCode_whenCallbackHasNoCode() async {
    let (service, _) = makeService(callbackURL: URL(string: "mygithubapp://callback"))
    await #expect(throws: AuthError.missingCode) {
      try await service.login(presentationAnchor: .init())
    }
  }
  
  @Test func login_throwsHTTPError_whenExchangeFails() async {
    let (service, _) = makeService(statusCode: 401)
    await #expect(throws: APIError.self) {
      try await service.login(presentationAnchor: .init())
    }
  }
  
  @Test func storedToken_returnsNil_whenNotLoggedIn() {
    let (service, _) = makeService()
    #expect(service.storedToken() == nil)
  }
  
  @Test func storedToken_returnsToken_afterLogin() async throws {
    let (service, _) = makeService()
    let token = try await service.login(presentationAnchor: .init())
    #expect(service.storedToken() == "token_xyz")
    #expect(token == "token_xyz")
  }
  
  @Test func logout_clearsToken() async throws {
    let (service, tokenStore) = makeService()
    let token = try await service.login(presentationAnchor: .init())
    try service.logout()
    #expect(tokenStore.storage == nil)
    #expect(service.storedToken() == nil)
    #expect(token == "token_xyz")
  }
}
