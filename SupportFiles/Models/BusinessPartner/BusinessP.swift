//
//  BusinessP.swift
//  GE Sales
//
//  Created by Auxano on 25/04/24.
//

import Foundation

// MARK: - BusinessPartner
struct BusinessPartner: Codable {
    var id: Int?
    var name: String?
    var code: String?
    var isVerified: Int?
    var verifiedStatus: String?
    var isGst: Int?
    var paymentType: Int?
    var creditDayLimit: String?
    var creditLimit: Double?
    var discountPercent: Double?
    var billingId: Int?
    var billingLocation: String?
    var salesPersonDesignationId: Int?
    var salesPersonDesignation: String?
    var deliveryId: Int?
    var deliveryLocation: String?
    var companyType: Int?
    var deliveryTo: String?
    var lastTransporterId: Int?
    var transporterGSTNo: String?
    var salesPersonName: String?
    var createdAt: String?
    var updatedAt: String?
    var stateName: String?
    var cityName: String?
    var zoneType: Int?
    var transporters: [Transporter]?
    
    // Add BP
    var deliveryAddressId: Int?
    var deliveryAddressName: String?
    var billingAddressId: Int?
    var billingAddressName: String?
    var businessPartner: Int?
    
    // Dashboard
    var codeId: String?
    var industryType: String?
    var saleOrderCount: Int?
    var qiOrderCount: Int?
    var piOrderCount: Int?
    var sampleOrderCount: Int?
    var employeeName: String?
    var employeeId, stateId: Int?
    var email: String?
    var contactPerson: String?
    var contactNumber: String?
    var lastOrderDate: String?
    var lastSampleOrderDate: String?
}

// MARK: - Transporter
struct Transporter: Codable {
    var transporterId: Int? 
    var transporterTitle: String?
    
    // Add BP Transporter
    var transporterCode: String?
    var transporterGSTNo: String?
    var companyType: Int?
    
    // Add Sales Order
    var position: Bool?
    
    enum CodingKeys: String, CodingKey {
        case transporterId
        case transporterTitle
        
        // Add BP Transporter
        case transporterCode
        case transporterGSTNo
        case companyType
        
        // Add Sales Order
        case position
    }
    
    init(transporterId: Int? = nil, transporterTitle: String? = nil, transporterCode: String? = nil, transporterGSTNo: String? = nil, companyType: Int? = nil, position: Bool? = nil) {
        self.transporterId = transporterId
        self.transporterTitle = transporterTitle
        self.transporterCode = transporterCode
        self.transporterGSTNo = transporterGSTNo
        self.companyType = companyType
        self.position = position
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        /*if let intValue = try? values.decode(Int.self, forKey: .transporterId) {
            transporterId = intValue
        } else if let stringValue = try? values.decode(String.self, forKey: .transporterId) {
            transporterId = Int(stringValue) ?? 0
        } else {
            transporterId = 0
        }   //  */
        transporterId = try values.decodeIfPresent(Int.self, forKey: .transporterId)
        transporterTitle = try values.decodeIfPresent(String.self, forKey: .transporterTitle)
        
        // Add BP Transporter
        transporterCode = try values.decodeIfPresent(String.self, forKey: .transporterCode)
        transporterGSTNo = try values.decodeIfPresent(String.self, forKey: .transporterGSTNo)
        companyType = try values.decodeIfPresent(Int.self, forKey: .companyType)
        
        // Add Sales Order
        position = try values.decodeIfPresent(Bool.self, forKey: .position)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encodeIfPresent(transporterId, forKey: .transporterId)
        try container.encodeIfPresent(transporterTitle, forKey: .transporterTitle)
        
        // Add BP Transporter
        try container.encodeIfPresent(transporterCode, forKey: .transporterCode)
        try container.encodeIfPresent(transporterGSTNo, forKey: .transporterGSTNo)
        try container.encodeIfPresent(companyType, forKey: .companyType)
        
        // Add Sales Order
        try container.encodeIfPresent(position, forKey: .position)
    }
}

