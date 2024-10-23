//
//  ApiResponseSampleRequest.swift
//  Novasol Ingredients
//
//  Created by Auxano on 31/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseDashboard: Codable {
    var status: Int?
    var result: ResponseDashboard?
    var message: String
}

struct ResponseDashboard: Codable {
    
    // Dashboard
    var path: String?
    var employee: [Employee]?
    
    var orders: [Order]?
    var hasMore: Bool?
    var total: Total?
    
    var productList: [ProductList]?
    
    enum CodingKeys: String, CodingKey {
        
        // Daashboard
        case path
        case employee
        
        case orders
        case hasMore
        case total
        
        case productList
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Dashboard
        path = try values.decodeIfPresent(String.self, forKey: .path)
        employee = try values.decodeIfPresent([Employee].self, forKey: .employee)
        
        orders = try values.decodeIfPresent([Order].self, forKey: .orders)
        hasMore = try values.decodeIfPresent(Bool.self, forKey: .hasMore)
        total = try values.decodeIfPresent(Total.self, forKey: .total)
        
        productList = try values.decodeIfPresent([ProductList].self, forKey: .productList)
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Dashboard
            try container.encodeIfPresent(path, forKey: .path)
            try container.encodeIfPresent(employee, forKey: .employee)
            
            try container.encodeIfPresent(orders, forKey: .orders)
            try container.encodeIfPresent(hasMore, forKey: .hasMore)
            try container.encodeIfPresent(total, forKey: .total)
            
            try container.encodeIfPresent(productList, forKey: .productList)
        }
        catch let err {
            print(err)
        }
    }
}
