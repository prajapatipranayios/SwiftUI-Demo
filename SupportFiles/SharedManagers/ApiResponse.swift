//
//  ApiResponse.swift
//
//  Created by Pranay on 23/10/24.
//

import Foundation

struct ApiResponse: Codable {
    var status: Int?
    var result: Response?
    var message: String
}

struct Response: Codable {
    
    // Login
    
    
    // Home
    var userDetail : UserDetail?
    var hasmore: Bool?
    
    enum CodingKeys: String, CodingKey {
        
        // Home
        case userDetail
        case hasmore
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Home
        userDetail = try values.decodeIfPresent(UserDetail.self, forKey: .userDetail)
        hasmore = try values.decodeIfPresent(Bool.self, forKey: .hasmore)
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Home
            try container.encodeIfPresent(userDetail, forKey: .userDetail)
            try container.encodeIfPresent(hasmore, forKey: .hasmore)
        }
        catch let err {
            print(err)
        }
    }
    
}

struct UserDetail : Codable {
    
    var id : Int?
    var roleId : Int?
    var firstName : String?
    var lastName : String?
    var email : String?
    var image : String?
    var isActive : Bool?
    var userDesignation : String?
    var token: String?
    
    enum CodingKeys: String, CodingKey {
        case id, roleId, firstName, lastName, email, image, isActive, userDesignation, token
    }
    
    // MARK: - Custom Decoding
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode values that might be Int or String types
        id = try decodeIntOrString(forKey: .id, from: container)
        roleId = try decodeIntOrString(forKey: .roleId, from: container)
        isActive = try decodeBoolOrString(forKey: .isActive, from: container)
        if isActive ?? false || !(isActive ?? true) {
            isActive = try decodeBoolOrInt(forKey: .isActive, from: container)
        }
        
        // Decode other properties
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        userDesignation = try container.decodeIfPresent(String.self, forKey: .userDesignation)
        token = try container.decodeIfPresent(String.self, forKey: .token)
    }
}


// MARK: - Global Helper Functions for Decoding Flexible Types

/// Decodes a value that might be either an Int or a String, returning it as an Int if possible.
func decodeIntOrString<Key: CodingKey>(forKey key: Key, from container: KeyedDecodingContainer<Key>) throws -> Int? {
    if let intValue = try? container.decode(Int.self, forKey: key) {
        return intValue
    } else if let stringValue = try? container.decode(String.self, forKey: key), let intFromString = Int(stringValue) {
        return intFromString
    }
    return nil
}

/// Decodes a value that might be either an Int or a String, returning it as an Int if possible.
func decodeStringOrInt<Key: CodingKey>(forKey key: Key, from container: KeyedDecodingContainer<Key>) throws -> String? {
    if let strValue = try? container.decode(String.self, forKey: key) {
        return strValue
    } else if let intValue = try? container.decode(Int.self, forKey: key) {
        return String(intValue)
    }
    return nil
}

/// Decodes a value that might be either a Bool or a String, returning it as a Bool if possible.
func decodeBoolOrInt<Key: CodingKey>(forKey key: Key, from container: KeyedDecodingContainer<Key>) throws -> Bool? {
    if let boolValue = try? container.decode(Bool.self, forKey: key) {
        return boolValue
    } else if let intValue = try? container.decode(Int.self, forKey: key) {
        if intValue == 1 {
            return true
        } else if intValue == 0 {
            return false
        }
    }
    return nil
}

/// Decodes a value that might be either a Bool or a String, returning it as a Bool if possible.
func decodeBoolOrString<Key: CodingKey>(forKey key: Key, from container: KeyedDecodingContainer<Key>) throws -> Bool? {
    if let boolValue = try? container.decode(Bool.self, forKey: key) {
        return boolValue
    } else if let stringValue = try? container.decode(String.self, forKey: key).lowercased() {
        if stringValue == "true" {
            return true
        } else if stringValue == "false" {
            return false
        }
    }
    return nil
}
