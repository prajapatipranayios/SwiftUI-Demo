//
//  UserDetail.swift
//  - This class is used to manage & parse API Response

//  Tussly
//
//  Created by Auxano on 19/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import Foundation

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
	var warehouse : [Warehouse]?
    var chatSecretKey : String?
    var latestVersion : Double?
    var otherChatId : [String]?
    var token: String?
    
}

// MARK: - Branch
struct Branch: Codable {
    
    var id: Int?
    var branchName: String?
    var stateId: Int?
}

// MARK: - Category
struct Category: Codable {
    
    let id: Int?
    let name: String?
    
    // Sales Order Report Details
    var productUnit: String?
    var productQty: String?
    var totalAmount: Double?
}
