#if !os(Windows)

    public import Either

    extension Kernel.File.Handle {

        public borrowing func write(
            from buffer: UnsafeRawBufferPointer
        ) throws(Either<Kernel.File.Handle.Error, Interrupt>) -> Int {
            do throws(ISO_9945.Kernel.IO.Write.Error) {
                return try unsafe ISO_9945.Kernel.IO.Write.write(descriptor, from: buffer)
            } catch {
                if error.code.isInterrupted {
                    throw .right(.occurred)
                }
                throw .left(Kernel.File.Handle.Error(from: error, operation: .write))
            }
        }

        public borrowing func pwrite(
            from buffer: UnsafeRawBufferPointer,
            at offset: ISO_9945.Kernel.File.Offset
        ) throws(Either<Kernel.File.Handle.Error, Interrupt>) -> Int {
            do throws(ISO_9945.Kernel.IO.Write.Error) {
                return try unsafe ISO_9945.Kernel.IO.Write.pwrite(descriptor, from: buffer, at: offset)
            } catch {
                if error.code.isInterrupted {
                    throw .right(.occurred)
                }
                throw .left(Kernel.File.Handle.Error(from: error, operation: .write))
            }
        }
    }

    extension Kernel.File.Handle {

        public borrowing func write(
            from span: Swift.Span<Byte>
        ) throws(Either<Kernel.File.Handle.Error, Interrupt>) -> Int {
            do throws(ISO_9945.Kernel.IO.Write.Error) {
                return try ISO_9945.Kernel.IO.Write.write(descriptor, from: span)
            } catch {
                if error.code.isInterrupted {
                    throw .right(.occurred)
                }
                throw .left(Kernel.File.Handle.Error(from: error, operation: .write))
            }
        }

        public borrowing func pwrite(
            from span: Swift.Span<Byte>,
            at offset: ISO_9945.Kernel.File.Offset
        ) throws(Either<Kernel.File.Handle.Error, Interrupt>) -> Int {
            do throws(ISO_9945.Kernel.IO.Write.Error) {
                return try ISO_9945.Kernel.IO.Write.pwrite(descriptor, from: span, at: offset)
            } catch {
                if error.code.isInterrupted {
                    throw .right(.occurred)
                }
                throw .left(Kernel.File.Handle.Error(from: error, operation: .write))
            }
        }
    }

#endif
