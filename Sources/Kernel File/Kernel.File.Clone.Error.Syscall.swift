public import Error

extension Kernel.File.Clone.Error {

    public enum Syscall: Swift.Error, Sendable {

        case platform(code: Error.Error.Code, operation: Operation)

        case notSupported(operation: Operation)
    }
}
