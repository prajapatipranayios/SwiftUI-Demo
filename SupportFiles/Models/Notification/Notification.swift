//
//  MTPModel.swift
//  Novasol Ingredients
//
//  Created by Auxano on 26/07/24.
//

import Foundation


// MARK: - Notification
struct NotificationList: Codable {
    
    var title: String?
    var body: String?
    var clickAction: String?
    var isRead: Int?
    var data: String?
    var notificationDate: String?
}
