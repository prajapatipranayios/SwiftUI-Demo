//
//  Warehouse.swift
//  GE Sales
//
//  Created by Auxano on 17/04/24.
//

import Foundation

struct Warehouse : Codable {
    var id : Int?
    var branchName : String?
    var branchCode : String?
    var branchSeries : Int?
    var pivot : Pivot?

//    enum CodingKeys: String, CodingKey {
//        case id = "id"
//        case branchName = "branchName"
//        case branchCode = "branchCode"
//        case branchSeries = "branchSeries"
//        case pivot = "pivot"
//    }

//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        id = try values.decodeIfPresent(Int.self, forKey: .id)
//        branchName = try values.decodeIfPresent(String.self, forKey: .branchName)
//        branchCode = try values.decodeIfPresent(String.self, forKey: .branchCode)
//        branchSeries = try values.decodeIfPresent(Int.self, forKey: .branchSeries)
//        pivot = try values.decodeIfPresent(Pivot.self, forKey: .pivot)
//    }
}

struct Pivot : Codable {
    var userId : Int?
    var warehouseId : Int?

//    enum CodingKeys: String, CodingKey {
//        case userId = "userId"
//        case warehouseId = "warehouseId"
//    }

//    init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: CodingKeys.self)
//        userId = try values.decodeIfPresent(Int.self, forKey: .userId)
//        warehouseId = try values.decodeIfPresent(Int.self, forKey: .warehouseId)
//    }
}
