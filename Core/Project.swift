import ProjectDescription

let project = Project(
  name: "Core",
  targets: [
    .target(
      name: "Core",
      destinations: .macOS,
      product: .framework,
      bundleId: "com.missingems.Gitivity.Core",
      infoPlist: .default,
      sources: ["Core/Sources/**"],
      resources: ["Core/Resources/**"],
      dependencies: []
    ),
    .target(
      name: "CoreTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "io.tuist.CoreTests",
      infoPlist: .default,
      sources: ["Core/Tests/**"],
      resources: [],
      dependencies: [.target(name: "Core")]
    ),
  ],
  schemes: [
    .scheme(
      name: "Core",
      testAction: .targets(
        ["CoreTests"],
        options: .options(
          coverage: true,
          codeCoverageTargets: ["Core"]
        )
      )
    )
  ]
)
