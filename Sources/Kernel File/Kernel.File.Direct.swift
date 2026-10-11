public import Memory
public import Path

extension Kernel.File {
    public enum Direct {}
}

extension Kernel.File.Direct {

    public static func requirements(
        for path: borrowing Path
    ) -> Requirements {
        .platformDefault
    }
}

extension Kernel.File.Direct.Requirements {

    public init(
        bufferAlignment: Memory.Alignment,
        offsetAlignment: Memory.Alignment,
        lengthMultiple: Memory.Alignment
    ) {
        self = .known(
            Alignment(
                bufferAlignment: bufferAlignment,
                offsetAlignment: offsetAlignment,
                lengthMultiple: lengthMultiple
            )
        )
    }

    public init(uniformAlignment alignment: Memory.Alignment) {
        self = .known(Alignment(uniform: alignment))
    }
}
