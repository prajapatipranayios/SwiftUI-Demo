//
//  SalesOrder.swift
//  Novasol Ingredients
//
//  Created by Auxano on 28/05/24.
//

import Foundation

// Sales Order

// MARK: - OrderedBusinessPartner
struct OrderedBusinessPartner: Codable {
    var id: Int?
    var name: String?
}

// MARK: - OrderedEmployee
struct OrderedEmployee: Codable {
    var employeeId: Int?
    var employeeName: String?
}

// MARK: - OrderCount
struct SalesOrderCount: Codable {
    var totalCommission: Int?
    var totalOrder: String?
    //var totalOrder: Int?
    var totalAmount: String?
    var requestDate: String?
    var businessPartnerName: String?
    
    var ordersList: [SalesOrdersList]? = []
}

// MARK: - OrderCount

struct OrderCount: Codable {
    var all: Int?
    var pending: Int?
    var approved: Int?
    var inProcess: Int?
    var completed: Int?
    var cancelled: Int?
    var hold: Int?
    var open: Int?
    var rejected: Int?
    var dispatched: Int?
    var sOBookedInSAP: Int?
    var qIBookedInSAP: Int?
    var pIBookedInSAP: Int?
    var sOApprovalInSAP: Int?
    var sORejectedInSAP: Int?
    var deliveryGenerated:Int?
    var partiallyDeliveryGenerated: Int?
    var invoiceGenerated: Int?
    var partiallyInvoiceGenerated: Int?
    var materialDispatched: Int?
    var partiallyMaterialDispatched: Int?
    var sOCancelledInSAP: Int?
}

// MARK: - OrdersList
struct SalesOrdersList: Codable {
    
    var totalProduct: Int?
    var id: Int?
    var userId: Int?
    var orderCode: String?
    var orderDate: String?
    var orderStatus: Int?
    var isPurchaseManager: Int?
    var subTotal: Double?
    var gstTotal: Double?
    var grandTotalAmount: String?
    var orderType: Int?
    var quotationValidityDate: String?
    var quotationStatus: String?
    var paymentType: Int?
    var creditDayLimit: String?
    var businessPartnerName: String?
    var requestDate: String?
    var roleId: Int?
    var statusBy: Int?
    var totalCommission: Int?
    var paymentsDetail: PaymentsDetail?
    var employeeOrder: Int?
    var employeeName: String?
    
    var accessId: Int?
}

// MARK: - PaymentsDetail
// in BusinessP

// MARK: - BusinessPartnerAddress
struct BusinessPartnerAddress: Codable {
    var id: Int?
    var businessPartnersId: Int?
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
    var countryId: Int?
    var stateId: Int?
    var cityId: Int?
    var isDefault: Int?
    var isDeleted: Int?
    var createdAt: String?
    var updatedAt: String?
    var state: String?
    var city: String?
}

// MARK: - SaveToDraftOrder
struct SaveToDraftOrder: Codable {
    
    var billingAddressID: Int?
    var billingAddressName: String?
    var bookingPoint: String?
    var branchID: Int?
    var branchName: String?
    var businessPartnerTransporter: [BusinessPartnerTransporter]?
    var businessPartnersID: Int?
    var businessPartnerName: String?
    var businesscode: String?
    var cgstAmount: Double?
    var comment: String?
    var companyType: Int?
    var creditDay: String?
    var deliveryTo: String?
    var deliveryAddressID: String?
    var deliveryAddressName: String?
    var draftID: Int?
    var followUpDays: Int?
    var freight: Double?
    var freightCharges: String?
    var freightGst: Double?
    var grandTotalAmount: String?
    var gstTotal: Double?
    var handDeliveryText: String?
    var igstAmount: Double?
    var isEditableOrder: Bool?
    var lastTransporterID: Int?
    var orderDeliveryType: String?
    var orderID: Int?
    var orderType: Int?
    var otherTransporter: String?
    var paymentAmount: String?
    var paymentChequeNo: String?
    var paymentDate: String?
    var paymentMode: String?
    var paymentTransactionID: String?
    var paymentType: String?
    var paymentsDetail: PaymentsDetail?
    var poAttachment: [PoAttachment]?
    var preferredBranchID: Int?
    var products: [ProductList]?
    var qiValidity: String?
    var qiPiID: Int?
    var referenceEmployeeName: String?
    var remainderID: Int?
    var requiredDate: String?
    var sAPID: String?
    var sampleRequestID: Int?
    var sgstAmount: Double?
    var transportNamelist: [Transporter]?
    var transporterGSTNo: String?
    var transporterID: String?
    var transporterTitle: String?
    var userID: Int?
    
    

