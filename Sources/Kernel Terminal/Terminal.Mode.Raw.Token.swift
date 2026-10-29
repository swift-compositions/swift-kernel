#if KernelTerminal
    import Error
    public import Terminal

    #if !os(Windows)
        @_spi(Syscall) import POSIX_Kernel_Terminal
    #endif

    extension Terminal.Mode.Raw {

        public struct Token: ~Copyable, Sendable {

            public let stream: Terminal.Stream

            #if os(Windows)
                public let previous: UInt32
            #else
                public let previous: ISO_9945.Kernel.Termios.Attributes
            #endif

            public var restored: Bool = false

            #if os(Windows)
                public init(stream: Terminal.Stream, previous: UInt32) {
                    self.stream = stream
                    self.previous = previous
                }
            #else
                public init(stream: Terminal.Stream, previous: ISO_9945.Kernel.Termios.Attributes) {
                    self.stream = stream
                    self.previous = previous
                }
            #endif
        }
    }

    #if !os(Windows)

        extension Terminal.Mode.Raw {

            public func enter() throws(Terminal.Error) -> Token {
                do throws(Error::Error) {
                    let original = try ISO_9945.Kernel.Termios.Attributes.get(fd: stream.rawValue)
                    let raw = original.withRaw()
                    try ISO_9945.Kernel.Termios.Attributes.set(raw, fd: stream.rawValue)
                    return Token(stream: stream, previous: original)
                } catch {
                    throw Terminal.Error(operation: .enterRaw, underlying: .kernel(error))
                }
            }
        }

        extension Terminal.Mode.Raw.Token {

            public mutating func restore() throws(Terminal.Error) {
                guard !restored else { return }
                do throws(Error::Error) {
                    try ISO_9945.Kernel.Termios.Attributes.set(previous, fd: stream.rawValue)
                    restored = true
                } catch let error {
                    throw Terminal.Error(operation: .exitRaw, underlying: .kernel(error))
                }
            }
        }

    #endif
#endif
