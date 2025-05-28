//
//  Conversation.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 16/04/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

struct Conversation: Codable {
    
    var id: Int
    var name: String
    var userName: String
    var profilePic: String
    
    var lastMessageId: Int
    var message: String
    var messageType: String

    var mt: String
    var messageTime: String
    
    var unReadCount: Int
    var userId: Int

    var RequestDate: String
    var identifier: String
    
}

struct ChatMessage: Codable {
    var id: Int
    var message: String
    var messageUrl: String
    var thumbnailImage: String?
    var isRead: Int
    var senderId: Int
    var receiverId: Int
    var messageType: String
    var messageDate: String?
    var messageTime: String
    var createdAt: String
}
