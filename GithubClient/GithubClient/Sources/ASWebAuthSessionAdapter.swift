//
//  ASWebAuthSessionAdapter.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation
import AuthenticationServices

protocol WebAuthSession {
  func authenticate(url: URL, callbackScheme: String) async throws -> URL
}

final class ASWebAuthSessionAdapter: NSObject, WebAuthSession, ASWebAuthenticationPresentationContextProviding {
  private let anchor: ASPresentationAnchor
  
  init(anchor: ASPresentationAnchor) {
    self.anchor = anchor
  }
  
  func authenticate(url: URL, callbackScheme: String) async throws -> URL {
    try await withCheckedThrowingContinuation { continuation in
      let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackScheme) { url, error in
        if let error = error as? ASWebAuthenticationSessionError,
           error.code == .canceledLogin {
          continuation.resume(throwing: AuthError.userCancelled)
          return
        }
        
        guard let url else {
          continuation.resume(throwing: AuthError.missingCode)
          return
        }
        
        continuation.resume(returning: url)
      }
      
      session.presentationContextProvider = self
      session.prefersEphemeralWebBrowserSession = false
      session.start()
    }
  }
  
  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    anchor
  }
}
