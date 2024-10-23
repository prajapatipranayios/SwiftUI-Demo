//
//  ApiResponse.swift
//  GEClone-UI
//
//  Created by Auxano on 23/10/24.
//

import Foundation

struct ApiResponse: Codable {
    var status: Int?
    var result: Response?
    var message: String
}

struct Response: Codable {
    
    // Login
    
    
    // Home
    var userDetail : UserDetail?
    
    enum CodingKeys: String, CodingKey {
        
        // Home
        case userDetail
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Home
        userDetail = try values.decodeIfPresent(UserDetail.self, forKey: .userDetail)
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Home
            try container.encodeIfPresent(userDetail, forKey: .userDetail)
        }
        catch let err {
            print(err)
        }
    }
    
}

struct UserDetail : Codable {
    
    var id : Int?
    var roleId : Int?
    var firstname : String?
    var lastname : String?
    var email : String?
    var image : String?
    var isActive : Int?
    var userDesignation : String?
    var zone : String?
    var monthlyTargetActual : Double?
    var quarterlyTargetActual : Double?
    var yearlyTargetActual : Double?
    var monthlyTargetStatus : Int?
    var quarterlyTargetStatus : Int?
    var yearlyTargetStatus : Int?
    var companyType : Int?
    var totalOrder : Int?
    var totalQuotationOrder : Int?
    var totalPiOrder : Int?
    var totalSampleOrder : Int?
    var totalFollowupOrder : Int?
    var isTada : Int?
    var isSales : Int?
    var designationId : Int?
    var isLogged : Int?
    var chatUserId : String?
    //var warehouse : [Warehouse]?
    var chatSecretKey : String?
    var latestVersion : Double?
    var otherChatId : [String]?
    var token: String?
    
}
