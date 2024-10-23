//
//  ProductH.swift
//  GE Sales
//
//  Created by Auxano on 22/04/24.
//

import Foundation

// MARK: - ProductList
struct ProductList: Codable {
    var id: Int?
    var productCode: String?
    var name: String?
    var showWarehouse: Int?
    var isNill: Int?
    var remark: String?
    var productUnit: String?
    var description: String?
    var unitPrice: Double?
    var inStock: Double?
    var tax: Double?
    var hsnNumber: String?
    var status: String?
    var companyType: Int?
    var categoryName: String?
    var lastPrice: Int?
    var categoryId: Int?
    var isOtherProduct: Int?
    var warehouseQty: Double?
    var inCommited: Double?
    var available: Double?
    var productWarehouse: [ProductWarehouse]?
    
    // Add Order from Sales.
    var commission: Int?
    var discountAmount: Double?
    var maxDiscount: Int?
    var productBasicPrice: String?
    
    //var productCode: String?
    var productId: Int?
    var productName: String?
    var productOldPrice: Double?
    var productTotal: Int?
    var questions: Questions?
    var storeQty: Int?
    var userCommission: Int?
    var userCommissionByCategory: [CategoryCommissionDetails]?
    
    var productPrice: Double?
    var discountPrice: Double?
    var quantity: Double?
    var productUnitMesurement: String?
    var moq: Double?
    var moqUnit: String?
    var packSize: String?
    
    // Dashboard
    var reMarkName: String?
    
    
    
    var ordersID: Int?
    var productDiscount: Double?
    var productRemark: String?
    var productTax: Double?
    var requiredQty: Double?
    var productQty: Double?
    var basicProductTotal: Double?
    var remainingQty: Int?
    var sgstPercentage: Double?
    var sgstAmount: Double?
    var cgstPercentage: Double?
    var cgstAmount: Double?
    var igstPercentage: Double?
    var igstAmount: Double?
    var gstType: String?
    var originalPrice: Double?
    var productHistory: [ProductHistory]?
    var rejectReason: String?
    
    /// Sample Order
    //var categoryID: Int?
    
    // Follow Up
    var trailReports: [TrailReports]?
    
    
    
    
    enum CodingKeys: String, CodingKey {
        case id, productCode, name, showWarehouse, isNill, remark
        case description, unitPrice, inStock, tax, hsnNumber, status, companyType, categoryName, lastPrice, categoryId, isOtherProduct, warehouseQty, inCommited, available, productWarehouse
        //case categoryID = "categoryId"
        case commission
        
        //case discountAmount = "discount_amount"
        case discountAmount
        case discount_amount
        
        case discountPrice = "discount_price"
        case maxDiscount
        
        //case packSize = "pack_size"
        case packSize
        case pack_size
        
        case productUnitMesurement
        case productBasicPrice = "product_basic_price"
        
        case product_code
        
        //case productID = "product_id"
        //case productID = "productId"
        case productId
        //case productID
        case product_id
        
        case moq
        
        //case productName = "product_name"
        case productName
        case product_name
        
        case productOldPrice = "product_old_price"
        
        //case productPrice = "product_price"
        case productPrice
        case product_price
        
        case quantity
        case productTotal = "product_total"
        
        //case productUnit = "product_unit"
        case productUnit
        case product_unit
        
        //case moqUnit = "moq_unit"
        case moqUnit
        case moq_unit
        
        case questions, storeQty, userCommission, userCommissionByCategory
        
        // Dashboard
        case reMarkName
        
        
        
        case ordersID = "ordersId"
        case productDiscount
        case productRemark
        case productTax
        case requiredQty
        case productQty
        case basicProductTotal
        case remainingQty
        case sgstPercentage
        case sgstAmount
        case cgstPercentage
        case cgstAmount
        case igstPercentage
        case igstAmount
        case gstType
        case originalPrice
        case productHistory
        case rejectReason
        
        /// Sample Order
        //case categoryID = "categoryId"
        
        // Follow Up
        case trailReports
        
    }
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // Home
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        
        if let value1 = try values.decodeIfPresent(String.self, forKey: .productCode) {
            productCode = value1
        }
        else if let value2 = try values.decodeIfPresent(String.self, forKey: .product_code) {
            productCode = value2
        } else {
            productCode = ""
        }
        
        name = try values.decodeIfPresent(String.self, forKey: .name)
        showWarehouse = try values.decodeIfPresent(Int.self, forKey: .showWarehouse)
        
        isNill = try values.decodeIfPresent(Int.self, forKey: .isNill)
        remark = try values.decodeIfPresent(String.self, forKey: .remark)
        
        if let stringValue1 = try? values.decode(String.self, forKey: .productUnit) {
            productUnit = stringValue1
        } else if let stringValue2 = try? values.decode(String.self, forKey: .product_unit) {
            productUnit = stringValue2
        } else {
            productUnit = ""
        }
        //productUnit = try values.decodeIfPresent(String.self, forKey: .productUnit)
        
