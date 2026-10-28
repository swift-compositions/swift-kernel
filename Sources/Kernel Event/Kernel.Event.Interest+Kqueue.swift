#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    /// Vnode interests: changes to the file or directory a descriptor refers to.
    ///
    /// They exist only where the event source is kqueue, which watches a descriptor opened on
    /// the node itself. Linux has no descriptor-based equivalent under epoll (inotify watches
    /// paths), so these members are absent there and code that names them does not compile.
    extension Kernel.Event.Interest {

        /// The node's contents changed: written or extended. For a directory, an entry was
        /// added, removed or renamed.
        public static let change = Self(rawValue: 1 << 3)

        /// The node's attributes or link count changed.
        public static let attributes = Self(rawValue: 1 << 4)

        /// The node was renamed or moved.
        public static let rename = Self(rawValue: 1 << 5)

        /// The node was deleted.
        public static let delete = Self(rawValue: 1 << 6)

        /// Access to the node was revoked, for example because its volume was unmounted.
        public static let revoke = Self(rawValue: 1 << 7)

        /// Every vnode interest.
        public static let vnode: Self = [.change, .attributes, .rename, .delete, .revoke]
    }

#endif
