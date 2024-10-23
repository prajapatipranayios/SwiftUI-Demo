//
//  ApiResponseExpenses.swift
//  Novasol Ingredients
//
//  Created by Auxano on 31/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseCommission: Codable {
    var status: Int?
    var result: ResponseCommission?
    var message: String
}

struct ResponseCommission: Codable {
    
    // Commission
    var employees: [Employee]?
    var data: [CommissionData]?
    var path: String?
    
    
    enum CodingKeys: String, CodingKey {
        
        // Commission
        case employees
        case data
        case path
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Commission
        employees = try values.decodeIfPresent([Employee].self, forKey: .employees)
        data = try values.decodeIfPresent([CommissionData].self, forKey: .data)
        path = try values.decodeIfPresent(String.self, forKey: .path)
        
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Commission
            try container.encodeIfPresent(employees, forKey: .employees)
            try container.encodeIfPresent(data, forKey: .data)
            try container.encodeIfPresent(path, forKey: .path)
            
        }
        catch let err {
            print(err)
        }
    }
}