    enum CodingKeys: String, CodingKey {
        case billingAddressID = "billing_address_id"
        case billingAddressName = "billing_address_name"
        case bookingPoint = "booking_point"
        case branchID = "branch_id"
        case branchName, businessPartnerTransporter
        case businessPartnersID = "business_partners_id"
        case businessPartnerName = "business_partner_name"
        case businesscode, cgstAmount, comment
        case companyType = "company_type"
        case creditDay = "credit_day"
        case deliveryTo
        case deliveryAddressID = "delivery_address_id"
        case deliveryAddressName = "delivery_address_name"
        case draftID = "draft_id"
        case followUpDays = "follow_up_days"
        case freight
        case freightCharges = "freight_charges"
        case freightGst = "freight_gst"
        case grandTotalAmount = "grand_total_amount"
        case gstTotal
        case handDeliveryText = "hand_delivery_text"
        case igstAmount, isEditableOrder
        case lastTransporterID = "lastTransporterId"
        case orderDeliveryType = "order_delivery_type"
        case orderID = "order_id"
        case orderType = "order_type"
        case otherTransporter
        case paymentAmount = "payment_amount"
        case paymentChequeNo = "payment_cheque_no"
        case paymentDate = "payment_date"
        case paymentMode = "payment_mode"
        case paymentTransactionID = "payment_transaction_id"
        case paymentType = "payment_type"
        case paymentsDetail, poAttachment
        case preferredBranchID = "preferredBranchId"
        case products, qiValidity
        case qiPiID = "qi_pi_id"
        case referenceEmployeeName
        case remainderID = "remainder_id"
        case requiredDate = "required_date"
        case sAPID = "sAPId"
        case sampleRequestID = "sample__request_id"
        case sgstAmount, transportNamelist, transporterGSTNo
        case transporterID = "transporter_id"
        case transporterTitle = "transporter_title"
        case userID = "user_id"
    }
    
    // Default initializer (Swift provides this automatically)
    init() { }
    
    // Initializer to map from OrderDetail
    init(from orderDetails: BPOrderDetail) {
        
        // Default values for fields that don't exist in TargetData
        
        orderID = orderDetails.id ?? 0
        
        businessPartnersID = orderDetails.businessPartnersID ?? 0
        businessPartnerName = orderDetails.businessPartnerName ?? ""
        businesscode = orderDetails.codeID ?? ""
        paymentType = "\(orderDetails.paymentType ?? 0)"
        creditDay = orderDetails.creditDayLimit ?? ""
        
        billingAddressID = orderDetails.billingAddressID ?? 0
        billingAddressName = orderDetails.billingLocation ?? ""
        
        deliveryAddressID = "\(orderDetails.deliveryAddressID ?? 0)"
        deliveryAddressName = orderDetails.deliveryLocation ?? ""
        deliveryTo = orderDetails.deliveryTo ?? ""
        
        var tempTransporter: [Transporter] = []
        for (_, value) in (orderDetails.businessPartnerTransporter ?? []).enumerated() {
            var temp: Transporter = Transporter()
            temp.transporterId = value.transporterID ?? 0
            temp.transporterTitle = value.transporterTitle ?? ""
            temp.transporterCode = value.transporterCode ?? ""
            temp.transporterGSTNo = value.transporterGSTNo ?? ""
            
            tempTransporter.append(temp)
        }
        
        transportNamelist = tempTransporter
        
        branchID = orderDetails.branchID ?? 0
        branchName = orderDetails.branchName ?? ""
        
        bookingPoint = orderDetails.bookingPoint ?? ""
        
        businessPartnerTransporter = orderDetails.businessPartnerTransporter ?? []
        
        orderDeliveryType = orderDetails.orderDeliveryType ?? ""
        
        comment = orderDetails.comment ?? ""
        
        orderType = orderDetails.orderType ?? 0
        
        otherTransporter = orderDetails.otherTransporter ?? ""
        
        paymentsDetail = orderDetails.paymentsDetail
        
        poAttachment = orderDetails.poAttachment ?? []
        
        paymentAmount = "\(orderDetails.paymentsDetail?.paymentAmount ?? 0.0)"
        paymentChequeNo = orderDetails.paymentsDetail?.paymentChequeNo ?? ""
        paymentDate = orderDetails.paymentsDetail?.paymentDate ?? ""
        paymentMode = "\(orderDetails.paymentsDetail?.paymentMode ?? 0)"
        paymentTransactionID = orderDetails.paymentsDetail?.paymentTransactionId ?? ""
        
        products = orderDetails.products ?? []
        
        qiValidity = orderDetails.qiValidity ?? ""
        qiPiID = orderDetails.qiPiID ?? 0
        referenceEmployeeName = orderDetails.referenceEmployeeName ?? ""
        requiredDate = orderDetails.requiredDate ?? ""
        sAPID = orderDetails.sAPID ?? ""
        sampleRequestID = orderDetails.sampleRequestID ?? 0
        
        transporterID = "\(orderDetails.transporterID ?? 0)"
        
        userID = orderDetails.userID ?? 0
        
        handDeliveryText = orderDetails.handDeliveryText ?? ""
        
        followUpDays = orderDetails.followUpDays ?? 0
        freight = orderDetails.freight ?? 0.0
        freightCharges = orderDetails.freightCharges ?? ""
        freightGst = orderDetails.freightGst ?? 0.0
        
        transporterGSTNo = orderDetails.transporterGSTNo ?? ""
        transporterTitle = orderDetails.transporterName ?? ""
        
        //grandTotalAmount
        //gstTotal
        
        //igstAmount
        //sgstAmount
        //isEditableOrder: Bool?
        
        //lastTransporterID
        //preferredBranchID
        //remainderID
        
        //transporterTitle
        
    }
    
}

