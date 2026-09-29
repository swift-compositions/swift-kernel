#if os(Linux) || os(Android) || os(OpenBSD) || os(Windows)
    extension System {

        @inlinable
        public static var physicalProcessorCount: Int {
            System.processorCount
        }
    }
#endif
