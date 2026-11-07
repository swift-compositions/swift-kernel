public import Error

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
