#if canImport(Foundation) && !os(Windows)
    import Foundation

    extension `Kernel.Lock Integration` {

        static let helperName = "_Lock Test Process"

        static var helperPath: Swift.String {
            let fileManager = FileManager.default
            for directory in productDirectories {
                let candidate = directory.appendingPathComponent(helperName)
                if fileManager.isExecutableFile(atPath: candidate.path) { return candidate.path }
            }
            return packageRoot.appendingPathComponent(helperName).path
        }

        static var packageRoot: URL {
            URL(fileURLWithPath: #filePath)
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent()
        }

        static var productDirectories: [URL] {
            var directories: [URL] = []
            if let builtProductsDirectory = ProcessInfo.processInfo.environment[
                "BUILT_PRODUCTS_DIR"
            ] {
                directories.append(URL(fileURLWithPath: builtProductsDirectory))
            }
            let buildRoot = packageRoot.appendingPathComponent(".build")
            for configuration in ["Debug", "Release"] {
                directories.append(
                    buildRoot
                        .appendingPathComponent("out")
                        .appendingPathComponent("Products")
                        .appendingPathComponent(configuration)
                )
            }
            for configuration in ["debug", "release"] {
                directories.append(buildRoot.appendingPathComponent(configuration))
            }
            let contents =
                (try? FileManager.default.contentsOfDirectory(
                    at: buildRoot,
                    includingPropertiesForKeys: nil
                )) ?? []
            for triple in contents {
                for configuration in ["debug", "release"] {
                    directories.append(triple.appendingPathComponent(configuration))
                }
            }
            return directories
        }

        static func runHelper(_ arguments: [Swift.String]) throws -> (status: Int32, output: Swift.String) {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: helperPath)
            process.arguments = arguments
            let pipe = Pipe()
            process.standardOutput = pipe
            try process.run()
            process.waitUntilExit()
            let outputData = pipe.fileHandleForReading.readDataToEndOfFile()
            return (process.terminationStatus, Swift.String(data: outputData, encoding: .utf8) ?? "")
        }
    }
#endif
