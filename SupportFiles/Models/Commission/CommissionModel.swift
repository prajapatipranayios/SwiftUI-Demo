//
//  MTPModel.swift
//  Novasol Ingredients
//
//  Created by Auxano on 26/07/24.
//

import Foundation



// MARK: - ResultDatum
struct CommissionData: Codable {
    var orderInfo: OrderInfo?
    var data: [CommissionOrderData]?
}

// MARK: - DatumDatum
struct CommissionOrderData: Codable {
    var categoryName: String?
    var userID: Int?
    var categoryID: Int?
    var productID: Int?
    var orderDate: String?
    var commission: Int?
    var status: Int?
    var orderCode: String?
    var name: String?
    var orderID: Int?
    var month: String?
    var employeeName: String?
    var paidCommission: Int?
    var remainCommission: Int?
    var requestStatus: Int?
    var remark: String?

    enum CodingKeys: String, CodingKey {
        case categoryName
        case userID = "userId"
        case categoryID = "categoryId"
        case productID = "productId"
        case orderDate, commission, status, orderCode, name
        case orderID = "orderId"
        case month, employeeName, paidCommission, remainCommission, requestStatus, remark
    }
}

// MARK: - OrderInfo
struct OrderInfo: Codable {
    var orderID: Int?
    var orderCode: String?
    var bmName: String?
    var orderDate: String?
    var paidCommission: Int?
    var remainCommission: Int?
    var requestStatus: Int?
    var orderStatus: Int?
    var remark: String?

    enum CodingKeys: String, CodingKey {
        case orderID = "orderId"
        case orderCode, bmName, orderDate, paidCommission, remainCommission, requestStatus, orderStatus, remark
    }
}
