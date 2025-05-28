//
//  User.swift
//  FoodFlocker
//

struct User: Codable {
    var id: Int
    var name: String
    var userName: String
    var email: String
    var mobileNumber: String
    var countryCode: String?
    var userType: String?
    var accountType: String?
    var aboutMe: String?
    var ABN: String
    var profilePic: String
    var rating: Double
    var otp: String?
    var isMobileVerify: Int
    var isEmailVerify: Int
    var isUpdated: Int
    var isActive: Int
    var isNewUser: Int
    var website: String
    var isOnCallAndSms: Int
    var socialId: String?
    var socialType: String?
    var followersCount: Int
    var followingCount: Int
    var requestsCount: Int
    var reviewCount: Int
    var eventCount: Int?
    var updatedAt: String?
    
    var isNotificationOn: Int?
    
    var isFollowing: Int?
    var followingStatus: String?

}

struct UserRequest: Codable {
    var requestId: Int?
    var id: Int
    var answer: String?
    var userId: Int?
    var name: String
    var userName: String
    var profilePic: String
    var accountType: String?
    var isNotificationOn: Int
    var rating: Float
    var reviewCount: Int
    var isFollowing: Int?
    var followingStatus: String?
    var createdAt: String?
    var answerDate: String?
}

struct UserReview: Codable {
    var id: Int
    var rate: Int
    var review: String
    var module: String
    var moduleId: Int
    var userId: Int
    var name: String
    var userName: String
    var profilePic: String
    var isNotificationOn: Int
    var rating: Float
    var reviewCount: Int
    var isFollowing: Int
    var followingStatus: String
    var accountType: String?
}