// MARK: - Employee
struct Employee: Codable {
    var id: Int?
    var firstname: String?
    var lastname: String?
    var zone: String?
    
    // MTP
    var userId: Int?
    var planDate: String?
    var orgPlanDate: String?
    var city: String?
    var reportURL: String?
    var masterId: Int?
    var estimatedCost: Double?
    var oldEstimatedCost: Int?
    var statusBy: Int?
    var employeeAction: Int?
    var estimatedCostComment: String?
    var fullname: String?
    var reply: String?
    var objectives: String?
    var status: String?
    var startDate: String?
    var endDate: String?
    var isLeave: Int?
    var remark: String?
    var leaveType: String?
    var isWorkingFromHome: Int?
    var comment: String?
    var roleId: Int?
    var whoms: [Whom]?
    
    // Add MTP
    var employeeName: String?
}

// MARK: - OrderDetail
struct BusinessPOrderDetail: Codable {
    var orderID: Int?
    var orderCode: String?
    var orderType: Int?
    var orderDate: String?
    var subTotal: Double?
    var gstTotal: Double?
    var calculatedTotal: Double?
    var grandTotalAmount: Double?
    var orderStatus: Int?

    enum CodingKeys: String, CodingKey {
        case orderID = "order_id"
        case orderCode = "order_code"
        case orderType = "order_type"
        case orderDate = "order_date"
        case subTotal = "sub_total"
        case gstTotal = "gst_total"
        case calculatedTotal
        case grandTotalAmount = "grand_total_amount"
        case orderStatus = "order_status"
    }
}

// MARK: - BusinessPartnerDetail
struct BusinessPartnerDetail: Codable {
    var id: Int?
    var userID: Int?
    var codeID: String?
    var sapID: String?
    var name: String?
    var legalName: String?
    var telephoneNo: String?
    var mobileNo: [String]?
    var email: [String]?
    var webURL: String?
    var industryType: String?
    var businessType: String?
    var existingBusiness: String?
    var isGst: Int?
    var paymentType: Int?
    var creditDayLimit: String?
    var contactPersonDesignation: String?
    var contactPersonName: String?
    var contactPersonEmail: String?
    var contactPersonPhonePrimary: String?
    var contactPersonPhoneSecondary: String?
    var discountPercent: Double?
    var annualTurnover: Double?
    var currencyType: String?
    var businessPartnerGstIn: String?
    var businessPartnerPanNo: String?
    var businessPartnerAadharCard: String?
    var businessPartnerSalesPersonAccountable: String?
    var firmType: String?
    var companyType: Int?
    var branchID: Int?
    var isVerified: Int?
    var verifiedStatus: String?
    var establishmentYear: String?
    var fromType: String?
    var status: Int?
    var useBillTo: Int?
    var createdAt: String?
    var updatedAt: String?
    var bmCreatedDate: String?
    var roleID: Int?
    var bmSAPID: String?
    var gfwSAPID: String?
    var userSAPID: String?
    var branchName: String?
    var companyName: String?
    var employeeName: String?
    var payTerm: String?
    var showBmFullDetails: Int?
    var currentBalance: Double?
    var isCurrentBalancePositive: Int?
    var grandSalesOrderTotal: Double?
    var grandTotalQi: Double?
    var grandTotalPi: Int?
    var grandTotalSampleRequest: Int?
    var grandTotal: Double?
    var salesPersonID: Int?
    var rajanDalalID: Int?
    var businessPartnersTransporters: [BusinessPartnersTransporter]?
    var businessPartnersContactPerson: [BusinessPartnersContactPerson]?
    var businessPartnerHistory: [BusinessPartnerHistory]?
    var billingAddress: Address?
    var deliveryAddress: Address?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case codeID = "code_id"
        case sapID = "SAP_id"
        case name
        case legalName = "legal_name"
        case telephoneNo = "telephone_no"
        case mobileNo = "mobile_no"
        case email
        case webURL = "web_url"
        case industryType = "industry_type"
        case businessType = "business_type"
        case existingBusiness = "existing_business"
        case isGst = "is_gst"
        case paymentType = "payment_type"
        case creditDayLimit = "credit_day_limit"
        case contactPersonDesignation = "contact_person_designation"
        case contactPersonName = "contact_person_name"
        case contactPersonEmail = "contact_person_email"
        case contactPersonPhonePrimary = "contact_person_phone_primary"
        case contactPersonPhoneSecondary = "contact_person_phone_secondary"
        case discountPercent = "discount_percent"
        case annualTurnover = "annual_turnover"
        case currencyType = "currency_type"
        case businessPartnerGstIn = "business_partner_GstIn"
        case businessPartnerPanNo = "business_partner_PanNo"
        case businessPartnerAadharCard = "business_partner_AadharCard"
        case businessPartnerSalesPersonAccountable = "business_partner_sales_person_accountable"
        case firmType = "firm_type"
        case companyType = "company_type"
        case branchID = "branch_id"
        case isVerified
        case verifiedStatus = "verified_status"
        case establishmentYear = "establishment_year"
        case fromType = "from_type"
        case status
        case useBillTo = "UseBillTo"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case bmCreatedDate
        case roleID = "role_id"
        case bmSAPID = "bmSAPId"
        case gfwSAPID = "GFW_SAP_id"
        case userSAPID = "userSAPId"
        case branchName = "branch_name"
        case companyName = "company_name"
        case employeeName = "employee_name"
        case payTerm = "pay_term"
        case showBmFullDetails
        case currentBalance
        case isCurrentBalancePositive
        case grandSalesOrderTotal = "grand_sales_order_total"
        case grandTotalQi = "grand_total_qi"
        case grandTotalPi = "grand_total_pi"
        case grandTotalSampleRequest = "grand_total_sample_request"
        case grandTotal = "grand_total"
        case salesPersonID = "sales_person_id"
        case rajanDalalID = "rajanDalalId"
        case businessPartnersTransporters = "business_partners_transporters"
        case businessPartnersContactPerson = "business_partners_contact_person"
        case businessPartnerHistory = "business_partner_history"
        case billingAddress = "billing_address"
        case deliveryAddress = "delivery_address"
    }
}

