//: [Previous](@previous)

import Foundation
import PlaygroundSupport

// Keep the playground running for async task
PlaygroundPage.current.needsIndefiniteExecution = true

class AppStorebundleIdChecker {
    static func checkIfAppExists(bundleId: String, completion: @escaping (Bool) -> Void) {
        let urlString = "https://itunes.apple.com/lookup?bundleId=\(bundleId)"
        guard let url = URL(string: urlString) else {
            completion(false)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let resultCount = json["resultCount"] as? Int {
                    completion(resultCount > 0)
                } else {
                    completion(false)
                }
            } catch {
                completion(false)
            }
        }.resume()
    }
}

// MARK: - Common function to test any bundle ID
func testAppExistence(bundleId: String) {
    AppStorebundleIdChecker.checkIfAppExists(bundleId: bundleId) { exists in
        print("Bundle ID: \(bundleId) ➜ App exists: \(exists)")
        PlaygroundPage.current.finishExecution()
    }
}

// Example usage
//testAppExistence(bundleId: "com.google.ios.youtube")
testAppExistence(bundleId: "com.app.tussly")


//: [Next](@next)
