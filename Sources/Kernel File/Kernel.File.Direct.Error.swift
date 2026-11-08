public import Error
public import Memory

extension Kernel.File.Direct {

    public enum Error: Swift.Error, Sendable, Equatable {

        case notSupported

        case misalignedBuffer(address: Memory.Address, required: Memory.Alignment)

        case misalignedOffset(offset: Int64, required: Memory.Alignment)

        case invalidLength(length: Int, requiredMultiple: Memory.Alignment)

        case modeChange

        case invalidHandle

        case platform(code: Error::Error.Code, operation: Operation)
    }
}

extension Kernel.File.Direct.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .notSupported:
            return "Direct I/O not supported"

        case .misalignedBuffer(let address, let required):
            return "Buffer address \(address) not aligned to \(required)"

        case .misalignedOffset(let offset, let required):
            return "File offset \(offset) not aligned to \(required) bytes"

        case .invalidLength(let length, let requiredMultiple):
            return "Length \(length) is not a multiple of \(requiredMultiple)"

        case .modeChange:
            return "Failed to change cache mode"

        case .invalidHandle:
            return "Invalid file handle"

        case .platform(let code, let operation):
            return "Platform error \(code) during \(operation)"
        }
    }
}

extension Kernel.File.Direct.Error {

    public init(from syscall: Syscall) {
        switch syscall {
        case .invalidDescriptor:
            self = .invalidHandle

        case .alignmentViolation(let operation):
            #if os(Windows)
                self = .platform(code: .win32(87), operation: operation)
            #else
                self = .platform(code: .EINVAL, operation: operation)
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
            case _ where code == .EBADF:
                self = .invalidHandle

            case _ where code == .ENOTSUP:
                self = .notSupported

            default:
                self = .platform(code: code, operation: operation)
            }
        #endif
    }
}
