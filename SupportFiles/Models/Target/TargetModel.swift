//
//  Model.swift
//  Novasol Ingredients
//
//  Created by Auxano on 26/07/24.
//

import Foundation


// MARK: - Target
struct Target: Codable {
    
    var groupName: String?
    var data: [TargetData]?
    
    var fullName: String?
    var userID: Int?
    var zone: String?
    var actualTarget: Double?
    var achievedTarget: Double?
    var targetStatus: Int?
    var name: String?
    var categoryID: Int?
    var unit: String?
    var categoryGroup: String?
    var unitTarget: Double?
    var unitTargetAchieved: Double?
    var unitTargetStatus: Int?
    var month: Int?
    var quarter: Int?
    var year: Int?
    var targetPer: String?
    var targetRemaining: String?
    var unitPer: String?
    var unitRemaining: String?
    
    var employeeData: EmployeeData?
    
    
    enum CodingKeys: String, CodingKey {
        
        case groupName
        case data
        
        case fullName
        case userID = "userId"
        case zone, actualTarget, achievedTarget, targetStatus, name
        case categoryID = "categoryId"
        case unit, categoryGroup, unitTarget, unitTargetAchieved, unitTargetStatus, month, quarter, year, targetPer, targetRemaining, unitPer, unitRemaining
        
        case employeeData
    }
    
    // Initializer to map from TargetData
    init(from targetData: TargetData) {
        
        // Default values for fields that don't exist in TargetData
        self.groupName = nil
        self.data = nil
        
        
        self.fullName = targetData.fullName
        self.userID = targetData.userID
        self.zone = targetData.zone
        self.actualTarget = targetData.actualTarget
        self.achievedTarget = targetData.achievedTarget
        self.targetStatus = targetData.targetStatus
        self.name = targetData.name
        self.categoryID = targetData.categoryID
        self.unit = targetData.unit
        self.categoryGroup = targetData.categoryGroup
        self.unitTarget = targetData.unitTarget
        self.unitTargetAchieved = targetData.unitTargetAchieved
        self.unitTargetStatus = targetData.unitTargetStatus
        self.month = targetData.month
        self.quarter = targetData.quarter
        self.year = targetData.year
        self.targetPer = targetData.targetPer
        self.targetRemaining = targetData.targetRemaining
        self.unitPer = targetData.unitPer
        self.unitRemaining = targetData.unitRemaining
        
        self.employeeData = nil
    }
    
}


// MARK: - Datum
struct TargetData: Codable {
    
    var fullName: String?
    var userID: Int?
    var zone: String?
    var actualTarget: Double?
    var achievedTarget: Double?
    var targetStatus: Int?
    var name: String?
    var categoryID: Int?
    var unit: String?
    var categoryGroup: String?
    var unitTarget: Double?
    var unitTargetAchieved: Double?
    var unitTargetStatus: Int?
    var month: Int?
    var quarter: Int?
    var year: Int?
    var targetPer: String?
    var targetRemaining: String?
    var unitPer: String?
    var unitRemaining: String?
    
    var monthYear: String?
    
    
    
    enum CodingKeys: String, CodingKey {
        case fullName
        case userID = "userId"
        case zone, actualTarget, achievedTarget, targetStatus, name
        case categoryID = "categoryId"
        case unit, categoryGroup, unitTarget, unitTargetAchieved, unitTargetStatus, month, quarter, year, targetPer, targetRemaining, unitPer, unitRemaining
        
        case monthYear
    }
}


// MARK: - Total
struct TargetTotal: Codable {
    
    var unitTargetTotal: Double?
    var actualTargetTotal: Double?
    var unitTargetAchievedTotal: Double?
    var achievedTargetTotal: Double?
}


// MARK: - EmployeeData
struct EmployeeData: Codable {
    
    var monthYear: String?
    var fullName: String?
    var targetTotal: Double?
    var financialQuarterMonths: String?
}
