//
//  MTPModel.swift
//  Novasol Ingredients
//
//  Created by Auxano on 26/07/24.
//

import Foundation


// MARK: - MTPCalendarData
struct MTPCalendarData: Codable {
    var date: String?
    var employee: [Employee]?
}


// MARK: - Employee
/****struct Employee: Codable {
    let id, userId: Int?
    let planDate, orgPlanDate: String?
    let city: city?
    let reportURL: String?
    let masterId, estimatedCost, oldEstimatedCost, statusBy: Int?
    let employeeAction: Int?
    let estimatedCostComment: String?
    let fullname: String?
    let reply, objectives: String?
    let status: String?
    let startDate: String?
    let endDate: String?
    let isLeave: Int?
    let remark, leaveType: String?
    let isWorkingFromHome: Int?
    let comment: String?
    let roleId: Int?
    let whoms: [Whom]?
}   //  */


// MARK: - Employee
struct Whom: Codable {
    var mtpId: Int?
    var userId: Int?
    var otherName: String?
    var companyName: String?
    var userName: String?
}


// MARK: - DataResult
struct DataResult: Codable {
    var data: [DataMonth]?
    var pdfUrl: String?
}

// MARK: - Datum
struct DataMonth: Codable {
    var month: String?
    var zone: [Zone]?
    var monthTotal: Double?
}

// MARK: - Zone
struct Zone: Codable {
    var zoneName: String?
    var employee: [Employee]?
    var zoneTotal: Double?
}

//// MARK: - Employee
//struct Employee: Codable {
//    let month: String?
//    let id: Int?
//    let fullname, zoneName: String?
//    let estimatedCost: Int?
//}


// MARK: - Google City Info
struct GoogleCityInfo {
    var name: String?
    var placeID: String?
    var state: String?
}


// MARK: - CityInfo
struct CityInfo: Codable {
    var id: String?
    var name: String?
    var state: String?
}


// MARK: - CityType
struct CityType: Codable {
    var cityName: String?
    var category: String?
}
