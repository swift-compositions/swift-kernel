public import Path

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    internal import Darwin_Kernel_Standard
#elseif os(Linux)
    internal import Linux_Kernel_File_Standard
#endif

#if os(Windows)

    extension Kernel.File.Move {

        /// Renames `oldPath` to `newPath` in one step, refusing with `.exists`
        /// when `newPath` already exists; never replaces the destination.
        public static func exclusive(
            from oldPath: borrowing Path.Borrowed,
            to newPath: borrowing Path.Borrowed
        ) throws(Error) {
            try unsafe oldPath.withUnsafePointer { oldPtr throws(Error) in
                try unsafe newPath.withUnsafePointer { newPtr throws(Error) in
                    try move(from: oldPtr, to: newPtr, replaceExisting: false)
                }
            }
        }
    }

#else

    extension Kernel.File.Move {

        /// Renames `oldPath` to `newPath` in one step, refusing with `.exists`
        /// when `newPath` already exists; never replaces the destination.
        ///
        /// Darwin uses `renamex_np(RENAME_EXCL)`, Linux `renameat2(RENAME_NOREPLACE)`.
        /// A file system that cannot rename exclusively fails with `.notSupported`;
        /// there is no check-then-rename fallback.
        public static func exclusive(
            from oldPath: borrowing Path.Borrowed,
            to newPath: borrowing Path.Borrowed
        ) throws(Error) {
            while true {
                do throws(ISO_9945.Kernel.File.Rename.Error) {
                    #if os(Linux)
                        try ISO_9945.Kernel.File.Rename.noClobber(from: oldPath, to: newPath)
                    #else
                        try ISO_9945.Kernel.File.Move.noClobber(from: oldPath, to: newPath)
                    #endif
                    return
                } catch {
                    switch error {
                    case .exists:
                        throw .exists

                    case .notSupported:
                        throw .notSupported

                    case .permission:
                        throw .permission

                    case .platform(let code):
                        if code.isInterrupted { continue }
                        throw Error(code: code)
                    }
                }
            }
        }
    }

#endif