        description = try values.decodeIfPresent(String.self, forKey: .description)
        unitPrice = try values.decodeIfPresent(Double.self, forKey: .unitPrice)
        inStock = try values.decodeIfPresent(Double.self, forKey: .inStock)
        tax = try values.decodeIfPresent(Double.self, forKey: .tax)
        hsnNumber = try values.decodeIfPresent(String.self, forKey: .hsnNumber)
        
        if let stringValue = try? values.decode(String.self, forKey: .status) {
            status = stringValue
        } else if let intValue = try? values.decode(Int.self, forKey: .status) {
            status = String(intValue)
        } else {
            status = ""
        }
        //status = try values.decodeIfPresent(Int.self, forKey: .status)
        
        companyType = try values.decodeIfPresent(Int.self, forKey: .companyType)
        categoryName = try values.decodeIfPresent(String.self, forKey: .categoryName)
        lastPrice = try values.decodeIfPresent(Int.self, forKey: .lastPrice)
        
        categoryId = try values.decodeIfPresent(Int.self, forKey: .categoryId)
        
        isOtherProduct = try values.decodeIfPresent(Int.self, forKey: .isOtherProduct)
        warehouseQty = try values.decodeIfPresent(Double.self, forKey: .warehouseQty)
        inCommited = try values.decodeIfPresent(Double.self, forKey: .inCommited)
        available = try values.decodeIfPresent(Double.self, forKey: .available)
        productWarehouse = try values.decodeIfPresent([ProductWarehouse].self, forKey: .productWarehouse)
        
        // Add Order from Sales.
        commission = try values.decodeIfPresent(Int.self, forKey: .commission)
        
        //discountAmount = try values.decodeIfPresent(Int.self, forKey: .discountAmount)
        if let value1 = try? values.decode(Double.self, forKey: .discountAmount) {
            discountAmount = value1
        }
        else if let value1 = try? values.decode(Double.self, forKey: .discount_amount) {
            discountAmount = value1
        }
        
        maxDiscount = try values.decodeIfPresent(Int.self, forKey: .maxDiscount)
        productBasicPrice = try values.decodeIfPresent(String.self, forKey: .productBasicPrice)
        
        //productId = try values.decodeIfPresent(String.self, forKey: .productId)
        if let value1 = try? values.decode(Int.self, forKey: .productId) {
            productId = value1
        }
        /*else if let value2 = try? values.decode(Int.self, forKey: .productID) {
            productId = value2
        }   //  */
        else if let value3 = try? values.decode(Int.self, forKey: .product_id) {
            productId = value3
        }
        else if let value4 = try? values.decode(String.self, forKey: .product_id) {
            productId = Int(value4)
        }
        else {
            productId = 0
        }
        
        //productName = try values.decodeIfPresent(String.self, forKey: .productName)
        
        if let strValue1 = try? values.decode(String.self, forKey: .productName) {
            productName = strValue1
        } else if let strValue2 = try? values.decode(String.self, forKey: .product_name) {
            productName = strValue2
        } else {
            productName = ""
        }
        
        productOldPrice = try values.decodeIfPresent(Double.self, forKey: .productOldPrice)
        productTotal = try values.decodeIfPresent(Int.self, forKey: .productTotal)
        questions = try values.decodeIfPresent(Questions.self, forKey: .questions)
        storeQty = try values.decodeIfPresent(Int.self, forKey: .storeQty)
        userCommission = try values.decodeIfPresent(Int.self, forKey: .userCommission)
        userCommissionByCategory = try values.decodeIfPresent([CategoryCommissionDetails].self, forKey: .userCommissionByCategory)
        
        //productPrice = try values.decodeIfPresent(Double.self, forKey: .productPrice)
        if let value1 = try? values.decode(Double.self, forKey: .productPrice) {
            productPrice = value1
        } else if let value2 = try? values.decode(Double.self, forKey: .product_price) {
            productPrice = value2
        } else {
            productPrice = 0
        }
        
        discountPrice = try values.decodeIfPresent(Double.self, forKey: .discountPrice)
        quantity = try values.decodeIfPresent(Double.self, forKey: .quantity)
        productUnitMesurement = try values.decodeIfPresent(String.self, forKey: .productUnitMesurement)
        moq = try values.decodeIfPresent(Double.self, forKey: .moq)
        
        //moqUnit = try values.decodeIfPresent(String.self, forKey: .moqUnit)
        if let value1 = try values.decodeIfPresent(String.self, forKey: .moqUnit) {
            moqUnit = value1
        }
        else if let value2 = try values.decodeIfPresent(String.self, forKey: .moq_unit) {
            moqUnit = value2
        }
        else {
            moqUnit = ""
        }
        
