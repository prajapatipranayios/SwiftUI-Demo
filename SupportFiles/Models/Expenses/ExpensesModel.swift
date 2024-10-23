//
//  MTPModel.swift
//  Novasol Ingredients
//
//  Created by Auxano on 26/07/24.
//

import Foundation



// MARK: - Expense
struct UserExpenseListDetails: Codable {
    
    // Expennses User List
    var userID: Int?
    var firstname: String?
    var lastname: String?
    var startDateShow: String?
    var endDateShow: String?
    var startDate: String?
    var endDate: String?
    
    var code: String?
    var designation: String?
    var status, id: Int?
    var title: String?
    var amount: String?
    var reimbursment: String?
    var reimbursmentHr: String?
    var requestDate: String?
    var expenseDate: String?
    var isClub: Int?
    var isDraft: Int?
    var isViolated: Int?
    var createdAt: String?
    var employeeName: String?

    
    // Expense Detail
    
    var expenseCode: String?
    var category: String?
    var catSlug: String?
    var isTravel: Int?
    var paymentMode: String?
    var spentAt: String?
    var cityCategory: String?
    var cityName: String?
    var toDate: String?
    var expenseType: String?
    var travelModeID: Int?
    var travelMode: String?
    var travelFrom: String?
    var travelTo: String?
    var travelVia: String?
    var distance: Double?
    var travelType: String?
    var travelReson: String?
    var reductionAmount: String?
    var reductionAmountHr: String?
    var comment: String?
    var statusByDesignation: String?
    var statusBy: Int?
    var clubID: Int?
    var remarks: String?
    var violatedType: String?
    var violatedMsg: String?
    var expenseAttachment: [ExpenseAttachment]?
    var statusHistory: [StatusHistory]?
    
    
    
    enum CodingKeys: String, CodingKey {
        
        // Expennses User List
        case userID = "userId"
        case firstname, lastname, startDateShow, endDateShow, startDate, endDate
        
        case code
        case designation, status, id, title, amount, reimbursment, reimbursmentHr, requestDate, expenseDate, isClub, isDraft, isViolated, createdAt, employeeName
        
        
        // Expense Detail
        
        case expenseCode, category, catSlug, isTravel, paymentMode, spentAt, cityCategory, cityName, toDate, expenseType
        case travelModeID = "travelModeId"
        case travelMode, travelFrom, travelTo, travelVia, distance, travelType, travelReson, reductionAmount, reductionAmountHr, comment, statusByDesignation, statusBy
        case clubID = "clubId"
        case remarks, violatedType, violatedMsg, expenseAttachment, statusHistory
    }
}


// MARK: - StatusHistory
struct StatusHistory: Codable {
    var id: Int?
    var expenseID: Int?
    var status: String?
    var statusBy: Int?
    var statusByDesignation: String?
    var comment: String?
    var reply: String?
    var statusDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case expenseID = "expenseId"
        case status
        case statusBy
        case statusByDesignation
        case comment
        case reply
        case statusDate
    }
}


// MARK: - ExpenseAttachment
struct ExpenseAttachment: Codable {
    var id: Int?
    var expenseId: Int?
    var attachment: String?
}


// MARK: - TravelMode
struct TravelMode: Codable {
    var id: Int?
    var travelMode: String?
    var isTicket: Int?
    var isFuel: Int?
}


// MARK: - Category
struct ExpensesCategory: Codable {
    var name: String?
    var slug: String?
    var isTravel: Int?
    var isViolate: Int?
    var isHq: Int?
    var isOS: Int?

    enum CodingKeys: String, CodingKey {
        case name, slug
        case isTravel = "is_travel"
        case isViolate = "is_violate"
        case isHq = "is_hq"
        case isOS = "is_os"
    }
}


// MARK: - Violated
struct Violated: Codable {
    var id: Int?
    var designationID: Int?
    var travelModeOutstationID: Int?
    var travelModeLocalID: Int?
    var aAccommodation: String?
    //var aAccommodation: Double?
    var aFoodAllowance: String?
    //var aFoodAllowance: Double?
    var aAccommodationIsBill: Int?
    var aFoodAllowanceIsBill: Int?
    var bAccommodation: String?
    //var bAccommodation: Double?
    var bFoodAllowance: String?
    //var bFoodAllowance: Double?
    var bAccommodationIsBill: Int?
    var bFoodAllowanceIsBill: Int?
    var cAccommodation: String?
    //var cAccommodation: Double?
    var cFoodAllowance: String?
    //var cFoodAllowance: Double?
    var cAccommodationIsBill: Int?
    //var cFoodAllowanceIsBill: Int?
    var cFoodAllowanceIsBill: Double?
    //var foodAllowance: String?
    var foodAllowance: Double?
    //var travelModeLocal: String?
    var travelModeLocal: Double?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case designationID = "designation_id"
        case travelModeOutstationID = "travel_mode_outstation_id"
        case travelModeLocalID = "travel_mode_local_id"
        case aAccommodation = "a_accommodation"
        case aFoodAllowance = "a_food_allowance"
        case aAccommodationIsBill = "a_accommodation_is_bill"
        case aFoodAllowanceIsBill = "a_food_allowance_is_bill"
        case bAccommodation = "b_accommodation"
        case bFoodAllowance = "b_food_allowance"
        case bAccommodationIsBill = "b_accommodation_is_bill"
        case bFoodAllowanceIsBill = "b_food_allowance_is_bill"
        case cAccommodation = "c_accommodation"
        case cFoodAllowance = "c_food_allowance"
        case cAccommodationIsBill = "c_accommodation_is_bill"
        case cFoodAllowanceIsBill = "c_food_allowance_is_bill"
        case foodAllowance = "food_allowance"
        case travelModeLocal = "travel_mode_local"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
