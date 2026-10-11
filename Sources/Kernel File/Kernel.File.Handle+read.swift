#if !os(Windows)

    public import Either

    extension Kernel.File.Handle {

        public borrowing func read(
            into buffer: UnsafeMutableRawBufferPointer
        ) throws(Either<Kernel.File.Handle.Error, Interrupt>) -> Int {
            do throws(ISO_9945.Kernel.IO.Read.Error) {
                return try unsafe ISO_9945.Kernel.IO.Read.read(descriptor, into: buffer)
            } catch {
                if error.code.isInterrupted {
                    throw .right(.occurred)
                }
                throw .left(Kernel.File.Handle.Error(from: error, operation: .read))
            }
        }

        public borrowing func pread(
            into buffer: UnsafeMutableRawBufferPointer,
            at offset: ISO_9945.Kernel.File.Offset
        ) throws(Either<Kernel.File.Handle.Error, Interrupt>) -> Int {
            do throws(ISO_9945.Kernel.IO.Read.Error) {
                return try unsafe ISO_9945.Kernel.IO.Read.pread(descriptor, into: buffer, at: offset)
            } catch {
                if error.code.isInterrupted {
                    throw .right(.occurred)
                }
                throw .left(Kernel.File.Handle.Error(from: error, operation: .read))
            }
        }
    }

    extension Kernel.File.Handle {

        public borrowing func read(
            into span: inout MutableSpan<Byte>
        ) throws(Either<Kernel.File.Handle.Error, Interrupt>) -> Int {
            do throws(ISO_9945.Kernel.IO.Read.Error) {
                return try ISO_9945.Kernel.IO.Read.read(descriptor, into: &span)
            } catch {
                if error.code.isInterrupted {
                    throw .right(.occurred)
                }
                throw .left(Kernel.File.Handle.Error(from: error, operation: .read))
            }
        }

        public borrowing func pread(
            into span: inout MutableSpan<Byte>,
            at offset: ISO_9945.Kernel.File.Offset
        ) throws(Either<Kernel.File.Handle.Error, Interrupt>) -> Int {
            do throws(ISO_9945.Kernel.IO.Read.Error) {
                return try ISO_9945.Kernel.IO.Read.pread(descriptor, into: &span, at: offset)
            } catch {
                if error.code.isInterrupted {
                    throw .right(.occurred)
                }
                throw .left(Kernel.File.Handle.Error(from: error, operation: .read))
            }
        }
    }

#endif
