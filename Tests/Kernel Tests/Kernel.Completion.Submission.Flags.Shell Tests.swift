import Testing

@testable import Kernel_Completion

enum `Kernel.Completion.Submission.Flags Tests` {}

extension `Kernel.Completion.Submission.Flags Tests` {
    @Suite
    struct `Shell Test` {
        @Suite struct Unit {}
    }
}

extension `Kernel.Completion.Submission.Flags Tests`.`Shell Test`.Unit {
    @Test
    func `empty flags has zero rawValue`() {
        let flags: Kernel.Completion.Submission.Flags = []
        #expect(flags.rawValue == 0)
    }

    @Test
    func `roundtrip through rawValue`() {
        let flags = Kernel.Completion.Submission.Flags(rawValue: 0b1010)
        #expect(flags.rawValue == 0b1010)
    }

    @Test
    func `flags is sendable`() {
        let flags: Kernel.Completion.Submission.Flags = []
        let _: any Sendable = flags
    }
}
