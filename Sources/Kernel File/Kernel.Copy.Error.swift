public import Error

extension Kernel.Copy {

    public enum Error: Swift.Error, Sendable, Equatable, Hashable {

        case invalidDescriptor

        case crossDevice

        case unsupported

        case noSpace

        case io

        case permissionDenied

        case exists

        case notFound

        case platform(code: Error::Error.Code)
    }
}

extension Kernel.Copy.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalidDescriptor: return "invalid file descriptor"
        case .crossDevice: return "cross-device copy not supported"
        case .unsupported: return "operation not supported"
        case .noSpace: return "no space left on device"
        case .io: return "I/O error"
        case .permissionDenied: return "permission denied"
        case .exists: return "destination already exists"
        case .notFound: return "source not found"
        case .platform(let code): return "platform error \(code)"
        }
    }
}

#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)

    extension Kernel.Copy.Error {

        public init(posixErrno: Int32) {
            switch Error::Error.Code.posix(posixErrno) {
            case .EBADF:
                self = .invalidDescriptor

            case .EXDEV:
                self = .crossDevice

            case .ENOSPC:
                self = .noSpace

            case .EIO:
                self = .io

            case .EACCES, .EPERM:
                self = .permissionDenied

            case .ENOENT:
                self = .notFound

            case .EEXIST:
                self = .exists

            case .EINVAL, .ENOTSUP, .EOPNOTSUPP, .ENOSYS:
                self = .unsupported

            default:
                self = .platform(code: .posix(posixErrno))
            }
        }
    }

#endif
