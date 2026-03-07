import ProjectDescription

let project = Project(
  name: "GithubClient",
  targets: [
    .target(
      name: "GithubClient",
      destinations: .macOS,
      product: .framework,
      bundleId: "com.missingems.Gitivity.GithubClient",
      infoPlist: .default,
      sources: ["GithubClient/Sources/**"],
      resources: [],
      dependencies: []
    ),
    .target(
      name: "GithubClientTests",
      destinations: .macOS,
      product: .unitTests,
      bundleId: "com.missingems.Gitivity.GithubClientTests",
      infoPlist: .default,
      sources: ["GithubClient/Tests/**"],
      dependencies: [.target(name: "GithubClient")]
    ),
  ],
  schemes: [
    .scheme(
      name: "GithubClient",
      testAction: .targets(
        ["GithubClientTests"],
        options: .options(
          coverage: true,
          codeCoverageTargets: ["GithubClient"]
        )
      )
    )
  ]
)
