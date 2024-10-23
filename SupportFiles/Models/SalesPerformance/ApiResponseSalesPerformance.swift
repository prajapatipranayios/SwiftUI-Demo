//
//  ApiResponseSalesPerformance.swift
//  Novasol Ingredients
//
//  Created by Auxano on 31/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseSalesPerformance: Codable {
    var status: Int?
    var result: ResponseSalesPerformance?
    var message: String
}

struct ResponseSalesPerformance: Codable {
    
    // Sales Performance
    var employee: [Employee]?
    var kra: [Kra]?
    
    
    
    enum CodingKeys: String, CodingKey {
        
        // Sales Performance
        case employee
        case kra
        
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Sales Performance
        employee = try values.decodeIfPresent([Employee].self, forKey: .employee)
        kra = try values.decodeIfPresent([Kra].self, forKey: .kra)
        
        
        
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Sales Performance
            try container.encodeIfPresent(employee, forKey: .employee)
            try container.encodeIfPresent(kra, forKey: .kra)
            
            
        }
        catch let err {
            print(err)
        }
    }
}
