// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MySpecialDates",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MySpecialDates",
            targets: ["MySpecialDates"]),
    ],
    dependencies: [
        .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.25.0"),
    ],
    targets: [
        .target(
            name: "MySpecialDates",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestore", package: "firebase-ios-sdk"),
                .product(name: "FirebaseFirestoreSwift", package: "firebase-ios-sdk"),
            ]),
        .testTarget(
            name: "MySpecialDatesTests",
            dependencies: ["MySpecialDates"]),
    ]
)