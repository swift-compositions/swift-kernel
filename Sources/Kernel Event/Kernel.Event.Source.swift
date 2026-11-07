#if !os(Windows)
    extension Kernel.Event {

        public struct Source: ~Copyable {
            package let driver: Kernel.Event.Driver

            public let wakeup: Kernel.Wakeup.Channel

            public init(driver: consuming Kernel.Event.Driver, wakeup: Kernel.Wakeup.Channel) {
                self.driver = driver
                self.wakeup = wakeup
            }
        }
    }

    extension Kernel.Event.Source {
        public func register(
            descriptor: consuming Kernel.Descriptor,
            interest: Kernel.Event.Interest
        ) throws(Kernel.Event.Driver.Error) -> Kernel.Event.ID {
            try driver._register(descriptor, interest)
        }

        public func modify(
            id: Kernel.Event.ID,
            interest: Kernel.Event.Interest
        ) throws(Kernel.Event.Driver.Error) {
            try driver._modify(id, interest)
        }

        public func deregister(
            id: Kernel.Event.ID
        ) throws(Kernel.Event.Driver.Error) {
            try driver._deregister(id)
        }

        public func arm(
            id: Kernel.Event.ID,
            interest: Kernel.Event.Interest
        ) throws(Kernel.Event.Driver.Error) {
            try driver._arm(id, interest)
        }

        public func poll(
            deadline: Clock.Continuous.Deadline?,
            into buffer: inout [Kernel.Event]
        ) throws(Kernel.Event.Driver.Error) -> Int {
            try driver._poll(deadline, &buffer)
        }

        public consuming func close() {
            driver._close()
        }
    }
#endif

#if !os(Windows)
    extension Kernel.Event.Source {

        public static func platform() throws(Kernel.Event.Driver.Error) -> Kernel.Event.Source {
            #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
                try .kqueue()
            #elseif os(Linux)
                try .epoll()
            #else

                throw .unsupportedPlatform
            #endif
        }
    }
#endif
