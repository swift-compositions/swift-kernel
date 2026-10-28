import Kernel_Test_Support
import Testing

@testable import Kernel

#if !os(Windows)
    extension Kernel.Event.Source {
        @Suite struct Test {
            @Suite struct Unit {}
            @Suite(
                .disabled(
                    if: Toolchain.hasTaggedMetadataSIGSEGV,

                )
            )
            struct Integration {}
        }
    }
#endif

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    extension Kernel.Event.Source.Test.Integration {
        @Test func `platform creates kqueue source`() throws {
            let source = try Kernel.Event.Source.platform()
            _ = source
        }

        @Test func `kqueue factory creates valid source`() throws {
            let source = try Kernel.Event.Source.kqueue()
            _ = source
        }

        @Test func `kqueue factory accepts custom max events`() throws {
            let source = try Kernel.Event.Source.kqueue(maxEvents: 64)
            _ = source
        }

        @Test func `poll with output buffer smaller than ready registrations does not drop events`()
            throws
        {
            let pipeA = try Kernel.Event.Test.makePipe()
            let pipeB = try Kernel.Event.Test.makePipe()

            let source = try Kernel.Event.Source.kqueue()

            let readA = try Kernel.Descriptor.Duplicate.duplicate(pipeA.read)
            let readB = try Kernel.Descriptor.Duplicate.duplicate(pipeB.read)

            let idA = try source.register(descriptor: readA, interest: .read)
            let idB = try source.register(descriptor: readB, interest: .read)
            try source.arm(id: idA, interest: .read)
            try source.arm(id: idB, interest: .read)

            Kernel.Event.Test.writeByte(pipeA.write)
            Kernel.Event.Test.writeByte(pipeB.write)

            let deadline = Clock.Continuous.Deadline.after(.seconds(2), from: Clock.Continuous.now)

            var first = [Kernel.Event](repeating: .empty, count: 1)
            let firstCount = try source.poll(deadline: deadline, into: &first)
            #expect(firstCount == 1)

            var second = [Kernel.Event](repeating: .empty, count: 1)
            let secondCount = try source.poll(deadline: deadline, into: &second)
            #expect(secondCount == 1)

            let delivered: Swift.Set<Kernel.Event.ID> = [first[0].id, second[0].id]
            #expect(delivered == [idA, idB])

            source.close()
        }
    }

    extension Kernel.Event.Source.Test.Integration {
        @Test func `vnode interest reports a change when a file appears in a watched directory`()
            throws
        {
            let directory = Kernel.Temporary.filePath(prefix: "vnode")
            try Path.scope(directory) { path in
                try Kernel.Directory.Create.create(path)
                defer { try? Kernel.Directory.Remove.remove(path) }

                let watched = try Kernel.File.Open.open(
                    path: path,
                    mode: .read,
                    options: [.eventOnly, .execClose],
                    permissions: Kernel.File.Permissions(rawValue: 0)
                )
                let source = try Kernel.Event.Source.kqueue()
                let id = try source.register(descriptor: watched, interest: [.change, .delete])
                try source.arm(id: id, interest: [.change, .delete])

                try Path.scope(directory + "/new") { file in
                    let created = try Kernel.File.Open.open(
                        path: file,
                        mode: .write,
                        options: [.create],
                        permissions: .ownerReadWrite
                    )
                    Kernel.Event.Test.closeNoThrow(created)

                    let deadline = Clock.Continuous.Deadline.after(.seconds(2), from: Clock.Continuous.now)
                    var events = [Kernel.Event](repeating: .empty, count: 4)
                    let count = try source.poll(deadline: deadline, into: &events)

                    #expect(count == 1)
                    #expect(events[0].id == id)
                    #expect(events[0].interest == .change)

                    try Kernel.File.Delete.delete(file)
                }

                source.close()
            }
        }

        @Test func `vnode interest reports the deletion of the watched directory`() throws {
            let directory = Kernel.Temporary.filePath(prefix: "vnode")
            try Path.scope(directory) { path in
                try Kernel.Directory.Create.create(path)

                let watched = try Kernel.File.Open.open(
                    path: path,
                    mode: .read,
                    options: [.eventOnly, .execClose],
                    permissions: Kernel.File.Permissions(rawValue: 0)
                )
                let source = try Kernel.Event.Source.kqueue()
                let id = try source.register(descriptor: watched, interest: [.change])
                try source.modify(id: id, interest: [.change, .rename, .delete])
                try source.arm(id: id, interest: [.change, .rename, .delete])

                try Kernel.Directory.Remove.remove(path)

                let deadline = Clock.Continuous.Deadline.after(.seconds(2), from: Clock.Continuous.now)
                var events = [Kernel.Event](repeating: .empty, count: 4)
                let count = try source.poll(deadline: deadline, into: &events)

                #expect(count == 1)
                #expect(events[0].id == id)
                #expect(events[0].interest.contains(.delete))

                source.close()
            }
        }

        @Test func `vnode interests describe themselves`() {
            #expect(Kernel.Event.Interest.vnode.description == "change|attributes|rename|delete|revoke")
            #expect(Kernel.Event.Interest([.read, .change]).description == "read|change")
        }
    }

#elseif os(Linux)

    extension Kernel.Event.Source.Test.Integration {
        @Test func `platform creates epoll source`() throws {
            let source = try Kernel.Event.Source.platform()
            _ = source
        }

        @Test func `epoll factory creates valid source`() throws {
            let source = try Kernel.Event.Source.epoll()
            _ = source
        }

        @Test func `epoll factory accepts custom max events`() throws {
            let source = try Kernel.Event.Source.epoll(maxEvents: 64)
            _ = source
        }

        @Test func `poll with output buffer smaller than ready registrations does not drop events`()
            throws
        {
            let pipeA = try Kernel.Event.Test.makePipe()
            let pipeB = try Kernel.Event.Test.makePipe()

            let source = try Kernel.Event.Source.epoll()

            let readA = try Kernel.Descriptor.Duplicate.duplicate(pipeA.read)
            let readB = try Kernel.Descriptor.Duplicate.duplicate(pipeB.read)

            let idA = try source.register(descriptor: readA, interest: .read)
            let idB = try source.register(descriptor: readB, interest: .read)
            try source.arm(id: idA, interest: .read)
            try source.arm(id: idB, interest: .read)

            Kernel.Event.Test.writeByte(pipeA.write)
            Kernel.Event.Test.writeByte(pipeB.write)

            let deadline = Clock.Continuous.Deadline.after(.seconds(2), from: Clock.Continuous.now)

            var first = [Kernel.Event](repeating: .empty, count: 1)
            let firstCount = try source.poll(deadline: deadline, into: &first)
            #expect(firstCount == 1)

            var second = [Kernel.Event](repeating: .empty, count: 1)
            let secondCount = try source.poll(deadline: deadline, into: &second)
            #expect(secondCount == 1)

            let delivered: Swift.Set<Kernel.Event.ID> = [first[0].id, second[0].id]
            #expect(delivered == [idA, idB])

            source.close()
        }
    }

#endif