// MARK: - Address
struct Address: Codable {
    var id: Int?
    var businessPartnersID: Int?
    var addressType: Int?
    var addressLocationType: String?
    var sapAddress: String?
    var addressTitle: String?
    var blockNo: String?
    var buildingFloorRoom: String?
    var streetPoBox: String?
    var pinCode: String?
    var gstIn: String?
    var streetNo: String?
    var landmark: String?
    var countryID: Int?
    var stateID: Int?
    var cityID: Int?
    var isDefault: Int?
    var isDeleted: Int?
    var createdAt: String?
    var updatedAt: String?
    var stateName: String?
    var zone: Int?
    var cityName: String?
    var countryName: String?
    var stateShortName: String?
    var gfwShortName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case businessPartnersID = "business_partners_id"
        case addressType = "address_type"
        case addressLocationType = "address_location_type"
        case sapAddress = "sap_address"
        case addressTitle = "address_title"
        case blockNo = "block_no"
        case buildingFloorRoom = "building_floor_room"
        case streetPoBox = "street_po_box"
        case pinCode = "pin_code"
        case gstIn = "GstIn"
        case streetNo = "street_no"
        case landmark
        case countryID = "country_id"
        case stateID = "state_id"
        case cityID = "city_id"
        case isDefault = "is_default"
        case isDeleted = "is_deleted"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case stateName = "state_name"
        case zone
        case cityName = "city_name"
        case countryName = "country_name"
        case stateShortName
        case gfwShortName = "gfw_short_name"
    }
}

// MARK: - BusinessPartnerHistory
struct BusinessPartnerHistory: Codable {
    var historyID: Int?
    var businessPartnersID: Int?
    var status: String?
    var historyDate: String?
    var reason: String?
    var employeeName: String?

