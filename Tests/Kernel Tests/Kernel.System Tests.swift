import Kernel_Test_Support
import Testing

@testable import Kernel

enum SystemMemoryTests {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)

    extension SystemMemoryTests.Test.Unit {
        @Test func `total memory is positive`() {
            let total = System.memoryCapacity
            let bytes = UInt64(total.rawValue)
            #expect(bytes > 0)
        }

        @Test func `total memory exceeds minimum threshold`() {
            let total = System.memoryCapacity
            let bytes = UInt64(total.rawValue)
            let sixtyFourMB: UInt64 = 64 * 1024 * 1024
            #expect(bytes >= sixtyFourMB)
        }

        @Test func `total memory is within reasonable upper bound`() {
            let total = System.memoryCapacity
            let bytes = UInt64(total.rawValue)
            let oneHundredTwentyEightTB: UInt64 = 128 * 1024 * 1024 * 1024 * 1024
            #expect(bytes <= oneHundredTwentyEightTB)
        }
    }

#endif

enum SystemProcessorTests {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

extension SystemProcessorTests.Test.Unit {
    @Test func `logical processor count is positive`() {
        let count = System.processorCount
        let value = Int(count)
        #expect(value > 0)
    }

    @Test func `logical processor count is within reasonable upper bound`() {
        let count = System.processorCount
        let value = Int(count)
        #expect(value <= 4096)
    }
}

enum SystemPhysicalProcessorTests {
    @Suite struct Test {
        @Suite struct Unit {}
    }
}

extension SystemPhysicalProcessorTests.Test.Unit {
    @Test func `physical processor count is positive`() {
        let count = System.physicalProcessorCount
        let value = Int(count)
        #expect(value > 0)
    }

    @Test func `physical count does not exceed logical count`() {
        let physical = Int(System.physicalProcessorCount)
        let logical = Int(System.processorCount)
        #expect(physical <= logical)
    }

    @Test func `physical processor count is within reasonable upper bound`() {
        let count = System.physicalProcessorCount
        let value = Int(count)
        #expect(value <= 4096)
    }
}
