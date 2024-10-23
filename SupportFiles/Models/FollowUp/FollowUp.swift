//
//  FollowUp.swift
//  Novasol Ingredients
//
//  Created by Auxano on 09/07/24.
//

import Foundation


// MARK: - ResultTrailReport
struct ResultTrailReport: Codable {
    let id: Int?
    let orderCode: String?
    //let products: [BPOrderProduct]?
    let products: [ProductList]?
}

//// MARK: - TrailReportElement
//struct TrailReportElement: Codable {
//    var id: Int?
//    var orderProductID: Int?
//    var isTrail: Int?
//    var status: Int?
//    var reason: String?
//    let reportAttachments: [ReportAttachment]?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case orderProductID = "orderProductId"
//        case isTrail, status, reason
//        case reportAttachments
//    }
//}
//
//// MARK: - ReportAttachment
//struct ReportAttachment: Codable {
//    let id, trailReportID: Int?
//    let attachment: String?
//    let caption: String?
//
//    enum CodingKeys: String, CodingKey {
//        case id
//        case trailReportID = "trailReportId"
//        case attachment, caption
//    }
//}
