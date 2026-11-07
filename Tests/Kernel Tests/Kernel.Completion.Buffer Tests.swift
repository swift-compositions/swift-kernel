import Tagged
import Testing

@testable import Kernel_Completion

enum `Kernel.Completion.Buffer Tests` {}

extension `Kernel.Completion.Buffer Tests` {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension `Kernel.Completion.Buffer Tests`.Test.Unit {
    @Test
    func `buffer namespace exists`() {
        _ = Kernel.Completion.Buffer.self
    }
}

extension `Kernel.Completion.Buffer Tests` {
    @Suite
    struct `Completion Buffer Group Tests` {
        @Suite struct Unit {}
    }
}

extension `Kernel.Completion.Buffer Tests`.`Completion Buffer Group Tests`.Unit {
    @Test
    func `none group`() {
        let group = Kernel.Completion.Buffer.Group.none
        #expect(group == 0)
    }

    @Test
    func `init from identifier`() {
        let group = Kernel.Completion.Buffer.Group(7)
        #expect(group == 7)
    }

    @Test
    func `groups are equatable`() {
        let a = Kernel.Completion.Buffer.Group(1)
        let b = Kernel.Completion.Buffer.Group(1)
        let c = Kernel.Completion.Buffer.Group(2)
        #expect(a == b)
        #expect(a != c)
    }
}
