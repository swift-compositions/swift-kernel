extension Kernel.Completion.Event.Result {

    public var failure: Error.Error? {
        guard !isSuccess else { return nil }
        return Error.Error(code: .posix(-rawValue))
    }
}
