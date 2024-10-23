//
//  MTPModel.swift
//  Novasol Ingredients
//
//  Created by Auxano on 26/07/24.
//

import Foundation


// MARK: - DVRUserList
struct DVRUserList: Codable {
    
    // User List Only       //  Expennses
    var userID: Int?
    var firstname: String?
    var lastname: String?
    var startDateShow: String?
    var endDateShow: String?
    var startDate: String?
    var endDate: String?
    
    // Full user details
    var id: Int?
    var visitFor: String?
    var curDate: String?
    var createdAt1: String?
    var dvrDate: String?
    var orgDVRDate: String?
    var followUpDate: String?
    var orgFollowUpDate: String?
    var businessPartnerID: Int?
    var name: String?
    var businessPartnerName: String?
    var bmType: String?
    var industriesType: String?
    var isPersonalVisit: Int?
    var remark: String?
    var city: String?
    var meetingStatus: String?
    var status: String?
    var comment: String?
    var reportURL: String?
    var paymentMode: String?
    var amount: String?
    var chequeNo: String?
    var bankName: String?
    var leaveType: String?
    var wfoRemarks: String?
    var aeName: String?
    var aeCity: String?
    var paymentRemarks: String?
    var tradersType: String?
    var followUpType: String?
    var chequeImage: String?
    var products: [DvrProduct]?
    var contacts: [DvrContact]?
    var whoms: [Whom]?
    
    
    enum CodingKeys: String, CodingKey {
        // User List Only
        case userID = "userId"
        case firstname, lastname, startDateShow, endDateShow, startDate, endDate
        
        // Full user details
        case id, visitFor
        case curDate, createdAt1, dvrDate
        case orgDVRDate = "orgDvrDate"
        case followUpDate, orgFollowUpDate
        case businessPartnerID = "businessPartnerId"
        case name, businessPartnerName, bmType, industriesType, isPersonalVisit, remark, city, meetingStatus, status, comment, reportURL, paymentMode, amount, chequeNo, bankName, leaveType, wfoRemarks, aeName, aeCity, paymentRemarks, tradersType, followUpType, chequeImage, products, contacts, whoms
    }
}



// MARK: - Product
struct DvrProduct: Codable {
    var id: Int?
    var dvrID: Int?
    var clientProduct: String?
    var clientProductCapacity: String?
    var unit: String?
    var timeInterval: String?
    var name: String?
    var productID: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case dvrID = "dvrId"
        case clientProduct, clientProductCapacity, unit, timeInterval, name
        case productID = "productId"
    }
}


// MARK: - Contact
struct DvrContact: Codable {
    var id: Int?
    var dvrID: Int?
    var name: String?
    var mobileNo: String?
    var telNo: String?
    var emailID: String?
    var designation: String?

    enum CodingKeys: String, CodingKey {
        case id
        case dvrID = "dvrId"
        case name, mobileNo, telNo
        case emailID = "emailId"
        case designation
    }
}


// MARK: - ResultContact
struct ClientContact: Codable {
    var id: Int?
    var bID: Int?
    var name: String?
    var bmType: String?
    var industriesType: String?
    var city: String?
    var contacts: [DvrContact]?

    // Add Dvr
    var businessPartnerName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case bID = "bId"
        case name, bmType, industriesType, city, contacts
        
        // Add Dvr
        case businessPartnerName
    }
}

//// MARK: - ContactContact
//struct DvrClientContact: Codable {
//    var id: Int?
//    var dvrID: Int?
//    var name: String?
//    var mobileNo: String?
//    var telNo: String?
//    var emailID: String?
//    var designation: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case dvrID = "dvrId"
//        case name, mobileNo, telNo
//        case emailID = "emailId"
//        case designation
//    }
//}
