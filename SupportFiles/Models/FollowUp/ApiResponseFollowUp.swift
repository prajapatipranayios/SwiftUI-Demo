//
//  ApiResponseFollowUp.swift
//  Novasol Ingredients
//
//  Created by Auxano on 09/07/24.
//

import Foundation
import DynamicCodable

struct ApiResponseFollowUp: Codable {
    var status: Int?
    var result: ResponseFollowUp?
    var message: String
}

struct ResponseFollowUp: Codable {
    
    // Follow Up
    var trailReport: ResultTrailReport?
    var trailReportId: Int?
    
    enum CodingKeys: String, CodingKey {
        
        // Follow Up
        case trailReport
        case trailReportId
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Sales Orders
        //counts = try values.decodeIfPresent([String: Int].self, forKey: .counts)
        trailReport = try values.decodeIfPresent(ResultTrailReport.self, forKey: .trailReport)
        trailReportId = try values.decodeIfPresent(Int.self, forKey: .trailReportId)
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Sales Orders
            try container.encodeIfPresent(trailReport, forKey: .trailReport)
            try container.encodeIfPresent(trailReportId, forKey: .trailReportId)
        }
        catch let err {
            print(err)
        }
    }
}
