import Kernel
import Kernel_Test_Support
import Testing

enum `Kernel.File.Flush Tests` {}

extension `Kernel.File.Flush Tests` {
    @Suite
    struct Test {
    }
}

extension `Kernel.File.Flush Tests`.Test {
    @Suite struct Flush {}

    @Suite struct `Data` {}

    @Suite struct `Directory` {}
}

#if !os(Windows)

    extension `Kernel.File.Flush Tests`.Test.Flush {
        @Test
        func `flush(_:) on a fresh tmp file succeeds on every platform`() throws {
            try KernelIOTest.withTempFile(prefix: "flush-smoke") { _, fd in

                try Kernel.File.Flush.flush(fd)
            }
        }
    }

#endif

#if !os(Windows)

    extension `Kernel.File.Flush Tests`.Test.Data {
        @Test
        func `data(_:) on a fresh tmp file succeeds on every platform`() throws {
            try KernelIOTest.withTempFile(prefix: "flush-data") { _, fd in

                try Kernel.File.Flush.data(fd)
            }
        }
    }

#endif

extension `Kernel.File.Flush Tests`.Test.Directory {
    @Test
    func `directory(path:) on the system temp directory succeeds (POSIX) / no-ops (Windows)`()
        throws
    {
        let tempDir = Kernel.Temporary.directory
        try Path.scope(tempDir) { dirPath in

            try Kernel.File.Flush.directory(path: dirPath)
        }
    }
}
