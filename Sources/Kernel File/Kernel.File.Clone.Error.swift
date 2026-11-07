public import Error

extension Kernel.File.Clone {

    public enum Error: Swift.Error, Sendable, Equatable, CustomStringConvertible {

        case notSupported

        case crossDevice

        case sourceNotFound

        case destinationExists

        case permissionDenied

        case isDirectory

        case platform(code: Error::Error.Code, operation: Operation)
    }
}

extension Kernel.File.Clone.Error {
    public var description: Swift.String {
        switch self {
        case .notSupported:
            return "Reflink not supported on this filesystem"

        case .crossDevice:
            return "Source and destination are on different devices"

        case .sourceNotFound:
            return "Source file not found"

        case .destinationExists:
            return "Destination already exists"

        case .permissionDenied:
            return "Permission denied"

        case .isDirectory:
            return "Source is a directory"

        case .platform(let code, let operation):
            return "Platform error \(code) during \(operation)"
        }
    }
}

extension Kernel.File.Clone.Error {

    public init(from syscall: Syscall) {
        switch syscall {
        case .notSupported:
            self = .notSupported

        case .platform(let code, let operation):
            self.init(code: code, operation: operation)
        }
    }

    public init(code: Error::Error.Code, operation: Operation) {
        #if os(Windows)
            self = .platform(code: code, operation: operation)
        #else
            switch code {
            case _ where code == .ENOENT:
                self = .sourceNotFound

            case _ where code == .EEXIST:
                self = .destinationExists

            case _ where code == .EACCES,
                _ where code == .EPERM:
                self = .permissionDenied

            case _ where code == .EXDEV:
                self = .crossDevice

            case _ where code == .EISDIR:
                self = .isDirectory

            case _ where code == .ENOTSUP:
                self = .notSupported

            default:
                self = .platform(code: code, operation: operation)
            }
        #endif
    }
}
