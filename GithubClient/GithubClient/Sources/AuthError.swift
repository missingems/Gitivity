//
//  AuthError.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation

enum AuthError: Error, Equatable {
  case userCancelled
  case missingCode
  case keychainFailure(OSStatus)
}
