#if !os(Windows)

    extension Kernel.File.Copy {

        public enum Error: Swift.Error, Sendable, Equatable {

            case sourceNotFound

            case destinationExists

            case isDirectory

            case permissionDenied

            case clone(Kernel.File.Clone.Error)

            case unlink(Kernel.File.Delete.Error)

            case attributes(Kernel.File.Attributes.Error)

            case times(Kernel.File.Times.Error)

            case mkdir(Kernel.Directory.Create.Error)

            case rmdir(Kernel.Directory.Remove.Error)

            case operation(Swift.String)
        }
    }

    extension Kernel.File.Copy.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .sourceNotFound:
                return "source not found"

            case .destinationExists:
                return "destination already exists"

            case .isDirectory:
                return "is a directory"

            case .permissionDenied:
                return "permission denied"

            case .clone(let e):
                return "clone error: \(e)"

            case .unlink(let e):
                return "unlink error: \(e)"

            case .attributes(let e):
                return "attributes error: \(e)"

            case .times(let e):
                return "times error: \(e)"

            case .mkdir(let e):
                return "mkdir error: \(e)"

            case .rmdir(let e):
                return "rmdir error: \(e)"

            case .operation(let message):
                return "operation failed: \(message)"
            }
        }
    }

    extension Kernel.File.Copy.Error {

        public var isSourceNotFound: Bool {
            if case .sourceNotFound = self { return true }
            return false
        }

        public var isDestinationExists: Bool {
            if case .destinationExists = self { return true }
            return false
        }

        public var isDirectory: Bool {
            if case .isDirectory = self { return true }
            return false
        }

        public var isPermissionDenied: Bool {
            if case .permissionDenied = self { return true }
            return false
        }
    }

#endif
