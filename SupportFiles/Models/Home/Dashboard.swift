//
//  Dashboard.swift
//  GE Sales
//
//  Created by Auxano on 17/04/24.
//

import Foundation

// MARK: - Dashboard
struct Dashboard : Codable {
    var products: Int?
    var businessPartners: Int?
    var salesOrder: Int?
    var sampleRequest: Int?
    var quotation: Int?
    var proformaInvoice: Int?
    var followUp: Int?
    var draftOrder: Int?
    var notification: Int?
    var pendingOrder: Int?
}

// MARK: - Order
struct Order: Codable {
    var orderID: String?
    var roleID: Int?
    var employeeName: String?
    var employeeID: Int?
    var totalOrders: Int?
    var targetStatus: Int?
    var totalAmount: Double?
    var materialDispatchedCount: Int?
    var backOrderCount: Int?
    
    
    // Sales Order Report Details
    var codeID, industryType, orderStatus: String?
    var id: Int?
    var name, cityName, stateName: String?
    var companyType: Int?
    var stateID: Int?
    var email, categoryIDS, categoryName: String?
    var orderTotal: Int?
    var orderIDS: String?
    var branchID, basicTotal: Double?
    var categories: [Category]?
    var bmOrderStatus: String?
    
    enum CodingKeys: String, CodingKey {
        case orderID = "orderId"
        case roleID = "roleId"
        case employeeName
        case employeeID = "employeeId"
        case totalOrders, targetStatus, totalAmount, materialDispatchedCount, backOrderCount
        
        // Sales Order Report Details
        case codeID = "codeId"
        case industryType, orderStatus, id, name, cityName, stateName, companyType
        case stateID = "stateId"
        case email
        case categoryIDS = "categoryIds"
        case categoryName, orderTotal
        case orderIDS = "orderIds"
        case branchID = "branchId"
        case basicTotal, categories, bmOrderStatus
    }
}


// MARK: - Total
struct Total: Codable {
    let orders: Int?
    let amount: Double?
}

//// MARK: - Category
//struct Category: Codable {
//    let name, productUnit, productQty: String?
//    let totalAmount: Int?
//}
