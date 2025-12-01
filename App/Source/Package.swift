// swift-tools-version:5.9
// Package.swift for VibeIntelligence
// Part of VibeCaaS.com - "Code the Vibe. Deploy the Dream."

import PackageDescription

let package = Package(
    name: "VibeIntelligence",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "VibeIntelligenceApp", targets: ["VibeIntelligenceApp"])
    ],
    targets: [
        .executableTarget(
            name: "VibeIntelligenceApp",
            path: ".",
            sources: ["VibeIntelligenceApp.swift"]
        )
    ]
)
