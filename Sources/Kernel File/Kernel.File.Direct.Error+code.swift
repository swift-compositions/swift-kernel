public import Error

extension Kernel.File.Direct.Error {

    public init(from syscall: Syscall) {
        switch syscall {
        case .invalidDescriptor:
            self = .invalidHandle

        case .alignmentViolation(let operation):
            #if os(Windows)
                self = .platform(code: .win32(87), operation: operation)
            #else
                self = .platform(code: .POSIX.EINVAL, operation: operation)
            #endif

        case .notSupported:
            self = .notSupported

        case .platform(let code, let operation):
            self.init(code: code, operation: operation)
        }
    }

    @usableFromInline
    internal init(code: Error::Error.Code, operation: Operation) {
        #if os(Windows)
            self = .platform(code: code, operation: operation)
        #else
            switch code {
            case _ where code == .POSIX.EBADF:
                self = .invalidHandle

            case _ where Error::Error.Code.POSIX.isENOTSUP(code):
                self = .notSupported

            default:
                self = .platform(code: code, operation: operation)
            }
        #endif
    }
}
