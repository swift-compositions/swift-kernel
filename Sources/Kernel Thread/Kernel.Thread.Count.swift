extension Kernel.Thread {

    public typealias Count = Tagged<Kernel.Thread, Cardinal>
}

extension Kernel.Thread.Count {

    @inlinable
    public init(_ processorCount: Int) {
        guard let count = UInt(exactly: processorCount) else {
            preconditionFailure("Thread count must be nonnegative")
        }
        self.init(_unchecked: Cardinal(count))
    }
}

extension Int {

    @inlinable
    public init(_ count: Kernel.Thread.Count) {
        guard let value = Int(exactly: count.underlying.rawValue) else {
            preconditionFailure("Thread count is not representable as Int")
        }
        self = value
    }
}
