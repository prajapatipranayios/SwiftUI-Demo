//
//  ApiResponse.swift
//  - This class is used to manage & parse API Response

//  Tussly
//
//  Created by Auxano on 19/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import DynamicCodable

struct ApiResponse: Codable {
    var status: Int?
    var result: Response?
    var message: String
}

struct Response: Codable {
    
    // Login
    
    
    // Home
    var userDetail : UserDetail?
    var geDashboard : Dashboard?
    var gfwDashboard : Dashboard?
    var bothDashboard : Dashboard?
    var categoryList: [CategoryList]?
    var branch: [Branch]?
    
    // ProductH
    var productList: [ProductList]?
    var hasMore: Bool?
    var orderDetail: OrderDetail?
    var newProduct: ProductList?
    
    // BusinessP
    var businessPartners: [BusinessPartner]?        //  in Dashboard
    var employees: [Employee]?
    var businessPartnerDetail: BusinessPartnerDetail?
    var order_detail: [BusinessPOrderDetail]?
    var qiList: [BusinessPOrderDetail]?
    var piList: [BusinessPOrderDetail]?
    var sampleRequestList: [BusinessPOrderDetail]?
    var fileURL: String?
    var transporters: Transporter?
    var teamMembers: [TeamMember]?
    var categories: [Category]?
    
    // Sales Orders
    var orderedBusinessPartners: [OrderedBusinessPartner]?
    var orderedEmployees: [OrderedEmployee]?
    
    // Dashboard
    var path: String?
    
    
    // MTP
    var mtp: Employee?
    
    
    enum CodingKeys: String, CodingKey {
        
        // Home
        case userDetail
        case geDashboard
        case gfwDashboard
        case bothDashboard
        case categoryList
        
        // ProductH
        case productList
        case hasMore
        case orderDetail
        case newProduct
        
        // BusinessP
        case businessPartners
        case employees
        case businessPartnerDetail = "business_partner_detail"
        case order_detail
        case qiList = "qi_list"
        case piList = "pi_list"
        case sampleRequestList = "sample_request_list"
        case fileURL
        case branch
        case teamMembers
        case categories
        
        // Sales Orders
        case orderedBusinessPartners
        case orderedEmployees
        
        // Daashboard
        case path
        
        
        // MTP
        case mtp
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Home
        userDetail = try values.decodeIfPresent(UserDetail.self, forKey: .userDetail)
        geDashboard = try values.decodeIfPresent(Dashboard.self, forKey: .geDashboard)
        gfwDashboard = try values.decodeIfPresent(Dashboard.self, forKey: .gfwDashboard)
        bothDashboard = try values.decodeIfPresent(Dashboard.self, forKey: .bothDashboard)
        categoryList = try values.decodeIfPresent([CategoryList].self, forKey: .categoryList)
        
        // ProductH
        productList = try values.decodeIfPresent([ProductList].self, forKey: .productList)
        hasMore = try values.decodeIfPresent(Bool.self, forKey: .hasMore)
        orderDetail = try values.decodeIfPresent(OrderDetail.self, forKey: .orderDetail)
        newProduct = try values.decodeIfPresent(ProductList.self, forKey: .newProduct)
        
        // BusinessP
        businessPartners = try values.decodeIfPresent([BusinessPartner].self, forKey: .businessPartners)
        employees = try values.decodeIfPresent([Employee].self, forKey: .employees)
        businessPartnerDetail = try values.decodeIfPresent(BusinessPartnerDetail.self, forKey: .businessPartnerDetail)
        order_detail = try values.decodeIfPresent([BusinessPOrderDetail].self, forKey: .order_detail)
        qiList = try values.decodeIfPresent([BusinessPOrderDetail].self, forKey: .qiList)
        piList = try values.decodeIfPresent([BusinessPOrderDetail].self, forKey: .piList)
        sampleRequestList = try values.decodeIfPresent([BusinessPOrderDetail].self, forKey: .sampleRequestList)
        fileURL = try values.decodeIfPresent(String.self, forKey: .fileURL)
        branch = try values.decodeIfPresent([Branch].self, forKey: .branch)
        teamMembers = try values.decodeIfPresent([TeamMember].self, forKey: .teamMembers)
        categories = try values.decodeIfPresent([Category].self, forKey: .categories)
        
        // Sales Orders
        orderedBusinessPartners = try values.decodeIfPresent([OrderedBusinessPartner].self, forKey: .orderedBusinessPartners)
        orderedEmployees = try values.decodeIfPresent([OrderedEmployee].self, forKey: .orderedEmployees)
        
        // Dashboard
        path = try values.decodeIfPresent(String.self, forKey: .path)
        
        
        // MTP
        mtp = try values.decodeIfPresent(Employee.self, forKey: .mtp)
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Home
            try container.encodeIfPresent(userDetail, forKey: .userDetail)
            try container.encodeIfPresent(geDashboard, forKey: .geDashboard)
            try container.encodeIfPresent(gfwDashboard, forKey: .gfwDashboard)
            try container.encodeIfPresent(bothDashboard, forKey: .bothDashboard)
            try container.encodeIfPresent(categoryList, forKey: .categoryList)
            
            // ProductH
            try container.encodeIfPresent(productList, forKey: .productList)
            try container.encodeIfPresent(hasMore, forKey: .hasMore)
            try container.encodeIfPresent(orderDetail, forKey: .orderDetail)
            try container.encodeIfPresent(newProduct, forKey: .newProduct)
            
            // BusinessP
            try container.encodeIfPresent(businessPartners, forKey: .businessPartners)
            try container.encodeIfPresent(employees, forKey: .employees)
            try container.encodeIfPresent(businessPartnerDetail, forKey: .businessPartnerDetail)
            try container.encodeIfPresent(order_detail, forKey: .order_detail)
            try container.encodeIfPresent(qiList, forKey: .qiList)
            try container.encodeIfPresent(piList, forKey: .piList)
            try container.encodeIfPresent(sampleRequestList, forKey: .sampleRequestList)
            try container.encodeIfPresent(fileURL, forKey: .fileURL)
            try container.encodeIfPresent(branch, forKey: .branch)
            try container.encodeIfPresent(teamMembers, forKey: .teamMembers)
            try container.encodeIfPresent(categories, forKey: .categories)
            
            // Sales Orders
            try container.encodeIfPresent(orderedBusinessPartners, forKey: .orderedBusinessPartners)
            try container.encodeIfPresent(orderedEmployees, forKey: .orderedEmployees)
            
            // Dashboard
            try container.encodeIfPresent(path, forKey: .path)
            
            
            // MTP
            try container.encodeIfPresent(mtp, forKey: .mtp)
        }
        catch let err {
            print(err)
        }
    }
}
