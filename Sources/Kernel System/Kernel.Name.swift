#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)
    public import POSIX_Kernel_System

    extension Kernel {

        /// The running system's identification: `uname()` on POSIX systems.
        public typealias Name = ISO_9945.Kernel.Name
    }
#elseif os(Windows)
    public import Windows_32_Kernel_System

    extension Kernel {

        /// The running system's identification: the registry's version and `GetNativeSystemInfo`.
        public typealias Name = Windows.`32`.Kernel.Name
    }
#endif
