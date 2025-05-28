//
//  APIResponse.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 25/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//


struct ApiResponse: Codable {
    var status: Int
    var result: Response?
    var message: String
}

struct Response: Codable {
    
    var redirectUrl: String?
    
    //Login, checkEmailMobileNumber
    var userDetail: User?
    var accessToken: String?
    var isVerified: Int?
    var notificationCount: Int?

    //Forgot Password
    var otp: String?
    
    // Confirm Ticket
    var totalAvailbleTicket: Int?

    //Notifications
    var notifications: [Notification]?
    
    //User Request List
    var userList: [UserRequest]?
    var hasMore: Int?

    //getNearByPostEvents
    var totalPost: [PostEventDetail]?
    
    //getPostEventDetails
    var postDetail: PostEventDetail?
    var eventDetail: PostEventDetail?

    //getForumQuestionList
    var questionsList: [ForumQuestion]?
    
    //getAllEventsList
    var eventList: [PostEventDetail]?

    //getAllUserPost
    var postList: [PostEventDetail]?
    
    //getUsersAllMedia
    var mediaList: [Media]?
    
    //getUsersReview
    var reviewList: [UserReview]?
    
    //getConversations
    var conversations: [Conversation]?
    
    //getChats
    var data: [ChatMessage]?
    
    //Send Message
    var lastMessage: ChatMessage?

    //searchFoodFlocker
    var tagList: [Tag]?

    //getCards
    var cardList: [Card]?
    
    //getFAQs
    var faqsList: [FAQ]?
    
    //getTermAndPolicy
    var termAndPolicy: [TermsPolicyContent]?
    
    //getAboutUs
    var aboutUs: AboutUs?
    
    //uploadProfile
    var profilePic: String?
    
    //addCard
    var userCardData: Card?
    
    //getBankDetail
    var userBankAccountDetail: BankDetail?
}

struct Notification: Codable {
    var id: Int
    var notificationType: String
    var title: String
    var description: String
    var action: String
    var positiveText: String
    var negativeText: String
    var isRead: Int
    var isActionDone: Int
    var userId: Int
    var name: String
    var userName: String
    var profilePic: String
    var isNotificationOn: Int
    var rating: Float
    var reviewCount: Int
    var notificationTime: String
}

struct ForumQuestion: Codable {
    var id: Int
    var userId: Int
    var question: String
    var name: String
    var userName: String
    var profilePic: String
    var isNotificationOn: Int
    var rating: Float
    var reviewCount: Int
    var questionDate: String
    var answers: [UserRequest]
}

struct Tag: Codable {
    var tag: String
}

struct Card: Codable {
    var token: String
    var scheme: String
    var display_number: String
    var issuing_country: String
    var expiry_month: Int
    var expiry_year: Int
    var name: String
    var address_line1: String
    var address_line2: String
    var address_city: String
    var address_postcode: String
    var address_state: String
    var address_country: String
    var customer_token: String
    var primary: Bool
}

struct BankDetail: Codable {
    var token: String
    var name: String
    var email: String
    var created_at: String
    var kyc_status: String
    var bank_account: BankAccount
}

struct BankAccount: Codable {
    var token: String
    var name: String
    var bsb: String
    var number: String
    var bank_name: String
    var branch: String
}


struct FAQ: Codable {
    var id: Int
    var question: String
    var answer: String
}

struct TermsPolicyContent: Codable {
    var id: Int
    var name: String
    var title: String
    var slug: String
    var content: String
}

struct AboutUs: Codable {
    var about: String
    var address: String
    var mobileNumber: String
    var email: String
}
