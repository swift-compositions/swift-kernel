// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-kernel",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [

        .library(
            name: "Kernel Core",
            targets: ["Kernel Core"]
        ),

        .library(
            name: "Kernel System",
            targets: ["Kernel System"]
        ),
        .library(
            name: "Kernel Thread",
            targets: ["Kernel Thread"]
        ),
        .library(
            name: "Kernel File",
            targets: ["Kernel File"]
        ),
        .library(
            name: "Kernel Event",
            targets: ["Kernel Event"]
        ),
        .library(
            name: "Kernel Completion",
            targets: ["Kernel Completion"]
        ),
        .library(
            name: "Kernel Clock",
            targets: ["Kernel Clock"]
        ),
        .library(
            name: "Kernel Terminal",
            targets: ["Kernel Terminal"]
        ),

        .library(
            name: "Kernel",
            targets: ["Kernel"]
        ),

        .library(
            name: "Kernel Test Support",
            targets: ["Kernel Test Support"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-clock.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-system.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-binary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-time.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dimension.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-queue.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-reference.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ownership.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-error.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-random.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-path.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-string.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-dictionary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-hash-table.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-hash.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-buffer-linear.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-storage.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-heap.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-memory-allocation.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-terminal.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-compositions/swift-cpu.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-posix.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-darwin.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-linux.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-windows.git", branch: "main"),
        .package(url: "https://github.com/swift-compositions/swift-strings.git", branch: "main"),
    ],
    targets: [

        .target(
            name: "Kernel Core",
            dependencies: [
                .product(name: "Binary", package: "swift-binary"),
                .product(name: "CPU", package: "swift-cpu"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "ASCII", package: "swift-ascii"),
                .product(name: "Clock", package: "swift-clock"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Random", package: "swift-random"),
                .product(name: "System", package: "swift-system"),
                .product(name: "Path", package: "swift-path"),
                .product(name: "Reference", package: "swift-reference"),
                .product(name: "Ownership", package: "swift-ownership"),
                .product(name: "Dimension", package: "swift-dimension"),
                .product(name: "Queue", package: "swift-queue"),
                .product(
                    name: "POSIX Kernel",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(
                    name: "Darwin Kernel",
                    package: "swift-darwin",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS])
                ),
                .product(
                    name: "Darwin System",
                    package: "swift-darwin",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS])
                ),
                .product(
                    name: "Linux Kernel",
                    package: "swift-linux",
                    condition: .when(platforms: [.linux])
                ),
                .product(
                    name: "Linux System",
                    package: "swift-linux",
                    condition: .when(platforms: [.linux])
                ),
                .product(
                    name: "Windows Kernel",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
                .product(
                    name: "Windows Kernel Clock",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
                .product(
                    name: "Windows Kernel Process",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
            ]
        ),

        .target(
            name: "Kernel System",
            dependencies: ["Kernel Core"]
        ),

        .target(
            name: "Kernel Thread",
            dependencies: [
                "Kernel Core",
                "Kernel System",
                .product(name: "Error", package: "swift-error"),
                .product(
                    name: "Windows Kernel Thread",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
            ]
        ),

        .target(
            name: "Kernel File",
            dependencies: [
                "Kernel Core",
                .product(name: "String", package: "swift-string"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "Memory", package: "swift-memory"),
                .product(name: "Path", package: "swift-path"),
                .product(
                    name: "Windows Kernel File",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
            ]
        ),

        .target(
            name: "Kernel Event",
            dependencies: [
                "Kernel Core",
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Dictionary", package: "swift-dictionary"),
                .product(name: "Hash Indexed Primitive", package: "swift-hash-table"),
                .product(name: "Hash Tagged", package: "swift-hash"),
                .product(name: "Buffer Primitive", package: "swift-buffer"),
                .product(
                    name: "Buffer Linear Primitive",
                    package: "swift-buffer-linear"
                ),
                .product(
                    name: "Buffer Linear",
                    package: "swift-buffer-linear"
                ),
                .product(name: "Storage Primitive", package: "swift-storage"),
                .product(
                    name: "Storage Contiguous",
                    package: "swift-storage"
                ),
                .product(name: "Memory Heap", package: "swift-memory-heap"),
                .product(
                    name: "Memory Allocator Primitive",
                    package: "swift-memory-allocation"
                ),
                .product(
                    name: "POSIX Kernel Descriptor",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(
                    name: "Linux Kernel Event",
                    package: "swift-linux",
                    condition: .when(platforms: [.linux])
                ),
            ]
        ),

        .target(
            name: "Kernel Completion",
            dependencies: [
                "Kernel Core",

                "Kernel Event",
                .product(
                    name: "Linux Kernel IO Uring",
                    package: "swift-linux",
                    condition: .when(platforms: [.linux])
                ),
                .product(
                    name: "Windows Kernel File",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
            ]
        ),

        .target(
            name: "Kernel Clock",
            dependencies: [
                .product(name: "Clock", package: "swift-clock"),
                .product(
                    name: "POSIX Kernel Clock",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(
                    name: "Windows Kernel Clock",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
            ]
        ),

        .target(
            name: "Kernel Terminal",
            dependencies: [
                "Kernel Core",
                .product(name: "Terminal", package: "swift-terminal"),
                .product(
                    name: "POSIX Kernel Terminal",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
            ]
        ),

        .target(
            name: "Kernel",
            dependencies: [
                "Kernel Core",
                "Kernel System",
                "Kernel Thread",
                "Kernel File",
                "Kernel Event",
                "Kernel Completion",
                "Kernel Clock",
                .product(
                    name: "POSIX Kernel Descriptor",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(
                    name: "POSIX Kernel Directory",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(
                    name: "POSIX Kernel Socket",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(
                    name: "POSIX Kernel Socket Address",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(
                    name: "POSIX Kernel Lock",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
                .product(
                    name: "Windows Kernel Descriptor",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
                .product(
                    name: "Windows Kernel Lock",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
                .product(
                    name: "Windows Kernel Socket",
                    package: "swift-windows",
                    condition: .when(platforms: [.windows])
                ),
            ]
        ),

        .target(
            name: "Kernel Test Support",
            dependencies: [
                "Kernel",
                .product(name: "Strings", package: "swift-strings"),
            ],
            path: "Tests/Support",
            exclude: ["_Lock Test Process"]
        ),

        .executableTarget(
            name: "_Lock Test Process",
            dependencies: [
                "Kernel",
                .product(name: "Binary", package: "swift-binary"),
                .product(
                    name: "POSIX Kernel Descriptor",
                    package: "swift-posix",
                    condition: .when(platforms: [.macOS, .iOS, .tvOS, .watchOS, .visionOS, .linux])
                ),
            ],
            path: "Tests/Support/_Lock Test Process"
        ),
        .testTarget(
            name: "Kernel Tests",
            dependencies: [
                "Kernel",
                "Kernel Core",
                "Kernel Thread",
                "Kernel File",
                "Kernel Event",
                "Kernel Completion",
                "Kernel Test Support",
                .product(
                    name: "Tagged Standard Library Integration",
                    package: "swift-tagged"
                ),
            ],
            path: "Tests/Kernel Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
