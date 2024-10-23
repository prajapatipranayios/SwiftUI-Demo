//
//  ApiResponseNotification.swift
//  Novasol Ingredients
//
//  Created by Auxano on 31/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseNotification: Codable {
    var status: Int?
    var result: ResponseNotification?
    var message: String
}

struct ResponseNotification: Codable {
    
    // Notification
    var notification: [NotificationList]?
    var hasMore: Bool?
    
    
    
    enum CodingKeys: String, CodingKey {
        
        // Notification
        case notification
        case hasMore
        
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Notification
        notification = try values.decodeIfPresent([NotificationList].self, forKey: .notification)
        hasMore = try values.decodeIfPresent(Bool.self, forKey: .hasMore)
        
        
        
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Notification
            try container.encodeIfPresent(notification, forKey: .notification)
            try container.encodeIfPresent(hasMore, forKey: .hasMore)
            
            
        }
        catch let err {
            print(err)
        }
    }
}
