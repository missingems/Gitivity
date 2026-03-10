//
//  GithubStatusManager.swift
//  GithubClient
//
//  Created by Jun on 8/3/26.
//

import Foundation

public actor GitHubStatusManager {
  public private(set) var contributions: [ContributionsCollection.Calendar.Day] = []
  public private(set) var isLoggedIn: Bool
  
  private let service: GitHubServiceProtocol
  private var refreshTask: Task<Void, Never>?
  
  public init() {
    let tokenStore = KeychainTokenStore()
    let provider = APIProvider(
      authHeaderProvider: { _ in
        guard let token = tokenStore.load() else { return [:] }
        return ["Authorization": "Bearer \(token)"]
      }
    )
    self.service = GitHubService(provider: provider)
    self.isLoggedIn = tokenStore.load() != nil
  }
  
  // MARK: - Public API
  
  public func startAutoRefresh() {
    let interval = UserDefaults.standard.integer(forKey: "refreshInterval")
    let safeInterval = interval > 0 ? interval : 10
    
    refreshTask?.cancel()
    refreshTask = Task {
      while !Task.isCancelled {
        await refresh()
        try? await Task.sleep(nanoseconds: UInt64(safeInterval) * 1_000_000_000)
      }
    }
  }
  
  public func stopAutoRefresh() {
    refreshTask?.cancel()
    refreshTask = nil
  }
  
  public func refresh() async {
    guard isLoggedIn else {
      contributions = []
      return
    }
    
    do {
      contributions = try await service.fetchLastFiveDaysContributions()
    } catch {
      contributions = []
    }
  }
  
  public func didLogin() {
    isLoggedIn = true
    startAutoRefresh()
  }
  
  public func didLogout() {
    isLoggedIn = false
    contributions = []
    stopAutoRefresh()
  }
}
