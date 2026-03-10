import ProjectDescription

let project = Project(
  name: "ClientProviders",
  targets: [
    .target(
      name: "ClientProviders",
      destinations: .iOS,
      product: .app,
      bundleId: "io.tuist.ClientProviders",
      infoPlist: .extendingDefault(
        with: [
          "UILaunchScreen": [
            "UIColorName": "",
            "UIImageName": "",
          ],
        ]
      ),
      sources: ["ClientProviders/Sources/**"],
      resources: ["ClientProviders/Resources/**"],
      dependencies: []
    ),
    .target(
      name: "ClientProvidersTests",
      destinations: .iOS,
      product: .unitTests,
      bundleId: "io.tuist.ClientProvidersTests",
      infoPlist: .default,
      sources: ["ClientProviders/Tests/**"],
      resources: [],
      dependencies: [.target(name: "ClientProviders")]
    ),
  ]
)

