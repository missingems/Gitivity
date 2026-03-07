//
//  KeychainTokenStore.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Foundation

protocol TokenStore {
  func save(_ token: String) throws
  func load() -> String?
  func delete() throws
}

final class KeychainTokenStore: TokenStore {
  private let service: String
  private let account: String
  
  init(service: String = "com.missingems.Gitivity", account: String = "github_token") {
    self.service = service
    self.account = account
  }
  
  func save(_ token: String) throws {
    let data = Data(token.utf8)
    SecItemDelete(query() as CFDictionary)
    
    let add = query().merging(
      [
        kSecValueData: data,
        kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
      ]
    ) { $1 }
    
    let status = SecItemAdd(add as CFDictionary, nil)
    guard status == errSecSuccess else { throw AuthError.keychainFailure(status) }
  }
  
  func load() -> String? {
    let query = query().merging([kSecReturnData: true, kSecMatchLimit: kSecMatchLimitOne]) { $1 }
    var result: AnyObject?
    guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
          let data = result as? Data else { return nil }
    return String(data: data, encoding: .utf8)
  }
  
  func delete() throws {
    let status = SecItemDelete(query() as CFDictionary)
    guard status == errSecSuccess || status == errSecItemNotFound else {
      throw AuthError.keychainFailure(status)
    }
  }
  
  private func query() -> [CFString: Any] {
    [kSecClass: kSecClassGenericPassword, kSecAttrService: service, kSecAttrAccount: account]
  }
}
