import Kernel_Test_Support
import Tagged
import Testing

@testable import Kernel


@Suite
struct `Kernel.Lock Integration` {}

private func createLockFile(prefix: Swift.String) throws -> Swift.String {
    let pathString = Kernel.Temporary.filePath(prefix: prefix)
    try Path.scope(pathString) { path in
        let fd = try Kernel.File.Open.open(
            path: path,
            mode: .readWrite,
            options: [.create, .truncate],
            permissions: .ownerReadWrite
        )
        let data = [UInt8](repeating: 0x78, count: 1024)
        _ = try data.withUnsafeBytes { buffer in
            try Kernel.IO.Write.write(fd, from: buffer)
        }

    }
    return pathString
}

private func openForLock(_ pathString: Swift.String) throws -> Kernel.Descriptor {
    try Path.scope(pathString) { path in
        try Kernel.File.Open.open(
            path: path,
            mode: .readWrite,
            options: [],
            permissions: .ownerReadWrite
        )
    }
}

private func cleanupLockFile(_ pathString: Swift.String) {
    try? Path.scope(pathString) { path in
        try Kernel.File.Delete.delete(path)
    }
}

extension `Kernel.Lock Integration` {
    @Test
    func `token acquires and releases lock`() throws {
        let path = try createLockFile(prefix: "kernel-lock-token")
        defer { cleanupLockFile(path) }

        let fd = try openForLock(path)
        var token = try Kernel.Lock.Token(
            descriptor: fd,
            range: .file,
            kind: .exclusive,
            acquire: .wait
        )
        try token.release()
    }

    @Test
    func `try lock returns immediately when uncontested`() throws {
        let path = try createLockFile(prefix: "kernel-lock-try")
        defer { cleanupLockFile(path) }

        let fd = try openForLock(path)
        var token = try Kernel.Lock.Token(
            descriptor: fd,
            range: .file,
            kind: .exclusive,
            acquire: .try
        )
        try token.release()
    }
}

#if canImport(Foundation) && !os(Windows)

    extension `Kernel.Lock Integration` {

        @Test
        func `exclusive lock blocks try-exclusive from another process`() throws {
            let path = try createLockFile(prefix: "kernel-contention")
            defer { cleanupLockFile(path) }

            let fd = try openForLock(path)
            var token = try Kernel.Lock.Token(
                descriptor: fd,
                range: .file,
                kind: .exclusive,
                acquire: .wait
            )

            let (status, output) = try Self.runHelper(["try-exclusive", path, "--signal-ready"])

            #expect(status == 1, "Helper should exit with 1 (would block)")
            #expect(output.contains("WOULD_BLOCK"), "Helper should report WOULD_BLOCK")

            try token.release()
        }

        @Test
        func `exclusive lock blocks try-shared from another process`() throws {
            let path = try createLockFile(prefix: "kernel-contention")
            defer { cleanupLockFile(path) }

            let fd = try openForLock(path)
            var token = try Kernel.Lock.Token(
                descriptor: fd,
                range: .file,
                kind: .exclusive,
                acquire: .wait
            )

            let (status, output) = try Self.runHelper(["try-shared", path])

            #expect(status == 1, "Helper should exit with 1 (would block)")
            #expect(output.contains("WOULD_BLOCK"), "Helper should report WOULD_BLOCK")

            try token.release()
        }

        @Test
        func `shared lock allows try-shared from another process`() throws {
            let path = try createLockFile(prefix: "kernel-contention")
            defer { cleanupLockFile(path) }

            let fd = try openForLock(path)
            var token = try Kernel.Lock.Token(
                descriptor: fd,
                range: .file,
                kind: .shared,
                acquire: .wait
            )

            let (status, output) = try Self.runHelper(["try-shared", path, "--hold", "0", "--signal-ready"])

            #expect(status == 0, "Helper should exit with 0 (success)")
            #expect(output.contains("READY"), "Helper should report READY")
            #expect(output.contains("RELEASED"), "Helper should report RELEASED")

            try token.release()
        }

        @Test
        func `shared lock blocks try-exclusive from another process`() throws {
            let path = try createLockFile(prefix: "kernel-contention")
            defer { cleanupLockFile(path) }

            let fd = try openForLock(path)
            var token = try Kernel.Lock.Token(
                descriptor: fd,
                range: .file,
                kind: .shared,
                acquire: .wait
            )

            let (status, output) = try Self.runHelper(["try-exclusive", path])

            #expect(status == 1, "Helper should exit with 1 (would block)")
            #expect(output.contains("WOULD_BLOCK"), "Helper should report WOULD_BLOCK")

            try token.release()
        }

        @Test
        func `non-overlapping byte ranges do not conflict`() throws {
            let path = try createLockFile(prefix: "kernel-contention")
            defer { cleanupLockFile(path) }

            let fd = try openForLock(path)
            var token = try Kernel.Lock.Token(
                descriptor: fd,
                range: .bytes(start: Kernel.File.Offset(0), end: Kernel.File.Offset(100)),
                kind: .exclusive,
                acquire: .wait
            )

            let (status, output) = try Self.runHelper([
                "try-exclusive", path, "--range", "200-300", "--hold", "0", "--signal-ready",
            ])

            #expect(status == 0, "Helper should exit with 0 (success)")
            #expect(output.contains("READY"), "Helper should report READY")

            try token.release()
        }

        @Test
        func `overlapping byte ranges conflict`() throws {
            let path = try createLockFile(prefix: "kernel-contention")
            defer { cleanupLockFile(path) }

            let fd = try openForLock(path)
            var token = try Kernel.Lock.Token(
                descriptor: fd,
                range: .bytes(start: Kernel.File.Offset(0), end: Kernel.File.Offset(200)),
                kind: .exclusive,
                acquire: .wait
            )

            let (status, output) = try Self.runHelper(["try-exclusive", path, "--range", "100-300"])

            #expect(status == 1, "Helper should exit with 1 (would block)")
            #expect(output.contains("WOULD_BLOCK"), "Helper should report WOULD_BLOCK")

            try token.release()
        }
    }
#endif
