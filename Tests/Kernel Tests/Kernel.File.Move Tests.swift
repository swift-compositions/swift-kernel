import Kernel_Test_Support
import Testing

@testable import Kernel

extension Kernel.File.Move {
    @Suite struct Test {
        @Suite struct Unit {}
        @Suite struct `Edge Case` {}
    }
}

#if !os(Windows)

    extension Kernel.File.Move.Test {

        static func create(_ path: Swift.String) throws {
            let descriptor = try Path.scope(path) { path in
                try Kernel.File.Open.open(
                    path: path,
                    mode: .write,
                    options: [.create, .exclusive],
                    permissions: .ownerReadWrite
                )
            }
            try Kernel.Close.close(descriptor)
        }

        static func inode(_ path: Swift.String) throws -> Kernel.Inode {
            try Path.scope(path) { try Kernel.File.Stats.lget(path: $0).inode }
        }

        static func exclusive(
            from source: Swift.String,
            to destination: Swift.String
        ) throws -> Kernel.File.Move.Error? {
            try Path.scope(source, destination) { source, destination in
                do throws(Kernel.File.Move.Error) {
                    try Kernel.File.Move.exclusive(from: source, to: destination)
                    return nil
                } catch {
                    return error
                }
            }
        }

        static func delete(_ path: Swift.String) {
            try? Path.scope(path) { try? Kernel.File.Delete.delete($0) }
        }
    }

    extension Kernel.File.Move.Test.Unit {

        @Test
        func `exclusive renames onto a free destination`() throws {
            let source = Kernel.Temporary.filePath(prefix: "kernel-move-exclusive-src")
            let destination = Kernel.Temporary.filePath(prefix: "kernel-move-exclusive-dst")
            try Kernel.File.Move.Test.create(source)
            defer {
                Kernel.File.Move.Test.delete(source)
                Kernel.File.Move.Test.delete(destination)
            }
            let sourceInode = try Kernel.File.Move.Test.inode(source)

            let error = try Kernel.File.Move.Test.exclusive(from: source, to: destination)

            #expect(error == nil)
            #expect(try Kernel.File.Move.Test.inode(destination) == sourceInode)
            #expect((try? Kernel.File.Move.Test.inode(source)) == nil)
        }

        @Test
        func `exclusive refuses an existing destination and leaves both files in place`() throws {
            let source = Kernel.Temporary.filePath(prefix: "kernel-move-exclusive-src")
            let destination = Kernel.Temporary.filePath(prefix: "kernel-move-exclusive-dst")
            try Kernel.File.Move.Test.create(source)
            try Kernel.File.Move.Test.create(destination)
            defer {
                Kernel.File.Move.Test.delete(source)
                Kernel.File.Move.Test.delete(destination)
            }
            let sourceInode = try Kernel.File.Move.Test.inode(source)
            let destinationInode = try Kernel.File.Move.Test.inode(destination)

            let error = try Kernel.File.Move.Test.exclusive(from: source, to: destination)

            #expect(error == .exists)
            #expect(try Kernel.File.Move.Test.inode(source) == sourceInode)
            #expect(try Kernel.File.Move.Test.inode(destination) == destinationInode)
        }
    }

    extension Kernel.File.Move.Test.`Edge Case` {

        // A dangling symlink is an entry `stat` cannot see, standing in for a
        // file that appears after a check: only an exclusive rename refuses it.
        @Test
        func `exclusive refuses a dangling symlink at the destination`() throws {
            let source = Kernel.Temporary.filePath(prefix: "kernel-move-exclusive-src")
            let destination = Kernel.Temporary.filePath(prefix: "kernel-move-exclusive-dst")
            let missing = Kernel.Temporary.filePath(prefix: "kernel-move-exclusive-missing")
            try Kernel.File.Move.Test.create(source)
            try Path.scope(missing, destination) { missing, destination in
                try Kernel.Link.Symbolic.create(target: missing, at: destination)
            }
            defer {
                Kernel.File.Move.Test.delete(source)
                Kernel.File.Move.Test.delete(destination)
            }
            let sourceInode = try Kernel.File.Move.Test.inode(source)
            let linkInode = try Kernel.File.Move.Test.inode(destination)

            let error = try Kernel.File.Move.Test.exclusive(from: source, to: destination)

            #expect(error == .exists)
            #expect(try Kernel.File.Move.Test.inode(source) == sourceInode)
            #expect(try Kernel.File.Move.Test.inode(destination) == linkInode)
        }
    }

#endif
