//
//  MTPModel.swift
//  Novasol Ingredients
//
//  Created by Auxano on 26/07/24.
//

import Foundation



// MARK: - Kra
struct Kra: Codable {
    var fullName: String?
    var employeeCode: String?
    var id: Int?
    var userID: Int?
    var createdBy: Int?
    var label: String?
    var actualSale: Double?
    var gpSales: String?
    var totalExp: Double?
    var projectedSale: Double?
    var projectedSaleQuarter: String?
    var quarter: String?
    var year: Int?
    var createdAt: String?
    var updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case fullName, employeeCode, id
        case userID = "userId"
        case createdBy, label, actualSale, gpSales, totalExp, projectedSale, projectedSaleQuarter, quarter, year, createdAt, updatedAt
    }
}
