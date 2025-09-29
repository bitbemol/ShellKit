import Testing
@testable import ShellKit

@Suite("Shell.run tests")
struct ShellRunTests {
    @Test("succeeds and returns trimmed stdout")
    func succeedsAndReturnsTrimmedStdout() throws {
        // Using `printf` for predictable behavior across shells/platforms.
        let output = try Shell.run("printf", "hello\n")
        #expect(output == "hello")
    }

    @Test("throws CommandError on non-zero exit status")
    func throwsOnNonZeroExit() {
        do {
            _ = try Shell.run("false")
            #expect(Bool(false), "Shell.run('false') should have thrown a CommandError")
        } catch {
            guard let cmdError = error as? Shell.CommandError else {
                #expect(Bool(false), "Unexpected error type: \(error)")
                return
            }
            // `false` exits with status 1 and produces no output.
            #expect(cmdError.terminationStatus == 1)
            #expect(cmdError.standardOutput.isEmpty)
            #expect(cmdError.errorOutput.isEmpty)
        }
    }

    @Test("captures stderr when command fails")
    func capturesStderrOnFailure() {
        do {
            _ = try Shell.run("sh", "-c", "echo err 1>&2; exit 2")
            #expect(Bool(false), "Expected Shell.run to throw when command exits non-zero")
        } catch {
            guard let cmdError = error as? Shell.CommandError else {
                #expect(Bool(false), "Unexpected error type: \(error)")
                return
            }
            #expect(cmdError.terminationStatus == 2)
            #expect(cmdError.errorOutput == "err")
        }
    }

    @Test("captures stdout even when command fails")
    func capturesStdoutOnFailure() {
        do {
            _ = try Shell.run("sh", "-c", "echo out; echo err 1>&2; exit 3")
            #expect(Bool(false), "Expected Shell.run to throw when command exits non-zero")
        } catch {
            guard let cmdError = error as? Shell.CommandError else {
                #expect(Bool(false), "Unexpected error type: \(error)")
                return
            }
            #expect(cmdError.terminationStatus == 3)
            #expect(cmdError.standardOutput == "out")
            #expect(cmdError.errorOutput == "err")
        }
    }
}

