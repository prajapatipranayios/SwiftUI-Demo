//
//  ApiResponseTarget.swift
//  Novasol Ingredients
//
//  Created by Auxano on 31/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseTarget: Codable {
    var status: Int?
    var result: ResponseTarget?
    var message: String
}

struct ResponseTarget: Codable {
    
    // Target
    var categories: [Category]?
    var employee: [Employee]?
    var target: [Target]?
    var total: TargetTotal?
    
    
    enum CodingKeys: String, CodingKey {
        
        // Target
        case categories
        case employee
        case target
        case total
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Target
        categories = try values.decodeIfPresent([Category].self, forKey: .categories)
        employee = try values.decodeIfPresent([Employee].self, forKey: .employee)
        target = try values.decodeIfPresent([Target].self, forKey: .target)
        total = try values.decodeIfPresent(TargetTotal.self, forKey: .total)
        
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Target
            try container.encodeIfPresent(categories, forKey: .categories)
            try container.encodeIfPresent(employee, forKey: .employee)
            try container.encodeIfPresent(target, forKey: .target)
            try container.encodeIfPresent(total, forKey: .total)
            
        }
        catch let err {
            print(err)
        }
    }
}