    enum CodingKeys: String, CodingKey {
        case historyID = "historyId"
        case businessPartnersID = "business_partners_id"
        case status
        case historyDate
        case reason
        case employeeName
    }
}

// MARK: - BusinessPartnersContactPerson
struct BusinessPartnersContactPerson: Codable {
    var id: Int?
    var businessPartnersID: Int?
    var contactPersonDesignation: String?
    var contactPersonName: String?
    var contactPersonNameSap: String?
    var contactPersonEmail: String?
    var contactPersonPhonePrimary: String?
    var contactPersonPhoneSecondary: String?

    enum CodingKeys: String, CodingKey {
        case id
        case businessPartnersID = "business_partners_id"
        case contactPersonDesignation = "contact_person_designation"
        case contactPersonName = "contact_person_name"
        case contactPersonNameSap = "contact_person_name_sap"
        case contactPersonEmail = "contact_person_email"
        case contactPersonPhonePrimary = "contact_person_phone_primary"
        case contactPersonPhoneSecondary = "contact_person_phone_secondary"
    }
}

// MARK: - BusinessPartnersTransporter
struct BusinessPartnersTransporter: Codable {
    var businessPartnersID: Int?
    var transporterID: Int?
    var transporterTitle: String?

    enum CodingKeys: String, CodingKey {
        case businessPartnersID = "business_partners_id"
        case transporterID = "transporter_id"
        case transporterTitle = "transporter_title"
    }
}

// MARK: - ProductList
struct BPProductList: Codable {
    var productName: String?
    var productCode: String?
    var products: [BPProduct]?
}

// MARK: - Product
struct BPProduct: Codable {
    var id: Int?
    var businessPartnersId: Int?
    var orderStatus: Int?
    var orderProductId: Int?
    var productCode: String?
    var productName: String?
    var productPrice: String?
    var productQty: Double?
    var productTotal: Double?
    var status: String?
    var createdAt: String?
    
    /// Trial Product
    var ordersId: Int?
    var productId: Int?
    var trailReports: [TrailReports]?
    
}

// MARK: - OrderDetail
struct BPOrderDetail: Codable {
    /// Sales Order Detail                  /// QI Order Detail
    var codeID: String?
    var businessPartnerEmail: String?
    var followUpDaysString: String?
    var followUpDate: String?
    var businessPartnerInvoiceEmail: String?
    var businessPartnerGstIn: String?
    var mobileNo: String?
    var bmSAPID: String?
    var businessPartnerName: String?
    var paymentType: Int?
    var creditDayLimit: String?
    var branchName: String?
    var branchCode: String?
    var branchGstNo: String?
    var id: Int?
    var userID: Int?
    var sAPID: String?
    var sAPDraftID: String?
    var sAPStatus: String?
    var businessPartnersID: Int?
    var branchID: Int?
    var qiPiID: Int?
    var qiValidity: String?
    var sampleRequestID: Int?
    var referenceEmployeeName: String?
    var orderCode: String?
    var orderDate: String?
    var requiredDate: String?
    var followUpDays: Int?
    var orderDateFollowUp: String?
    var orderDeliveryType: String?
    var billingAddressID: Int?
    var deliveryAddressID: Int?
    var transporterID: Int?
    var otherTransporter: String?
    var orderStatus: Int?
    var freightCharges: String?
    var bookingPoint: String?
    var comment: String?
    var totalGstPercentage: Int?
    var subTotal: Double?
    var basicTotal: Double?
    var gstTotal: Double?
    var grandTotalAmount: Double?
    var freight: Double?
    var freightGst: Double?
    var reason: String?
    var companyType: Int?
    var orderType: Int?
    var quotationValidityDate: String?
    var quotationStatus: String?
    var questionFromPan: String?
    var answerFromZm: String?
    var employeeTargetFlag: Int?
    var popupStatus: Int?
    var preferredWarehouse: Int?
    var statusBy: Int?
    var isPurchaseManager: Int?
    var createdAt: String?
    var updatedAt: String?
    var transporterName: String?
    var billingLocation: String?
    var deliveryLocation: String?
    var deliveryOption: String?
    var deliveryTo: String?
    var userName: String?
    var employeeOrder: Int?
    var employeeName: String?
    var sampleOrderCode: String?
    var billingAddress: Address?
    var deliveryAddress: Address?
    //var products: [BPOrderProduct]?
    var products: [ProductList]?
    var history: [History]?
    var paymentsDetail: PaymentsDetail?
    var poAttachment: [PoAttachment]?
    var businessPartnerTransporter: [BusinessPartnerTransporter]?
    