        //packSize = try values.decodeIfPresent(String.self, forKey: .packSize)
        if let value1 = try? values.decode(String.self, forKey: .packSize) {
            packSize = value1
        } else if let value2 = try? values.decode(String.self, forKey: .pack_size) {
            packSize = value2
        } else {
            packSize = ""
        }
       
        // Dashboard
        reMarkName = try values.decodeIfPresent(String.self, forKey: .reMarkName)
        
        
        ordersID = try values.decodeIfPresent(Int.self, forKey: .ordersID)
        productDiscount = try values.decodeIfPresent(Double.self, forKey: .productDiscount)
        productRemark = try values.decodeIfPresent(String.self, forKey: .productRemark)
        productTax = try values.decodeIfPresent(Double.self, forKey: .productTax)
        requiredQty = try values.decodeIfPresent(Double.self, forKey: .requiredQty)
        productQty = try values.decodeIfPresent(Double.self, forKey: .productQty)
        basicProductTotal = try values.decodeIfPresent(Double.self, forKey: .basicProductTotal)
        remainingQty = try values.decodeIfPresent(Int.self, forKey: .remainingQty)
        sgstPercentage = try values.decodeIfPresent(Double.self, forKey: .sgstPercentage)
        sgstAmount = try values.decodeIfPresent(Double.self, forKey: .sgstAmount)
        cgstPercentage = try values.decodeIfPresent(Double.self, forKey: .cgstPercentage)
        cgstAmount = try values.decodeIfPresent(Double.self, forKey: .cgstAmount)
        igstPercentage = try values.decodeIfPresent(Double.self, forKey: .igstPercentage)
        igstAmount = try values.decodeIfPresent(Double.self, forKey: .igstAmount)
        gstType = try values.decodeIfPresent(String.self, forKey: .gstType)
        
        originalPrice = try values.decodeIfPresent(Double.self, forKey: .originalPrice)
        
        productHistory = try values.decodeIfPresent([ProductHistory].self, forKey: .productHistory)
        rejectReason = try values.decodeIfPresent(String.self, forKey: .rejectReason)
        
        /// Sample Order
        //categoryID = try values.decodeIfPresent(Int.self, forKey: .categoryID)
        
        // Follow Up
        trailReports = try values.decodeIfPresent([TrailReports].self, forKey: .trailReports)
        
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Home
            try container.encodeIfPresent(id, forKey: .id)
            try container.encodeIfPresent(productCode, forKey: .productCode)
            try container.encodeIfPresent(name, forKey: .name)
            try container.encodeIfPresent(showWarehouse, forKey: .showWarehouse)
            try container.encodeIfPresent(isNill, forKey: .isNill)
            try container.encodeIfPresent(remark, forKey: .remark)
            
            try container.encodeIfPresent(productUnit, forKey: .productUnit)
            try container.encodeIfPresent(productUnit, forKey: .product_unit)
            
            try container.encodeIfPresent(description, forKey: .description)
            try container.encodeIfPresent(unitPrice, forKey: .unitPrice)
            try container.encodeIfPresent(inStock, forKey: .inStock)
            try container.encodeIfPresent(tax, forKey: .tax)
            try container.encodeIfPresent(hsnNumber, forKey: .hsnNumber)
            try container.encodeIfPresent(status, forKey: .status)
            try container.encodeIfPresent(companyType, forKey: .companyType)
            try container.encodeIfPresent(categoryName, forKey: .categoryName)
            try container.encodeIfPresent(lastPrice, forKey: .lastPrice)
            try container.encodeIfPresent(categoryId, forKey: .categoryId)
            try container.encodeIfPresent(isOtherProduct, forKey: .isOtherProduct)
            try container.encodeIfPresent(warehouseQty, forKey: .warehouseQty)
            try container.encodeIfPresent(inCommited, forKey: .inCommited)
            try container.encodeIfPresent(available, forKey: .available)
            try container.encodeIfPresent(productWarehouse, forKey: .productWarehouse)
            
            // Add Order from Sales.
            try container.encodeIfPresent(commission, forKey: .commission)
            try container.encodeIfPresent(discountAmount, forKey: .discountAmount)
            try container.encodeIfPresent(maxDiscount, forKey: .maxDiscount)
            try container.encodeIfPresent(productBasicPrice, forKey: .productBasicPrice)
            
            try container.encodeIfPresent(productId, forKey: .productId)
            //try container.encodeIfPresent(productId, forKey: .productID)
            try container.encodeIfPresent(productId, forKey: .product_id)
            
            try container.encodeIfPresent(productName, forKey: .productName)
            try container.encodeIfPresent(productName, forKey: .product_name)
            
