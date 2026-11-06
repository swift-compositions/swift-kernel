import Testing

@testable import Kernel_Completion

enum `Kernel.Completion Tests` {}

extension `Kernel.Completion Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension `Kernel.Completion Tests`.Test.Unit {
    @Test
    func `completion namespace exists`() {
        _ = Kernel.Completion.self
    }

    @Test
    func `token typealias exists`() {
        let _: Kernel.Completion.Token.Type = Kernel.Completion.Token.self
    }

    @Test
    func `submission typealias count exists`() {
        let _: Kernel.Completion.Submission.Count.Type = Kernel.Completion.Submission.Count.self
    }

    @Test
    func `event count typealias exists`() {
        let _: Kernel.Completion.Event.Count.Type = Kernel.Completion.Event.Count.self
    }
}