    var transporterGSTNo: String?

    /// Sample Order Detail
    var handDeliveryText: String?
    var podDetail: String?
    var podDate: String?
    var sampleStatus: String?
    var isFollowup: Int?
    var deliveryStatus: String?
    var deliveryComment: String?
    var contactPersonPhonePrimary: String?
    var trailReportsHistory: TrailReportsHistory?
    var isOtherProduct: Int?
    
    
    enum CodingKeys: String, CodingKey {
        /// Sales Order Detail          /// QI Order Detail
        case codeID = "codeId"
        case businessPartnerEmail, followUpDaysString, followUpDate, businessPartnerInvoiceEmail, businessPartnerGstIn, mobileNo
        case bmSAPID = "bmSAPId"
        case businessPartnerName, paymentType, creditDayLimit, branchName, branchCode, branchGstNo, id
        case userID = "userId"
        case sAPID = "sAPId"
        case sAPDraftID = "sAPDraftId"
        case sAPStatus
        case businessPartnersID = "businessPartnersId"
        case branchID = "branchId"
        case qiPiID = "qiPiId"
        case qiValidity
        case sampleRequestID = "sampleRequestId"
        case referenceEmployeeName, orderCode, orderDate, requiredDate, followUpDays, orderDateFollowUp, orderDeliveryType
        case billingAddressID = "billingAddressId"
        case deliveryAddressID = "deliveryAddressId"
        case transporterID = "transporterId"
        case otherTransporter, orderStatus, freightCharges, bookingPoint, comment, totalGstPercentage, subTotal, basicTotal, gstTotal, grandTotalAmount, freight, freightGst, reason, companyType, orderType, quotationValidityDate, quotationStatus, questionFromPan, answerFromZm, employeeTargetFlag, popupStatus, preferredWarehouse, statusBy, isPurchaseManager, createdAt, updatedAt, transporterName, billingLocation, deliveryLocation, deliveryOption, deliveryTo, userName, employeeOrder, employeeName, sampleOrderCode, billingAddress, deliveryAddress, products, history, paymentsDetail, poAttachment, businessPartnerTransporter, transporterGSTNo
        
        /// Sample Order Detail
        case handDeliveryText
        case podDetail, podDate, sampleStatus, isFollowup, deliveryStatus, deliveryComment
        case contactPersonPhonePrimary, trailReportsHistory, isOtherProduct
    }
}


// MARK: - BusinessPartnerTransporter
struct BusinessPartnerTransporter: Codable {
    var transporterID: Int?
    var transporterCode: String?
    var transporterTitle: String?
    var transporterGSTNo: String?
    var businessPartnersID: Int?
    
    enum CodingKeys: String, CodingKey {
        case transporterID = "transporterId"
        case transporterCode, transporterTitle, transporterGSTNo
        case businessPartnersID = "businessPartnersId"
    }
}

// MARK: - History
struct History: Codable {
    var id: Int?
    var ordersID: Int?
    var employeeName: String?
    var currentStatus: Int?
    var reason: String?
    var statusDatetime: String?
    var employeeReason: String?
    var reasonDateTime: String?

    enum CodingKeys: String, CodingKey {
        case id
        case ordersID = "ordersId"
        case employeeName, currentStatus, reason, statusDatetime, employeeReason, reasonDateTime
    }
}

