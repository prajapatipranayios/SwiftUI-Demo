//
//  ApiResponseSampleRequest.swift
//  Novasol Ingredients
//
//  Created by Auxano on 31/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseMTP: Codable {
    var status: Int?
    var result: ResponseMTP?
    var message: String
}

struct ResponseMTP: Codable {
    
    // MTP
    var data: [MTPCalendarData]?
    var mtp: [Employee]?
    var dataResult: DataResult?
    
    // Add MTP
    var employees: [Employee]?
    var dates: [String]?
    var dateValid: Int?
    
    
    enum CodingKeys: String, CodingKey {
        
        // MTP
        case data
        case mtp
        case dataResult
        
        // Add MTP
        case employees
        case dates
        case dateValid
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // MTP
        data = try values.decodeIfPresent([MTPCalendarData].self, forKey: .data)
        mtp = try values.decodeIfPresent([Employee].self, forKey: .mtp)
        dataResult = try values.decodeIfPresent(DataResult.self, forKey: .dataResult)
        
        // Add MTP
        employees = try values.decodeIfPresent([Employee].self, forKey: .employees)
        dates = try values.decodeIfPresent([String].self, forKey: .dates)
        dateValid = try values.decodeIfPresent(Int.self, forKey: .dateValid)
        
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // MTP
            try container.encodeIfPresent(data, forKey: .data)
            try container.encodeIfPresent(mtp, forKey: .mtp)
            try container.encodeIfPresent(dataResult, forKey: .dataResult)
            
            // Add MTP
            try container.encodeIfPresent(employees, forKey: .employees)
            try container.encodeIfPresent(dates, forKey: .dates)
            try container.encodeIfPresent(dateValid, forKey: .dateValid)
            
        }
        catch let err {
            print(err)
        }
    }
}
