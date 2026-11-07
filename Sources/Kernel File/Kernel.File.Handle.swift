#if !os(Windows)

    extension Kernel.File {

        @frozen
        public struct Handle: ~Copyable, Sendable {

            public let descriptor: Kernel.Descriptor

            public let direct: Kernel.File.Direct.Mode.Resolved

            public let requirements: Kernel.File.Direct.Requirements

            public init(
                descriptor: consuming Kernel.Descriptor,
                direct: Kernel.File.Direct.Mode.Resolved,
                requirements: Kernel.File.Direct.Requirements
            ) {
                self.descriptor = descriptor
                self.direct = direct
                self.requirements = requirements
            }
        }
    }

    extension Kernel.File.Handle {

        public typealias Error = ISO_9945.Kernel.File.Handle.Error

        public typealias Operation = ISO_9945.Kernel.File.Handle.Operation

        public init(
            descriptor: consuming Kernel.Descriptor,
            mode direct: Kernel.File.Direct.Mode.Resolved,
            requirements: Kernel.File.Direct.Requirements
        ) {
            self.init(descriptor: descriptor, direct: direct, requirements: requirements)
        }
    }

#endif

#if os(Windows)

    extension Kernel.File.Handle {

        public init(
            descriptor: consuming Kernel.Descriptor,
            mode direct: Kernel.File.Direct.Mode.Resolved,
            requirements: Kernel.File.Direct.Requirements
        ) {

            switch requirements {
            case .known(let alignment):
                self.init(
                    descriptor: descriptor,
                    direct: {
                        switch direct {
                        case .direct: .direct

                        case .uncached: .uncached

                        case .buffered: .buffered
                        }
                    }(),
                    requirements: .known(
                        .init(
                            bufferAlignment: alignment.bufferAlignment,
                            offsetAlignment: alignment.offsetAlignment,
                            lengthMultiple: alignment.lengthMultiple
                        )
                    )
                )

            case .unknown(let reason):
                self.init(
                    descriptor: descriptor,
                    direct: {
                        switch direct {
                        case .direct: .direct

                        case .uncached: .uncached

                        case .buffered: .buffered
                        }
                    }(),
                    requirements: .unknown(
                        reason: {
                            switch reason {
                            case .platformUnsupported: .platformUnsupported

                            case .sectorSizeUndetermined: .sectorSizeUndetermined

                            case .filesystemUnsupported: .filesystemUnsupported

                            case .invalidHandle: .invalidHandle
                            }
                        }()
                    )
                )
            }
        }
    }

#endif

#if !os(Windows)

    extension Kernel.File.Handle {

        public consuming func close() throws(ISO_9945.Kernel.Close.Error) {
            try ISO_9945.Kernel.Close.close(self.descriptor)
        }
    }

#endif

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

#if !os(Windows)

    public import Either

    extension Kernel.File.Handle {

        @inlinable
        public borrowing func writeAll(
            from buffer: UnsafeRawBufferPointer
        ) throws(Either<Self.Error, Interrupt>) {
            guard let baseAddress = buffer.baseAddress else {
                return
            }

            var written = 0
            let total = buffer.count

            while written < total {
                let remaining = unsafe UnsafeRawBufferPointer(
                    start: baseAddress.advanced(by: written),
                    count: total - written
                )
                let n: Int
                do throws(ISO_9945.Kernel.IO.Write.Error) {
                    n = try unsafe ISO_9945.Kernel.IO.Write.write(descriptor, from: remaining)
                } catch {
                    if error.code.isInterrupted {
                        throw .right(.occurred)
                    }
                    throw .left(Self.Error(from: error, operation: .write))
                }
                if n == 0 {

                    throw .left(
                        Self.Error(
                            from: ISO_9945.Kernel.IO.Write.Error.platform(
                                Error::Error(code: .EIO)
                            ),
                            operation: .write
                        )
                    )
                }
                written += n
            }
        }
    }

    extension Kernel.File.Handle {

        @inlinable
        public borrowing func writeAll(
            from span: Swift.Span<Byte>
        ) throws(Either<Self.Error, Interrupt>) {
            try span.withUnsafeBytes {
                (buffer: UnsafeRawBufferPointer) throws(Either<Self.Error, Interrupt>) in
                try unsafe writeAll(from: buffer)
            }
        }
    }

#endif