            try container.encodeIfPresent(productOldPrice, forKey: .productOldPrice)
            try container.encodeIfPresent(productTotal, forKey: .productTotal)
            try container.encodeIfPresent(questions, forKey: .questions)
            try container.encodeIfPresent(storeQty, forKey: .storeQty)
            try container.encodeIfPresent(userCommission, forKey: .userCommission)
            try container.encodeIfPresent(userCommissionByCategory, forKey: .userCommissionByCategory)
            
            try container.encodeIfPresent(productPrice, forKey: .productPrice)
            try container.encodeIfPresent(productPrice, forKey: .product_price)
            
            try container.encodeIfPresent(discountPrice, forKey: .discountPrice)
            try container.encodeIfPresent(quantity, forKey: .quantity)
            try container.encodeIfPresent(productUnitMesurement, forKey: .productUnitMesurement)
            try container.encodeIfPresent(moq, forKey: .moq)
            
            try container.encodeIfPresent(moqUnit, forKey: .moqUnit)
            try container.encodeIfPresent(moqUnit, forKey: .moq_unit)
            
            try container.encodeIfPresent(packSize, forKey: .packSize)
            try container.encodeIfPresent(packSize, forKey: .pack_size)
            
            // Dashboard
            try container.encodeIfPresent(reMarkName, forKey: .reMarkName)
            
            
            
            try container.encodeIfPresent(ordersID, forKey: .ordersID)
            try container.encodeIfPresent(productDiscount, forKey: .productDiscount)
            try container.encodeIfPresent(productRemark, forKey: .productRemark)
            try container.encodeIfPresent(productTax, forKey: .productTax)
            try container.encodeIfPresent(requiredQty, forKey: .requiredQty)
            try container.encodeIfPresent(productQty, forKey: .productQty)
            try container.encodeIfPresent(basicProductTotal, forKey: .basicProductTotal)
            try container.encodeIfPresent(remainingQty, forKey: .remainingQty)
            try container.encodeIfPresent(sgstPercentage, forKey: .sgstPercentage)
            try container.encodeIfPresent(sgstAmount, forKey: .sgstAmount)
            try container.encodeIfPresent(cgstPercentage, forKey: .cgstPercentage)
            try container.encodeIfPresent(cgstAmount, forKey: .cgstAmount)
            try container.encodeIfPresent(igstPercentage, forKey: .igstPercentage)
            try container.encodeIfPresent(igstAmount, forKey: .igstAmount)
            try container.encodeIfPresent(gstType, forKey: .gstType)
            try container.encodeIfPresent(originalPrice, forKey: .originalPrice)
            try container.encodeIfPresent(productHistory, forKey: .productHistory)
            try container.encodeIfPresent(rejectReason, forKey: .rejectReason)
            
            /// Sample Order
            //try container.encodeIfPresent(categoryID, forKey: .categoryID)
            
            // Follow Up
            try container.encodeIfPresent(trailReports, forKey: .trailReports)
            
        }
        catch let err {
            print(err)
        }
    }
}

// MARK: - UserCommissionByCategory
struct UserCommissionByCategory: Codable {
    var unit: String?
    var name: String?
    var commissionType: String?
    var categoryID: Int?
    var commission: Double?

    enum CodingKeys: String, CodingKey {
        case unit, name, commissionType
        case categoryID = "categoryId"
        case commission
    }
}

// MARK: - ProductWarehouse
struct ProductWarehouse: Codable {
    var productId: Int?
    var branchId: Int?
    var inStock: String?
    //var inStock: Int?
    var inCommited: Double?
    var available: Double?
    
    var city: String?
    
    // Dashboard
    var branchName: String?
}

// MARK: - CategoryCommissionDetails
struct CategoryCommissionDetails: Codable {
    var unit: String?
    var name: String?
    var commissionType: String? = "percentage"
    var categoryId: Int?
    var commission: Double?
}

// MARK: - CategoryList
struct CategoryList: Codable {
    var categoryId: Int?
    var name: String?
}

// MARK: - OrderDetail
struct OrderDetail: Codable {
    var currentPage: Int?
    var data: [ProductData]?
    var lastPage: Int?
    
    //var firstPageUrl: String?
    //var from: Int?
    //var lastPageUrl: String?
    //var nextPageUrl: String?
    //var path: String?
    //var perPage: Int?
    //var prevPageUrl: String?
    //var to: Int?
    //var total: Int?
}

// MARK: - Datum
struct ProductData: Codable {
    var productName: String?
    var productCode: String?
    var productRemark: String?
    var productQty: Double?
    //var remainingQty: Double?
    var remainingQty: Int?
    var codeId: String?
    var businessPartnerName: String?
    var orderStatus: Int?
    var requiredQty: Double?
    var productBasicPrice: Double?
    var lastUpdated: String?
    var orderDate: String?
    var orderType: Int?
    var productPrice: Double?
    var productTotal: Double?
    var discountAmount: Double?
    var userName: String?
}