// MARK: - ProductList
struct DraftProductList: Codable {
    var id: Int?
    var productCode: String?
    var name: String?
    var showWarehouse: Int?
    var isNill: Int?
    var remark: String?
    var productUnit: String?
    var description: String?
    var unitPrice: Double?
    var inStock: String?
    var tax: Double?
    var hsnNumber: String?
    var status: String?
    var companyType: Int?
    var categoryName: String?
    var lastPrice: Double?
    var categoryId: Int?
    var isOtherProduct: Int?
    var warehouseQty: String?
    var inCommited: String?
    var available: String?
    var productWarehouse: [DraftProductWarehouse]?
    
    // Add Order from Sales.
    var commission: Double?
    var discountAmount: Double?
    var maxDiscount: Double?
    var productBasicPrice: Double?
    //var productID: String?
    var productID: String?
    var productName: String?
    var productOldPrice: Double?
    var productTotal: Double?
    var questions: String?
    var storeQty: Int?
    var userCommission: Double?
    var userCommissionByCategory: [CategoryCommissionDetails]?
    
    var productPrice: Double?
    var discountPrice: Double?
    var quantity: Double?
    var productUnitMesurement: String?
    var moq: Double?
    var moqUnit: String?
    var packSize: String?
    //var product_unit: String?
    
    // Dashboard
    var reMarkName: String?
    
    
    enum CodingKeys: String, CodingKey {
        case id, productCode, name, showWarehouse, isNill, remark
        case description, unitPrice, inStock, tax, hsnNumber, status, companyType, categoryName, lastPrice, categoryId, isOtherProduct, warehouseQty, inCommited, available, productWarehouse
        //case categoryID = "categoryId"
        case commission
        case discountAmount = "discount_amount"
        case discountPrice = "discount_price"
        case maxDiscount
        case packSize = "pack_size"
        case productUnitMesurement
        case productBasicPrice = "product_basic_price"
        //case productCode = "product_code"
        case productID = "product_id"
        case moq
        case productName = "product_name"
        case productOldPrice = "product_old_price"
        case productPrice = "product_price"
        case quantity
        case productTotal = "product_total"
        case productUnit
        //case product_unit
        case moqUnit = "moq_unit"
        case questions, storeQty, userCommission, userCommissionByCategory
        
        // Dashboard
        case reMarkName
    }
}

// MARK: - ProductWarehouse
struct DraftProductWarehouse: Codable {
    var productId: Int?
    var branchId: Int?
    var inStock: String?
    //var inStock: Int?
    var inCommited: String?
    var available: String?
    
    var city: String?
    
    // Dashboard
    var branchName: String?
}

// MARK: - Transporter
struct DraftTransporter: Codable {
    var transporterId: Int?
    var transporterTitle: String?
    
    // Add BP Transporter
    var transporterCode: String?
    var transporterGSTNo: String?
    var companyType: Int?
    
    // Add Sales Order
    var position: Bool?
}

//// MARK: - TransportNamelist
//struct TransportNamelist: Codable {
//    var position: Bool?
//    var transporterCode: String?
//    var transporterGSTNo: String?
//    var transporterID: String?
//    var transporterTitle: String?
//
//    enum CodingKeys: String, CodingKey {
//        case position, transporterCode, transporterGSTNo
//        case transporterID = "transporterId"
//        case transporterTitle
//    }
//}

// MARK: - Booking Point
struct BookingPoint: Codable {
    var id: String?
    var bookingPoint: String?
}

// MARK: - GstResult
struct GstResult: Codable {
    var igstAmount: Double?
    var cgstAmount: Double?
    var sgstAmount: Double?
    var gstTotal: Double?
}

// MARK: - ImgUpload
struct ImgUpload: Codable {
    var id: Int?
    var img: String?
    var comment: String?
    var isNew: Bool? = false
}


/**** Draft Orders */
// MARK: - DraftOrder
struct DraftOrder: Codable {
    var id: Int?
    var userID: Int?
    var orderType: Int?
    var businessPartnersId: Int?
    var businessPartnersName: String?
    var jsonData: String?
    var orderDate: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "userId"
        case orderType
        case businessPartnersId
        case businessPartnersName
        case jsonData
        case orderDate
    }
}
