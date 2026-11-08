import Kernel_Test_Support
import Testing

@testable import Kernel

private enum SystemMemoryTests {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux) || os(Windows)

    extension SystemMemoryTests.Test.Unit {
        @Test func `installed memory exceeds 64 MiB`() {
            #expect(Int(Memory.Physical.capacity) >= 64 * 1024 * 1024)
        }

        @Test func `installed memory is within 128 TiB`() {
            #expect(UInt64(Int(Memory.Physical.capacity)) <= 128 * 1024 * 1024 * 1024 * 1024)
        }

        @Test func `page size is a power of two`() {
            let size = Int(Memory.Page.size)
            #expect(size >= 4096)
            #expect(size & (size - 1) == 0)
        }
    }

#endif

private enum SystemProcessorTests {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

extension SystemProcessorTests.Test.Unit {
    @Test func `logical count is between 1 and 4096`() {
        let value = Int(CPU.Logical.count)
        #expect(value > 0)
        #expect(value <= 4096)
    }

    @Test func `core count is between 1 and the logical count`() {
        let cores = Int(CPU.Core.count)
        #expect(cores > 0)
        #expect(cores <= Int(CPU.Logical.count))
    }

    @Test func `NUMA nodes each hold processors`() {
        if case .nonUniform(let nodes) = CPU.NUMA.state {
            for node in nodes {
                #expect(!node.processors.isEmpty)
            }
        }
    }
}

private enum SystemNameTests {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

extension SystemNameTests.Test.Unit {
    @Test func `name reports a system, release and machine`() throws {
        let name = try #require(Kernel.Name.current)
        #expect(!name.system.isEmpty)
        #expect(!name.release.isEmpty)
        #expect(!name.machine.isEmpty)
    }

    @Test func `thread sleep returns`() {
        Kernel.Thread.sleep(.milliseconds(1))
    }
}
