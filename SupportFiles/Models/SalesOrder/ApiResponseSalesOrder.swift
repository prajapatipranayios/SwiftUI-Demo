//
//  ApiResponseSalesOrder.swift
//  Novasol Ingredients
//
//  Created by Auxano on 28/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseSalesOrder: Codable {
    var status: Int?
    var result: ResponseSalesOrder?
    var message: String
}

struct ResponseSalesOrder: Codable {
    
    // Sales Orders
    var counts: OrderCount?
    var orderCounts: [SalesOrderCount]?
    var ordersList: [SalesOrdersList]?
    var hasMore: Bool?
    var rejectReason: [String]?
    
    // Add Order
    var businessPartnerAddress: [BusinessPartnerAddress]?
    var bookingPoints: [BookingPoint]?
    var gstResult: GstResult?
    var followUpDays: [String]?
    var customMaxDays: Int?
    var orderId: Int?
    
    // Draft Order
    var draftOrders: [DraftOrder]?
    
    enum CodingKeys: String, CodingKey {
        
        // Sales Orders
        case counts
        case orderCounts
        case ordersList
        case hasMore
        case rejectReason
        
        // Add Order
        case businessPartnerAddress
        case bookingPoints
        case gstResult
        case followUpDays
        case customMaxDays
        case orderId
        
        // Draft Order
        case draftOrders
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
        
        // Add Order
        businessPartnerAddress = try values.decodeIfPresent([BusinessPartnerAddress].self, forKey: .businessPartnerAddress)
        bookingPoints = try values.decodeIfPresent([BookingPoint].self, forKey: .bookingPoints)
        gstResult = try values.decodeIfPresent(GstResult.self, forKey: .gstResult)
        followUpDays = try values.decodeIfPresent([String].self, forKey: .followUpDays)
        customMaxDays = try values.decodeIfPresent(Int.self, forKey: .customMaxDays)
        orderId = try values.decodeIfPresent(Int.self, forKey: .orderId)
        
        // Draft Order
        draftOrders = try values.decodeIfPresent([DraftOrder].self, forKey: .draftOrders)
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
            
            // Add Order
            try container.encodeIfPresent(businessPartnerAddress, forKey: .businessPartnerAddress)
            try container.encodeIfPresent(bookingPoints, forKey: .bookingPoints)
            try container.encodeIfPresent(gstResult, forKey: .gstResult)
            try container.encodeIfPresent(followUpDays, forKey: .followUpDays)
            try container.encodeIfPresent(customMaxDays, forKey: .customMaxDays)
            try container.encodeIfPresent(orderId, forKey: .orderId)
            
            // Draft Order
            try container.encodeIfPresent(draftOrders, forKey: .draftOrders)
        }
        catch let err {
            print(err)
        }
    }
}
