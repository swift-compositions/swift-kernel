extension Kernel.Completion {

    public enum Error: Swift.Error, Sendable, Equatable {

        case platform(Error.Error.Code)

        case submissionQueueFull

        case invalidDescriptor

        case unsupportedPlatform
    }
}
