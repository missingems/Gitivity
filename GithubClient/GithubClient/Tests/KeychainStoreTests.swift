//
//  KeychainStoreTests.swift
//  GithubClient
//
//  Created by Jun on 7/3/26.
//

import Testing
import Foundation
@testable import GithubClient

@Suite("KeychainTokenStore")
struct KeychainTokenStoreTests {
  func makeStore() -> KeychainTokenStore {
    KeychainTokenStore(
      service: "com.missingems.Gitivity.tests.\(UUID().uuidString)",
      account: "test_token"
    )
  }
  
  @Test func save_andLoad_returnsToken() throws {
    let store = makeStore()
    try store.save("my_token")
    #expect(store.load() == "my_token")
  }
  
  @Test func load_returnsNil_whenEmpty() {
    let store = makeStore()
    #expect(store.load() == nil)
  }
  
  @Test func save_overwritesPreviousToken() throws {
    let store = makeStore()
    try store.save("first_token")
    try store.save("second_token")
    #expect(store.load() == "second_token")
  }
  
  @Test func delete_removesToken() throws {
    let store = makeStore()
    try store.save("my_token")
    try store.delete()
    #expect(store.load() == nil)
  }
  
  @Test func delete_doesNotThrow_whenAlreadyEmpty() {
    let store = makeStore()
    #expect(throws: Never.self) {
      try store.delete()
    }
  }
}
