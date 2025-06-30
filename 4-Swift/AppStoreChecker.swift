
import Foundation

class AppStoreChecker {
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
