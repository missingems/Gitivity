import ProjectDescription

let project = Project(
  name: "Gitivity",
  targets: [
    .target(
      name: "Gitivity",
      destinations: .macOS,
      product: .app,
      bundleId: "com.missingems.Gitivity",
      infoPlist: .extendingDefault(
        with: [
          "LSUIElement": true,
          "NSMainStoryboardFile": "",
          "NSPrincipalClass": "NSApplication"
        ]
      ),
      sources: ["Gitivity/Sources/**"],
      resources: ["Gitivity/Resources/**"],
      entitlements: .dictionary([
        "com.apple.security.app-sandbox": true,
        "com.apple.security.network.client": true
      ]),
      dependencies: [
        .project(target: "GithubClient", path: "./GithubClient")
      ]
    ),
    .target(
      name: "GitivityTests",
      destinations: .macOS,
      product: .unitTests,
      bundleId: "com.missingems.GitivityTests",
      infoPlist: .default,
      sources: ["Gitivity/Tests/**"],
      resources: [],
      dependencies: [.target(name: "Gitivity")]
    ),
  ]
)
