extension Kernel.File.Direct {

    public enum Mode: Sendable, Equatable {

        case direct

        case uncached

        case buffered

        case auto(policy: Policy)
    }
}

extension Kernel.File.Direct.Mode {

    public func resolve(
        given requirements: Kernel.File.Direct.Requirements
    ) throws(Kernel.File.Direct.Error) -> Resolved {
        #if canImport(Darwin)
            return try resolveDarwin()
        #else
            return try resolveLinuxWindows(requirements: requirements)
        #endif
    }

    #if canImport(Darwin)

        private func resolveDarwin() throws(Kernel.File.Direct.Error) -> Resolved {
            switch self {
            case .direct:

                throw .notSupported

            case .uncached:
                return .uncached

            case .buffered:
                return .buffered

            case .auto:

                return .uncached
            }
        }
    #endif

    #if !canImport(Darwin)

        private func resolveLinuxWindows(
            requirements: Kernel.File.Direct.Requirements
        ) throws(Kernel.File.Direct.Error) -> Resolved {
            switch self {
            case .direct:

                guard case .known = requirements else {
                    throw .notSupported
                }
                return .direct

            case .uncached:

                throw .notSupported

            case .buffered:
                return .buffered

            case .auto(let policy):
                return try resolveAutoLinuxWindows(policy: policy, requirements: requirements)
            }
        }

        private func resolveAutoLinuxWindows(
            policy: Policy,
            requirements: Kernel.File.Direct.Requirements
        ) throws(Kernel.File.Direct.Error) -> Resolved {
            switch requirements {
            case .known:

                return .direct

            case .unknown:

                switch policy {
                case .fallbackToBuffered:
                    return .buffered

                case .errorOnViolation:
                    throw .notSupported
                }
            }
        }
    #endif
}
