//
//  ApiResponseExpenses.swift
//  Novasol Ingredients
//
//  Created by Auxano on 31/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseExpenses: Codable {
    var status: Int?
    var result: ResponseExpenses?
    var message: String
}

struct ResponseExpenses: Codable {
    
    // Expenses
    var expense: [UserExpenseListDetails]?
    var expenses: [UserExpenseListDetails]?
    
    
    // Add Expenses
    var category: [ExpensesCategory]?
    var violated: Violated?
    var expenseId: Int?
    var travelModes: [TravelMode]?
    var dateValid: Int?
    
    
    enum CodingKeys: String, CodingKey {
        
        // Expenses
        case expense
        case expenses
        
        // Add Expenses
        case category
        case violated
        case expenseId
        case travelModes
        
        case dateValid
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Expenses
        if let singleExpense = try? values.decode(UserExpenseListDetails.self, forKey: .expense){
            expense = [singleExpense]
        }
        else {
            expense = try values.decodeIfPresent([UserExpenseListDetails].self, forKey: .expense)
        }
        expenses = try values.decodeIfPresent([UserExpenseListDetails].self, forKey: .expenses)
        
        // Add Expenses
        category = try values.decodeIfPresent([ExpensesCategory].self, forKey: .category)
        violated = try values.decodeIfPresent(Violated.self, forKey: .violated)
        expenseId = try values.decodeIfPresent(Int.self, forKey: .expenseId)
        travelModes = try values.decodeIfPresent([TravelMode].self, forKey: .travelModes)
        
        dateValid = try values.decodeIfPresent(Int.self, forKey: .dateValid)
        
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Expenses
            try container.encodeIfPresent(expense, forKey: .expense)
            try container.encodeIfPresent(expenses, forKey: .expenses)
            
            // Add Dvr
            try container.encodeIfPresent(category, forKey: .category)
            try container.encodeIfPresent(violated, forKey: .violated)
            try container.encodeIfPresent(expenseId, forKey: .expenseId)
            try container.encodeIfPresent(travelModes, forKey: .travelModes)
            
            try container.encodeIfPresent(dateValid, forKey: .dateValid)
            
        }
        catch let err {
            print(err)
        }
    }
}
