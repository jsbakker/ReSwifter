// Comment: func var let 42 3.14 "string" struct class enum

/* Block comment: if else return Int Bool String
   Numbers: 100 0.5 — all plain comment text, no highlighting */

import Foundation

@MainActor
final class SnippetTester: ObservableObject {

    // Strings — keywords/numbers/comments inside won't highlight
    let plain: String       = "hello world"
    let withKeyword: String = "func let var class struct return"
    let withNumber: String  = "count is 42 and ratio is 3.14"
    let withComment: String = "// not a comment — /* nor is this */"

    // Multi-line string — same non-highlighting rules apply inside
    let block = """
        if else switch for while 99 0.75
		 \(foo + 20)
        // still just a string, not a comment
        /* also not a block comment in here */
        """

    // Numbers: integers and floats
    let intVal: Int    = 42
    let bigInt: Int64  = 9_000_000
    let byte: UInt8    = 255
    let pi: Double     = 3.14159
    let ratio: Float   = 0.5 + 1.0 - 0.5

    // Properties with keywords and types
    @Published private var items: Array<String> = []
    @State var enabled: Bool = true
    weak var delegate: AnyObject?
    var optional: Optional<Int> = nil

    // Function: control flow, access, concurrency, error handling
    public func process(count: Int = 0) async throws -> Result<Bool, Error> {
        guard count > 0 else { return .failure(NSError()) }

        for i in 0 ..< count {
            switch i {
            case 0:    break
            case 1:    fallthrough
            default:   continue
            }
        }

        /* Mid-function block comment:
           var x = 10, let s = "test", if true { return } */

        defer { /* inline block comment */ }

        let values: [UInt8]  = [0, 128, 255]
        let flags: Set<Bool>  = [true, false]
        _ = values; _ = flags

        return .success(true)
    }

    // Lambda with block comment as unused parameter name
    func transform() {
        let nums = [1, 2, 3]
        _ = nums.map      { (/* unused */ _: Int)         in 0   }
        _ = nums.reduce(0) { (acc: Int, /* next */ _: Int) in acc }
    }

    @ViewBuilder func build() -> some Any { () }
}

// Protocol, extension, actor — more keyword/type coverage
protocol Nameable: AnyObject {
    associatedtype ID where ID: Sendable
    var name: String { get }
}

extension SnippetTester: Nameable {
    typealias ID = UInt
    var name: String { "tester \(intVal)" }
}

actor DataStore {
    nonisolated let id: UInt = 1
    private(set) var cache: Optional<String> = nil

    isolated func load() async -> Never { fatalError("unimplemented") }
}
