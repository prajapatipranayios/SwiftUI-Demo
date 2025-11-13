//
//  Logger.swift
//  SwiftDemo1
//
//  Created by Auxano on 13/11/25.
//

import Foundation
//import ShipBookSDK

// MARK: - Log Level Enum
enum LogLevel: String, CaseIterable {
    case info    = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error   = "❌ ERROR"
    case debug   = "🐞 DEBUG"
}

// MARK: - Logger Utility
final class Logger {
    
    // MARK: Shared Instance (Thread Safe)
    static let shared = Logger()
    private init() {}
    
    // MARK: Configuration
    var isConsoleLoggingEnabled: Bool = true
    var isThirdPartyLoggingEnabled: Bool = false
    var minimumLogLevel: LogLevel = .debug
    
    /// Optional closure for forwarding logs to a third-party SDK (e.g., Shipbook, Datadog)
    var thirdPartyLogger: ((LogLevel, String, Any?) -> Void)?
    
    /// Date formatter reused for performance
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
    
    // MARK: Core Log Method
    func log(_ message: String,
             data: Any? = nil,
             level: LogLevel = .info,
             file: String = #file,
             function: String = #function,
             line: Int = #line) {
        
        // Respect log level filtering
        guard shouldLog(level) else { return }
        
        // Prepare timestamp
        let timestamp = dateFormatter.string(from: Date())
        
        // Extract filename
        let filename = (file as NSString).lastPathComponent
        
        // Prepare formatted log
        let formattedMessage = "[\(timestamp)] [\(level.rawValue)] [\(filename):\(line)] \(function) → \(message)"
        
        // Print to console
        if isConsoleLoggingEnabled {
            print(formattedMessage)
            if let data = data {
                print(prettyPrint(data))
            }
        }
        
        // Forward to third-party logger
        if isThirdPartyLoggingEnabled, let thirdPartyLogger = thirdPartyLogger {
            thirdPartyLogger(level, message, data)
            //forwardToThirdParty(level: level, message: message, data: data)
        }
    }
}

// MARK: - Convenience Shortcuts
extension Logger {
    static func info(_ message: String, data: Any? = nil,
                     file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(message, data: data, level: .info, file: file, function: function, line: line)
    }
    
    static func warning(_ message: String, data: Any? = nil,
                        file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(message, data: data, level: .warning, file: file, function: function, line: line)
    }
    
    static func error(_ message: String, data: Any? = nil,
                      file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(message, data: data, level: .error, file: file, function: function, line: line)
    }
    
    static func debug(_ message: String, data: Any? = nil,
                      file: String = #file, function: String = #function, line: Int = #line) {
        shared.log(message, data: data, level: .debug, file: file, function: function, line: line)
    }
}

// MARK: - Helpers
private extension Logger {
    
    func shouldLog(_ level: LogLevel) -> Bool {
        // Define order: error > warning > info > debug
        let order: [LogLevel] = [.debug, .info, .warning, .error]
        guard
            let currentIndex = order.firstIndex(of: level),
            let minimumIndex = order.firstIndex(of: minimumLogLevel)
        else { return true }
        return currentIndex >= minimumIndex
    }
    
    func prettyPrint(_ data: Any) -> String {
        if let dict = data as? [String: Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return "📦 Data:\n\(jsonString)"
        }
        if let array = data as? [Any],
           let jsonData = try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return "📦 Data:\n\(jsonString)"
        }
        return "📦 Data: \(data)"
    }
    
    // MARK: - 🔥 Forwarder Function
    func forwardToThirdParty(level: LogLevel, message: String, data: Any?) {
        guard let thirdPartyLogger = thirdPartyLogger else { return }
        
        // Here you can handle different levels in one place
        switch level {
        case .info:
            thirdPartyLogger(.info, message, data)
            
        case .warning:
            thirdPartyLogger(.warning, message, data)
            
        case .error:
            thirdPartyLogger(.error, message, data)
            
        case .debug:
            thirdPartyLogger(.debug, message, data)
        }
        
//        switch level {
//        case .info:
//            ShipBook.log(message)
//        case .warning:
//            ShipBook.warn(message)
//        case .error:
//            ShipBook.error(message)
//        case .debug:
//            ShipBook.debug(message)
//        }
    }
}
