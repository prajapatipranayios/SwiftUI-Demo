//
//  ApiResponseDVR.swift
//  Novasol Ingredients
//
//  Created by Auxano on 31/05/24.
//

import Foundation
import DynamicCodable

struct ApiResponseDVR: Codable {
    var status: Int?
    var result: ResponseDVR?
    var message: String
}

struct ResponseDVR: Codable {
    
    // DVR
    var dvr: [DVRUserList]?
    
    
    // Add Dvr
    var contacts: [ClientContact]?
    var products: [DvrProduct]?
    
    var dateValid: Int?
    
    
    enum CodingKeys: String, CodingKey {
        
        // DVR
        case dvr
        
        // Add Dvr
        case contacts
        case products
        
        case dateValid
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // DVR
        if let singleDvr = try? values.decode(DVRUserList.self, forKey: .dvr){
            dvr = [singleDvr]
        }
        else {
            dvr = try values.decodeIfPresent([DVRUserList].self, forKey: .dvr)
        }
        
        // Add Dvr
        contacts = try values.decodeIfPresent([ClientContact].self, forKey: .contacts)
        products = try values.decodeIfPresent([DvrProduct].self, forKey: .products)
        
        dateValid = try values.decodeIfPresent(Int.self, forKey: .dateValid)
        
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // DVR
            try container.encodeIfPresent(dvr, forKey: .dvr)
            
            // Add Dvr
            try container.encodeIfPresent(contacts, forKey: .contacts)
            try container.encodeIfPresent(products, forKey: .products)
            
            try container.encodeIfPresent(dateValid, forKey: .dateValid)
            
        }
        catch let err {
            print(err)
        }
    }
}