// MARK: - PaymentsDetail
// Sales Order,
struct PaymentsDetail: Codable {
    var id: Int?
    var paymentType: Int?
    var ordersId: Int?
    var paymentMode: Int?
    var creditDay: Int?
    var paymentAmount: Double?
    var paymentDate: String?
    var paymentTransactionId: String?
    var paymentChequeNo: String?
    var hasApproval: Int?
    var paymentStatus: Int?
    var createdAt: String?
    var updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case paymentType
        case ordersId
        case paymentMode
        case creditDay
        case paymentAmount
        case paymentDate
        case paymentTransactionId
        case paymentChequeNo
        case hasApproval
        case paymentStatus
        case createdAt
        case updatedAt
        
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        paymentType = try values.decodeIfPresent(Int.self, forKey: .paymentType)
        ordersId = try values.decodeIfPresent(Int.self, forKey: .ordersId)
        paymentMode = try values.decodeIfPresent(Int.self, forKey: .paymentMode)
        creditDay = try values.decodeIfPresent(Int.self, forKey: .creditDay)
        paymentDate = try values.decodeIfPresent(String.self, forKey: .paymentDate)
        paymentTransactionId = try values.decodeIfPresent(String.self, forKey: .paymentTransactionId)
        paymentChequeNo = try values.decodeIfPresent(String.self, forKey: .paymentChequeNo)
        hasApproval = try values.decodeIfPresent(Int.self, forKey: .hasApproval)
        paymentStatus = try values.decodeIfPresent(Int.self, forKey: .paymentStatus)
        createdAt = try values.decodeIfPresent(String.self, forKey: .createdAt)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
        paymentAmount = try values.decodeIfPresent(Double.self, forKey: .paymentAmount)
        
        /*if let value1 = try? values.decode(String.self, forKey: .paymentAmount) {
            paymentAmount = value1
        } else if let value2 = try? values.decode(Int.self, forKey: .paymentAmount) {
            paymentAmount = String(value2)
        } else {
            paymentAmount = ""
        }   //  */
        
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // Home
            try container.encodeIfPresent(id, forKey: .id)
            try container.encodeIfPresent(paymentType, forKey: .paymentType)
            try container.encodeIfPresent(ordersId, forKey: .ordersId)
            try container.encodeIfPresent(paymentMode, forKey: .paymentMode)
            try container.encodeIfPresent(creditDay, forKey: .creditDay)
            try container.encodeIfPresent(paymentDate, forKey: .paymentDate)
            try container.encodeIfPresent(paymentTransactionId, forKey: .paymentTransactionId)
            try container.encodeIfPresent(paymentChequeNo, forKey: .paymentChequeNo)
            try container.encodeIfPresent(hasApproval, forKey: .hasApproval)
            try container.encodeIfPresent(paymentStatus, forKey: .paymentStatus)
            try container.encodeIfPresent(createdAt, forKey: .createdAt)
            try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
            try container.encodeIfPresent(paymentAmount, forKey: .paymentAmount)
            
        }
    }
}

// MARK: - PoAttachment
struct PoAttachment: Codable {
    var attachmentID: Int?
    var orderID: Int?
    var poType: String?
    var caption: String?
    var attachment: String?
    var reason: String?
    var attachmentPath: String?

    enum CodingKeys: String, CodingKey {
        case attachmentID = "attachmentId"
        case orderID = "orderId"
        case poType, caption, attachment, reason, attachmentPath
    }
}

