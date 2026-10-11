#if !os(Windows)

    extension Kernel.File {

        @frozen
        public struct Handle: ~Copyable, Sendable {

            public let descriptor: Kernel.Descriptor

            public let direct: Kernel.File.Direct.Mode.Resolved

            public let requirements: Kernel.File.Direct.Requirements

            public init(
                descriptor: consuming Kernel.Descriptor,
                direct: Kernel.File.Direct.Mode.Resolved,
                requirements: Kernel.File.Direct.Requirements
            ) {
                self.descriptor = descriptor
                self.direct = direct
                self.requirements = requirements
            }
        }
    }

    extension Kernel.File.Handle {

        public typealias Error = ISO_9945.Kernel.File.Handle.Error

        public typealias Operation = ISO_9945.Kernel.File.Handle.Operation

        public init(
            descriptor: consuming Kernel.Descriptor,
            mode direct: Kernel.File.Direct.Mode.Resolved,
            requirements: Kernel.File.Direct.Requirements
        ) {
            self.init(descriptor: descriptor, direct: direct, requirements: requirements)
        }
    }

#endif
