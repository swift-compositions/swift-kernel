#if !os(Windows)
    #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

        import Darwin_Kernel_Event_Standard

        public import POSIX_Kernel_Descriptor

        extension Kernel.Event.Driver.Error {
            init(_ kqueueError: Kernel.Kqueue.Error) {
                switch kqueueError {
                case .create(let code): self = .platform(code)
                case .kevent(let code): self = .platform(code)
                case .interrupted: self = .platform(.EINTR)
                }
            }
        }

        extension Kernel.Event.Source {

            fileprivate static func kevents(
                fd: borrowing Kernel.Descriptor,
                id: Kernel.Event.ID,
                interest: Kernel.Event.Interest,
                flags: Kernel.Kqueue.Flags
            ) -> [Kernel.Kqueue.Event] {
                var events: [Kernel.Kqueue.Event] = []

                if interest.contains(.read) {
                    events.append(
                        Kernel.Kqueue.Event(
                            id: Kernel.Event.ID(descriptor: fd).retag(),
                            filter: .read,
                            flags: flags,
                            data: id.map { UInt64($0) }.retag(Kernel.Kqueue.Event.self)
                        )
                    )
                }
                if interest.contains(.write) {
                    events.append(
                        Kernel.Kqueue.Event(
                            id: Kernel.Event.ID(descriptor: fd).retag(),
                            filter: .write,
                            flags: flags,
                            data: id.map { UInt64($0) }.retag(Kernel.Kqueue.Event.self)
                        )
                    )
                }

                if let notes = Kernel.Kqueue.Filter.Flags(interest.intersection(.vnode)) {
                    events.append(
                        Kernel.Kqueue.Event(
                            id: Kernel.Event.ID(descriptor: fd).retag(),
                            filter: .vnode,
                            flags: flags,
                            fflags: notes,
                            data: id.map { UInt64($0) }.retag(Kernel.Kqueue.Event.self)
                        )
                    )
                }

                return events
            }
        }

        extension Kernel.Kqueue.Filter.Flags {

            /// The vnode notes for an interest, or nil when it names none.
            fileprivate init?(_ interest: Kernel.Event.Interest) {
                var notes: Self = .none
                if interest.contains(.change) { notes = notes | .write | .extend }
                if interest.contains(.attributes) { notes = notes | .attrib | .link }
                if interest.contains(.rename) { notes = notes | .rename }
                if interest.contains(.delete) { notes = notes | .delete }
                if interest.contains(.revoke) { notes = notes | .revoke }
                guard notes != .none else { return nil }
                self = notes
            }
        }

        extension Kernel.Event.Interest {

            /// The vnode interests a fired event's notes report.
            fileprivate init(_ notes: Kernel.Kqueue.Filter.Flags) {
                self = []
                if notes.contains(.write) || notes.contains(.extend) { insert(.change) }
                if notes.contains(.attrib) || notes.contains(.link) { insert(.attributes) }
                if notes.contains(.rename) { insert(.rename) }
                if notes.contains(.delete) { insert(.delete) }
                if notes.contains(.revoke) { insert(.revoke) }
            }
        }

        extension Kernel.Event.Source {

            public static func kqueue(
                maxEvents: Int = 256
            ) throws(Kernel.Event.Driver.Error) -> Kernel.Event.Source {

                final class State {
                    let kq: Kernel.Kqueue
                    var rawEvents: [Kernel.Kqueue.Event]

                    init(kq: consuming Kernel.Kqueue, maxEvents: Int) {
                        self.kq = kq
                        self.rawEvents = [Kernel.Kqueue.Event](
                            repeating: Kernel.Kqueue.Event(id: .init(_unchecked: 0), filter: .read, flags: .none),
                            count: maxEvents
                        )
                    }
                }

                var kq: Kernel.Kqueue
                do throws(Kernel.Kqueue.Error) {
                    kq = try Kernel.Kqueue()
                } catch {
                    throw Kernel.Event.Driver.Error(error)
                }

                let wakeup: Kernel.Wakeup.Channel
                do throws(Kernel.Kqueue.Error) {
                    let signal = try kq.wakeup()
                    wakeup = Kernel.Wakeup.Channel(signal: signal)
                } catch {
                    throw Kernel.Event.Driver.Error(error)
                }

                let state = State(kq: consume kq, maxEvents: maxEvents)

                let addFlags: Kernel.Kqueue.Flags = .add | .clear | .dispatch

                let driver = Kernel.Event.Driver(
                    add: {
                        (
                            fd: borrowing Kernel.Descriptor,
                            id: Kernel.Event.ID,
                            interest: Kernel.Event.Interest
                        ) throws(Kernel.Event.Driver.Error) in

                        let events = kevents(fd: fd, id: id, interest: interest, flags: addFlags)
                        guard !events.isEmpty else { return }
                        do throws(Kernel.Kqueue.Error) {
                            try state.kq.register(events: events)
                        } catch {
                            throw Kernel.Event.Driver.Error(error)
                        }
                    },
                    modify: {
                        (
                            fd: borrowing Kernel.Descriptor,
                            id: Kernel.Event.ID,
                            old: Kernel.Event.Interest,
                            new: Kernel.Event.Interest
                        ) throws(Kernel.Event.Driver.Error) in

                        // Read and write are one filter each; every vnode interest shares the one
                        // vnode filter, so a change to its notes re-adds it with the full new set.
                        var toRemove = old.subtracting(new).subtracting(.vnode)
                        var toAdd = new.subtracting(old).subtracting(.vnode)
                        if old.intersection(.vnode) != new.intersection(.vnode) {
                            if new.isDisjoint(with: .vnode) {
                                toRemove.formUnion(old.intersection(.vnode))
                            } else {
                                toAdd.formUnion(new.intersection(.vnode))
                            }
                        }
                        var events = kevents(fd: fd, id: id, interest: toRemove, flags: .delete)
                        events.append(
                            contentsOf: kevents(fd: fd, id: id, interest: toAdd, flags: addFlags)
                        )
                        guard !events.isEmpty else { return }
                        do throws(Kernel.Kqueue.Error) {
                            try state.kq.register(events: events)
                        } catch {
                            throw Kernel.Event.Driver.Error(error)
                        }
                    },
                    remove: {
                        (
                            fd: borrowing Kernel.Descriptor,
                            id: Kernel.Event.ID,
                            interest: Kernel.Event.Interest
                        ) throws(Kernel.Event.Driver.Error) in

                        let events = kevents(fd: fd, id: id, interest: interest, flags: .delete)
                        guard !events.isEmpty else { return }
                        do throws(Kernel.Kqueue.Error) {
                            try state.kq.register(events: events)
                        } catch {
                            if case .kevent(let code) = error,
                                code == .ENOENT || code == .EBADF
                            {
                                return
                            }
                            throw Kernel.Event.Driver.Error(error)
                        }
                    },
                    arm: {
                        (
                            fd: borrowing Kernel.Descriptor,
                            id: Kernel.Event.ID,
                            interest: Kernel.Event.Interest
                        ) throws(Kernel.Event.Driver.Error) in

                        let armFlags: Kernel.Kqueue.Flags = .add | .enable | .clear | .dispatch
                        let events = kevents(fd: fd, id: id, interest: interest, flags: armFlags)
                        guard !events.isEmpty else { return }
                        do throws(Kernel.Kqueue.Error) {
                            try state.kq.register(events: events)
                        } catch {
                            throw Kernel.Event.Driver.Error(error)
                        }
                    },
                    poll: {
                        (
                            deadline: Clock.Continuous.Deadline?,
                            output: inout [Kernel.Event]
                        ) throws(Kernel.Event.Driver.Error) -> Int in

                        let timeout = deadline.flatMap { $0.remaining(at: Clock.Continuous.now) }

                        let requestCount = min(state.rawEvents.count, output.count)
                        guard requestCount > 0 else { return 0 }

                        let count: Int
                        do throws(Kernel.Kqueue.Error) {
                            if requestCount == state.rawEvents.count {
                                count = try state.kq.poll(into: &state.rawEvents, timeout: timeout)
                            } else {
                                var scratch = Array(state.rawEvents[0..<requestCount])
                                count = try state.kq.poll(into: &scratch, timeout: timeout)
                                state.rawEvents.replaceSubrange(0..<requestCount, with: scratch)
                            }
                        } catch {
                            if case .interrupted = error { return 0 }
                            throw Kernel.Event.Driver.Error(error)
                        }

                        guard count > 0 else { return 0 }

                        var writeIdx = 0
                        for i in 0..<count {
                            let raw = state.rawEvents[i]
                            if raw.filter == .user { continue }

                            let id = raw.data.map { UInt(truncatingIfNeeded: $0) }.retag(
                                Kernel.Event.self
                            )

                            var interest: Kernel.Event.Interest = []
                            if raw.filter == .read { interest.insert(.read) }
                            if raw.filter == .write { interest.insert(.write) }
                            if raw.filter == .vnode { interest.formUnion(Kernel.Event.Interest(raw.fflags)) }

                            var flags: Kernel.Event.Options = []
                            if raw.flags.contains(.eof) {
                                flags.insert(.hangup)
                                if raw.filter == .read {
                                    flags.insert(.readHangup)
                                } else if raw.filter == .write {
                                    flags.insert(.writeHangup)
                                }
                            }
                            if raw.flags.contains(.error) { flags.insert(.error) }

                            guard writeIdx < output.count else { break }
                            output[writeIdx] = Kernel.Event(
                                id: id,
                                interest: interest,
                                flags: flags
                            )
                            writeIdx += 1
                        }
                        return writeIdx
                    },
                    close: {

                    }
                )

                return Kernel.Event.Source(driver: driver, wakeup: wakeup)
            }
        }

    #endif
#endif
