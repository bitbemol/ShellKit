import Foundation

/// A utility for safely and conveniently executing shell commands.
///
/// Use the static ``run(_:)`` method to execute commands. On success, it returns
/// the command's output as a string. On failure, it throws a `CommandError`.
/// This allows you to use Swift's standard `do-try-catch` syntax for error handling.
///
/// ### Example
///
/// ```swift
/// do {
///     let output = try Shell.run("ls", "-la")
///     print("Command succeeded:\n\(output)")
/// } catch {
///     print("Command failed: \(error)")
/// }
/// ```
struct Shell {
    
    /// An error that represents a failed shell command execution.
    ///
    /// This error contains the exit code of the process, as well as any output
    /// captured from the standard error and standard output streams.
    struct CommandError: Error, CustomStringConvertible {
        /// The termination status (exit code) of the command. A value of `0` typically indicates success.
        let terminationStatus: Int32
        /// The content captured from the standard error stream (`stderr`).
        let errorOutput: String
        /// The content captured from the standard output stream (`stdout`), which may be present even if the command failed.
        let standardOutput: String
        
        /// A human-readable description of the error, suitable for logging or debugging.
        var description: String {
            """
            Command failed with exit code \(terminationStatus).
            --- Error Output ---
            \(errorOutput.isEmpty ? "None" : errorOutput)
            --- Standard Output ---
            \(standardOutput.isEmpty ? "None" : standardOutput)
            """
        }
    }
    
    /// Executes a shell command with the provided arguments.
    ///
    /// - Parameter command: A variadic list of strings representing the command and its arguments.
    ///   The first string is the command to execute (e.g., `"ls"`), and subsequent strings are its
    ///   arguments (e.g., `"-la"`).
    ///
    /// - Throws: A ``CommandError`` if the command cannot be launched or exits with a non-zero status.
    /// - Returns: The standard output of the command as a `String` on successful execution.
    @discardableResult
    static func run(_ command: String...) throws -> String {
        let process = Process()
        
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = command
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
            let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
            
            let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

            // If the command succeeded, return its output.
            if process.terminationStatus == 0 {
                return output
            } else {
                // If the command failed, throw an error with all the captured details.
                throw CommandError(
                    terminationStatus: process.terminationStatus,
                    errorOutput: errorOutput,
                    standardOutput: output
                )
            }
        } catch let cmdError as CommandError {
            // Propagate CommandError thrown above (e.g., non-zero exit)
            throw cmdError
        } catch {
            // If `process.run()` or another unexpected error occurred, wrap it as a CommandError.
            throw CommandError(
                terminationStatus: -1,
                errorOutput: (error as NSError).localizedDescription,
                standardOutput: ""
            )
        }
    }
}
