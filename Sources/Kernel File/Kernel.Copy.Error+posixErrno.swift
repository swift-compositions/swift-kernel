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
