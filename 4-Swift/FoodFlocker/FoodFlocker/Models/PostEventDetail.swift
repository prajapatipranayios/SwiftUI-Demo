//
//  FoodPost.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 30/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

struct PostEventDetail: Codable {
    var id: Int
    var createdBy: Int?
    var title: String
    var address: String
    var latitude: Double
    var longitude: Double
    var description: String
    var viewCount: Int?
    var likesCount: Int
    var shareCount: Int
    var module: String?
    
    var isActive: Int?
    var type: String?
    var isExpiringSoon: Int?
    var days: Int?
    var hours: Int?
    var expiringDate: String?
    
    var receipt: String?
    var categoryId: Int?
    var category: String?
    
    //Event
    var startDate: String?
    var endDate: String?
    var isLimitedTicket: Int?
    var totalAvailbleTicket: Int?
    var interestedCount: Int?
    var mayBeCount: Int?
    
    var isDownloadTicket: Int?
    var tickets: Int?
    
    var createDate: String
    var userId: Int
    var name: String
    var userName: String
    var rate: Double?
    var review: String?
    var accountType: String?
    var amount: String?
    var profilePic: String
    var isNotificationOn: Int
    var rating: Float?
    var reviewCount: Int
    var isLike: Int?
    var mediaImage: String?
    var mediaName: String?
    var distance: Float?
    var eventStatus: String?
    var isSave: Int?
    
    //Food Post Details
    var requestUserId: Int?
    var isFollowing: Int?
    var followingStatus: String?
    var isRequested: Int?
    var requestStatus: String?
    var isExpire: Int?

    var medias: [Media]?
    var foodDetails: [FoodDetail]?

    //getSentReceivePostRequest
    var status: String?
    var postId: Int?
    var requestTime: String?

}

struct Media: Codable {
    var id: Int

    var mediaName: String?
    var videoUrl: String?
    var mediaType: String 
    var postId: Int?
    var isLike: Int?
    
    var module: String?
    var moduleId: Int?
    var mediaImage: String?
    var type: String?
    var userId: Int?
    var name: String?
    var userName: String?
    var profilePic: String?
    var isNotificationOn: Int?
    var rating: Float?
    var reviewCount: Int?
    var isFollowing: Int?
    var followingStatus: String?
    var accountType: String?
}

struct FoodDetail: Codable {
    var id: Int
    var moduleId: Int
    var module: String
    var foodName: String
    var categoryId: Int
    var quantity: String
    var recipe: String
    var backgroundImage: String
    var realName: String
    var cookName: String
    var tags: String
    var ingredients: String
    var amount: Float
    var sign: String
    var costingSheet: [CostingSheet]?
}

struct CostingSheet: Codable {
    var id: Int
    var foodId: Int
    var name: String
    var price: Float
    var sign: String?
}
