@_exported public import Kernel_Clock
@_exported public import Kernel_Completion
@_exported public import Kernel_Core
@_exported public import Kernel_Event
@_exported public import Kernel_File
@_exported public import Kernel_System
@_exported public import Kernel_Thread

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS) || os(Linux)

    @_exported public import POSIX_Kernel_Socket_Address

#endif

#if canImport(Darwin) || canImport(Glibc) || canImport(Musl)
    @_exported public import POSIX_Kernel_Lock
#elseif os(Windows)
    @_exported public import Windows_Kernel_Lock
#endif