// MARK: - Product
//struct BPOrderProduct: Codable {
//    
//    /// Sales Order
//    
//    var id: Int?
//    var productID: Int?
//    var ordersID: Int?
//    var productName: String?
//    var productDiscount: Double?
//    var discountAmount: Double?
//    var productRemark: String?
//    var productUnit: String?
//    var packSize: String?
//    var productTax: Double?
//    var requiredQty: Double?
//    var productQty: Double?
//    var basicProductTotal: Double?
//    var remainingQty: Int?
//    var moq: Int?
//    var moqUnit: String?
//    var productPrice: Double?
//    var productTotal: Double?
//    var sgstPercentage: Double?
//    var sgstAmount: Double?
//    var cgstPercentage: Double?
//    var cgstAmount: Double?
//    var igstPercentage: Double?
//    var igstAmount: Double?
//    var gstType: String?
//    var categoryName: String?
//    var productCode: String?
//    var hsnNumber: String?
//    var commission: Int?
//    var userCommission: Int?
//    var originalPrice: Double?
//    var status: String?
//    var productWarehouse: [ProductWarehouse]?
//    var productHistory: [ProductHistory]?
//    
//    var rejectReason: String?
//    
//    /// Sample Order
//    
//    var categoryID: Int?
//    var questions: Questions?
//    
//    // Follow Up
//    var trailReports: [TrailReports]?
//    
//    
//    
//    enum CodingKeys: String, CodingKey {
//        
//        /// Sales Order
//        
//        case id
//        case productID = "productId"
//        case ordersID = "ordersId"
//        case productName, productDiscount, discountAmount, productRemark, productUnit, packSize, productTax, requiredQty, productQty, basicProductTotal, remainingQty, moq, moqUnit, productPrice, productTotal, sgstPercentage, sgstAmount, cgstPercentage, cgstAmount, igstPercentage, igstAmount, gstType, categoryName, productCode, hsnNumber, commission, userCommission, originalPrice, status, productWarehouse, productHistory, rejectReason
//        
//        /// Sample Order
//        
//        case categoryID = "categoryId"
//        case questions
//        
//        // Follow Up
//        case trailReports
//    }
//}

// MARK: - Questions
struct Questions: Codable {
    var orderProductID: Int?
    var qApplication: String?
    var qTrailBachSize: String?
    var qPotentialType: String?
    var qPotentialQty: String?
    var qPotentialMeasurement: String?
    var qBrand: String?

    enum CodingKeys: String, CodingKey {
        case orderProductID = "orderProductId"
        case qApplication, qTrailBachSize, qPotentialType, qPotentialQty, qPotentialMeasurement, qBrand
    }
}

// MARK: - ProductHistory
struct ProductHistory: Codable {
    var historyID: Int?
    var orderProductID: Int?
    var currentStatus: String?
    var reason: String?
    var reply: String?
    var statusDatetime: String?
    var parentName: String?
    var employeeName: String?
    
    var isReplyClicked: Bool? = false

    enum CodingKeys: String, CodingKey {
        case historyID = "historyId"
        case orderProductID = "orderProductId"
        case currentStatus, reason, reply, statusDatetime, parentName, employeeName
        
        case isReplyClicked
    }
}

// MARK: - TrailReportsHistory
struct TrailReportsHistory: Codable {
    var id: Int?
    var products: [BPProduct]?
}

// MARK: - TrailReports
struct TrailReports: Codable {
    var id: Int?
    var orderProductId: Int?
    var isTrail: Int?
    var status: Int?
    var reason: String?
    var reportAttachments: [ReportAttachment]?
}

// MARK: - ReportAttachment
struct ReportAttachment: Codable {
    var id: Int?
    var trailReportId: Int?
    var attachment: String?
    var caption: String?
}

// MARK: - TeamMember
struct TeamMember: Codable {
    var id: Int?
    var name: String?
    var userDesignation: String?
    var email: String?
    var mobileNo: String?
    var zone: String?
    var monthlyTargetActual: Double?
    var quarterlyTargetActual: Double?
    var yearlyTargetActual: Double?
    var categoryId: String?
}

// MARK: - State
struct State: Codable {
    var id: Int?
    var stateName: String?
}

// MARK: - City
struct City: Codable {
    var id: Int?
    var cityName: String?
}

// MARK: - BmList
struct BmList: Codable {
    var bmName: String?
    var cityName: String?
}

// MARK: - Add Contact
struct AddBPContact: Codable {
    var name: String?
    var pContact: String?
    var sContact: String?
    var email: String?
    var designation: String?
}
