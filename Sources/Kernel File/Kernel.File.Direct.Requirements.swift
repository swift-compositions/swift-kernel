public import Path

extension Kernel.File.Direct {

    public enum Requirements: Sendable, Equatable {

        case known(Alignment)

        case unknown(reason: Reason)
    }
}

extension Kernel.File.Direct.Requirements {

    public init(_ path: borrowing Path.Borrowed) {
        self = .platformDefault
    }

    internal static var platformDefault: Self {
        #if canImport(Darwin)
            .unknown(reason: .platformUnsupported)
        #elseif os(Linux)
            .unknown(reason: .sectorSizeUndetermined)
        #elseif os(Windows)
            .known(Alignment(uniform: .`4096`))
        #else
            .unknown(reason: .platformUnsupported)
        #endif
    }
}
