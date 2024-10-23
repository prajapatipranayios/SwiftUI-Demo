//
//  ApiResponseSampleRequest.swift
//  Novasol Ingredients
//
//  Created by Auxano on 31/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseSampleRequest: Codable {
    var status: Int?
    var result: ResponseSampleRequest?
    var message: String
}

struct ResponseSampleRequest: Codable {
    
    // Sales Orders
    var counts: OrderCount?
    var orderCounts: [SalesOrderCount]?
    var ordersList: [SalesOrdersList]?
    
    var remaindersCount: Int?
    var otherProductBrand: [String]?
    var isAddOtherProduct: Int?
    
    var hasMore: Bool?
    var rejectReason: [String]?
    
    enum CodingKeys: String, CodingKey {
        
        // Sales Orders
        case counts
        case orderCounts
        case ordersList
        case hasMore
        case rejectReason
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Sales Orders
        //counts = try values.decodeIfPresent([String: Int].self, forKey: .counts)
        counts = try values.decodeIfPresent(OrderCount.self, forKey: .counts)
        orderCounts = try values.decodeIfPresent([SalesOrderCount].self, forKey: .orderCounts)
        ordersList = try values.decodeIfPresent([SalesOrdersList].self, forKey: .ordersList)
        hasMore = try values.decodeIfPresent(Bool.self, forKey: .hasMore)
        rejectReason = try values.decodeIfPresent([String].self, forKey: .rejectReason)
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Sales Orders
            try container.encodeIfPresent(counts, forKey: .counts)
            try container.encodeIfPresent(orderCounts, forKey: .orderCounts)
            try container.encodeIfPresent(ordersList, forKey: .ordersList)
            try container.encodeIfPresent(hasMore, forKey: .hasMore)
            try container.encodeIfPresent(rejectReason, forKey: .rejectReason)
        }
        catch let err {
            print(err)
        }
    }
}
