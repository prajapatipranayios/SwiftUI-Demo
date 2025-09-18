//
//  NotificationService.swift
//  TusslyNotificationService
//
//  Created by Auxano on 22/07/25.
//

//import UserNotifications
//
//class NotificationService: UNNotificationServiceExtension {
//
//    var contentHandler: ((UNNotificationContent) -> Void)?
//    var bestAttemptContent: UNMutableNotificationContent?
//
//    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//        
//        
//        if bestAttemptContent != nil {
//            // Modify the notification content here...
//            if let notificationData = request.content.userInfo as? [String: Any] {
//                // Grab the attachment
//                if let urlString = notificationData["attachment_url"], let fileUrl = URL(string: urlString as! String) {
//                    // Download the attachment
//                    URLSession.shared.downloadTask(with: fileUrl) { (location, response, error) in
//                        if let location = location {
//                            // Move temporary file to remove .tmp extension
//                            let tmpDirectory = NSTemporaryDirectory()
//                            let tmpFile = "file://".appending(tmpDirectory).appending(fileUrl.lastPathComponent)
//                            let tmpUrl = URL(string: tmpFile)!
//                            try! FileManager.default.moveItem(at: location, to: tmpUrl)
//                            
//                            // Add the attachment to the notification content
//                            if let attachment = try? UNNotificationAttachment(identifier: "", url: tmpUrl) {
//                                self.bestAttemptContent?.attachments = [attachment]
//                            }
//                        }
//                        // Serve the notification content
//                        self.contentHandler!(self.bestAttemptContent!)
//                    }.resume()
//                }
//            }
//        }
//    }
//    
//    override func serviceExtensionTimeWillExpire() {
//        // Called just before the extension will be terminated by the system.
//        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
//        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
//            contentHandler(bestAttemptContent)
//        }
//    }
//
//}


import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(
        _ request: UNNotificationRequest,
        withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
    ) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        guard let userInfo = request.content.userInfo as? [String: Any],
              let urlString = userInfo["attachment_url"] as? String,
              let fileURL = URL(string: urlString)
        else {
            contentHandler(bestAttemptContent)
            return
        }
        
        URLSession.shared.downloadTask(with: fileURL) { (location, _, error) in
            defer {
                contentHandler(bestAttemptContent) // Always call this
            }
            
            guard let location = location, error == nil else {
                print("Failed to download attachment: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            let tmpDir = URL(fileURLWithPath: NSTemporaryDirectory())
            let localURL = tmpDir.appendingPathComponent(fileURL.lastPathComponent)
            
            do {
                try FileManager.default.moveItem(at: location, to: localURL)
                let attachment = try UNNotificationAttachment(identifier: "image", url: localURL, options: nil)
                bestAttemptContent.attachments = [attachment]
            } catch {
                print("Error attaching image: \(error)")
            }
        }.resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
