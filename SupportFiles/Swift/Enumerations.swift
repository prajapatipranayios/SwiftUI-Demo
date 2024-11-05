//
//  Enumerations.swift
//  - Contains Global Configuration required for whole Tussly App like Fonts, Colors.

//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import UIKit

enum Fonts
{
    case Regular, Bold, Medium
    
    func returnFont(size: CGFloat) -> UIFont {
        switch self {
            case .Regular:
                return UIFont(name: "Roboto", size: size) ?? UIFont.systemFont(ofSize: size)
            case .Medium:
                return UIFont(name: "Roboto-Medium", size: size) ?? UIFont.systemFont(ofSize: size)
            case .Bold:
                return UIFont(name: "Roboto-Bold", size: size) ?? UIFont.systemFont(ofSize: size)
            
        }
    }
}

// MARK: - Colors

enum Colors {
    case theme, black, gray, lightGray, successMsg, wrongMsg, themeDisable, validationMsg ,disable, disableButton, separator, themeRed, themeGreen, titleLabel, borderColor, darkGray, themeYellow
    
    func returnColor() -> UIColor {
        switch self {
        case .theme:
            //return UIColor(hexString: "#3E4182", alpha: 1.0)  //  Novasol
            return UIColor(hexString: "#007AFF", alpha: 1.0)
        case .black:
            return UIColor(red: 35.0/255.0, green: 35.0/255.0, blue: 35.0/255.0, alpha: 1.0)
        case .gray:
            return UIColor(hexString: "#A1A1A1", alpha: 1.0)
        case .lightGray:
            return UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        case .successMsg:
            return UIColor(red: 48.0/255.0, green:174.0/255.0, blue:51.5/255.0, alpha:1.0)
        case .wrongMsg:
            return UIColor(red: 198.0/255.0, green:26.0/255.0, blue:27.0/255.0, alpha:1.0)
        case .themeDisable:
            return UIColor(hexString: "#A1A1A1", alpha: 1.0)
        case .validationMsg:    //#FF4A40
            return UIColor(red: 255.0/255.0, green:74.0/255.0, blue:64.0/255.0, alpha:1.0)
        case .disable:
            return UIColor(red: 221.0/255.0, green:221.0/255.0, blue:221.0/255.0, alpha:0.5)
        case .disableButton:
            return UIColor(red: 149.0/255.0, green:149.0/255.0, blue:149.0/255.0, alpha:1)
        case .separator:
            return UIColor(hexString: "#A1A1A1", alpha: 1.0)
        case .themeRed:
            return UIColor(hexString: "#F90404", alpha: 1.0)
        case .themeGreen:
            return UIColor(hexString: "#0BA100", alpha: 1.0)
        case .titleLabel:
            return UIColor(hexString: "#303030", alpha: 1.0)
        case .borderColor:
            return UIColor(hexString: "#CFCFCF", alpha: 0.4)
        case .darkGray:
            return UIColor(hexString: "#54656F", alpha: 1.0)
        case .themeYellow:
            return UIColor(hexString: "#FFF700", alpha: 1.0)
        }
    }
}

// MARK: - Order Status and Colors

//1 -> pending_status_color
//2 -> approved_status_color
//3 -> in_process_status_color
//4 -> completed_status_color
//5 -> reject_back_color
//6 -> hold_status_color
//7 -> reject_back_color
//9 -> open_status_color
//11 -> so_booked_in_sap
//12 -> approved_status_color
//13 -> in_process_status_color
//14 -> completed_status_color
//15 -> invoice_generated
//16 -> hold_status_color
//17 -> material_dispatched
//18 -> deliverd_status_color
//19 -> open_status_color
//20 -> so_booked_in_sap
//21 -> so_booked_in_sap
//22 -> reject_back_color

//1 -> "Pending"
//2 -> "Approved"
//3 -> "In Process"
//4 -> "Completed"
//5 -> "Cancelled"
//6 -> "Hold"
//7 -> "Rejected"
//8 -> "Dispatched"
//9 -> "Open"
//11 -> "S.O Booked in SAP"
//12 -> "S.O Approval in SAP"
//13 -> "Delivery Generated"
//14 -> "Partially Delivery Generated"
//15 -> "Invoice Generated"
//16 -> "Partially Invoice Generated"
//17 -> "Material Dispatched"
//18 -> "Partially Material Dispatched"
//19 -> "S.O. Cancelled in SAP"
//20 -> "QI Booked in SAP"
//21 -> "PI Booked in SAP"
//22 -> "S.O. Rejected in SAP"
//else -> "Pending"

//pendingStatus = 1,
//approvedStatus = 2, 12
//inProcessStatus = 3, 13
//completedStatus = 4, 14
//rejectBack = 5, 7, 22
//holdStatus = 6, 16,
//openStatus = 9, 19,
//soBookedInSap = 11, 20, 21
//invoiceGenerated = 15
//materialDispatched = 17
//deliverdStatus = 18

// Extra Color
//"header_color" = #595959
//"status_number_color" = #6b6c6c
//"ruppees_color" = #00a3e4
//"products_color" = #6b6c6c
//"approve_back_color" = #45a200
//"reject_bg_color" = #E9C0C0
//"reject_color" = #FF0800
//"partial_completed_color" = #009688
//"cancel_status_color" = #e91f1f
//"purchase_manager_heighlight" = #C8C5C5

enum OrderStatus {
    case pendingStatus,
         approvedStatus,
         inProcessStatus,
         completedStatus,
         rejectBack,
         holdStatus,
         openStatus,
         soBookedInSap,
         invoiceGenerated,
         materialDispatched,
         deliverdStatus,
         partiallyCompleted
    
    var statusColor: UIColor {
        switch self {
        case .pendingStatus:                                    //  1
            return UIColor(hexString: "#E18F00", alpha: 1.0)
        case .approvedStatus:                                   //  2, 12
            return UIColor(hexString: "#0BA100", alpha: 1.0)
        case .inProcessStatus:                                  //  3, 13
            return UIColor(hexString: "#C708FC", alpha: 1.0)
        case .completedStatus:                                  //  4, 14
            return UIColor(hexString: "#00A3E4", alpha: 1.0)
        case .rejectBack:                                       //  5, 7, 22
            return UIColor(hexString: "#E91F1F", alpha: 1.0)
        case .holdStatus:                                       //  6, 16
            return UIColor(hexString: "#FF00FF", alpha: 1.0)
        case .openStatus:                                       //  9, 19
            return UIColor(hexString: "#697405", alpha: 1.0)
        case .soBookedInSap:                                    //  11, 20, 21
            return UIColor(hexString: "#0A98d0", alpha: 1.0)
        case .invoiceGenerated:                                 //  15
            return UIColor(hexString: "#633020", alpha: 1.0)
        case .materialDispatched:                               //  17
            return UIColor(hexString: "#D8571C", alpha: 1.0)
        case .deliverdStatus:                                   //  18
            return UIColor(hexString: "#0B50FF", alpha: 1.0)
        case .partiallyCompleted:                               //  -
            return UIColor(hexString: "#009688", alpha: 1.0)
        }
    }

    static func getStatusColor(status: Int) -> UIColor {
        switch status {
        case 1:                 //  "Pending"
            return OrderStatus.pendingStatus.statusColor
        case 2, 12:             //  "Approved", "S.O Approval in SAP"
            return OrderStatus.approvedStatus.statusColor
        case 3, 13:             //  "In Process", "Delivery Generated"
            return OrderStatus.inProcessStatus.statusColor
        case 4, 14:             //  "Completed", "Partially Delivery Generated"
            return OrderStatus.completedStatus.statusColor
        case 5, 7, 22:          //  "Cancelled", "Rejected", "S.O Rejected in SAP"
            return OrderStatus.rejectBack.statusColor
        case 6, 16:             //  "Hold", "Partially Invoice Generated"
            return OrderStatus.holdStatus.statusColor
        case 9, 19:             //  "Open", "S.O Cancelled in SAP"
            return OrderStatus.openStatus.statusColor
        case 11, 20, 21:        //  "S.O Booked in SAP", "PI Booked in SAP", "QI Booked in SAP"
            return OrderStatus.soBookedInSap.statusColor
        case 15:                //  "Invoice Generated"
            return OrderStatus.invoiceGenerated.statusColor
        case 17:                //  "Material Dispatched"
            return OrderStatus.materialDispatched.statusColor
        case 18:                //  "Partially Material Dispatched"
            return OrderStatus.deliverdStatus.statusColor
        default:
            return UIColor(hexString: "#A1A1A1", alpha: 1.0)
        }
    }
    
    static func getStatusColor(status: String) -> UIColor {
        switch status {
        case "Pending":                                         //1
            return OrderStatus.pendingStatus.statusColor
        case "Approved":                                        //2
            return OrderStatus.approvedStatus.statusColor
        case "Completed":                                       //4
            return OrderStatus.completedStatus.statusColor
        case "Rejected":                                        //7
            return OrderStatus.rejectBack.statusColor
        case "Hold":                                            //6
            return OrderStatus.holdStatus.statusColor
        
        
        case "Partially_Completed":
            return OrderStatus.partiallyCompleted.statusColor
        /*case "Pending":                                                         //1
            return OrderStatus.pendingStatus.statusColor
        case "Approved", "S.O Approval in SAP" :                                //2, 12:
            return OrderStatus.approvedStatus.statusColor
        case "In Process", "Delivery Generated":                                //3, 13:
            return OrderStatus.inProcessStatus.statusColor
        case "Completed", "Partially Delivery Generated":                       //4, 14:
            return OrderStatus.completedStatus.statusColor
        case "Cancelled", "Rejected", "S.O Rejected in SAP":                    //5, 7, 22:
            return OrderStatus.rejectBack.statusColor
        case "Hold", "Partially Invoice Generated":                             //6, 16:
            return OrderStatus.holdStatus.statusColor
        case "Open", "S.O Cancelled in SAP":                                    //9, 19:
            return OrderStatus.openStatus.statusColor
        case "S.O Booked in SAP", "PI Booked in SAP", "QI Booked in SAP":       //11, 20, 21:
            return OrderStatus.soBookedInSap.statusColor
        case "Invoice Generated":                                               //15:
            return OrderStatus.invoiceGenerated.statusColor
        case "Material Dispatched":                                             //17:
            return OrderStatus.materialDispatched.statusColor
        case "Partially Material Dispatched":                                   //18:
            return OrderStatus.deliverdStatus.statusColor   //  */
        default:
            return UIColor(hexString: "#A1A1A1", alpha: 1.0)
        }
    }
    
    static func getStatusTitle(status: Int) -> String {
        switch status {
        case 1:
            return "Pending"
        case 2:
            return "Approved"
        case 3:
            return "In Process"
        case 4:
            return "Completed"
        case 5:
            return "Cancelled"
        case 6:
            return "Hold"
        case 7:
            return "Rejected"
        case 8:
            return "Dispatched"
        case 9:
            return "Open"
        case 11:
            return "S.O Booked in SAP"
        case 12:
            return "S.O Approval in SAP"
        case 13:
            return "Delivery Generated"
        case 14:
            return "Partially Delivery Generated"
        case 15:
            return "Invoice Generated"
        case 16:
            return "Partially Invoice Generated"
        case 17:
            return "Material Dispatched"
        case 18:
            return "Partially Material Dispatched"
        case 19:
            return "S.O Cancelled in SAP"
        case 20:
            return "QI Booked in SAP"
        case 21:
            return "PI Booked in SAP"
        case 22:
            return "S.O Rejected in SAP"
        default:
            return "Pending"
        }
    }
}

enum Gender: Int {
    case MALE = 0, FEMALE, OTHER, PREFER_NOT_TO_SAY
}

enum AppInfo
{
    case AppTitle, DeviceId, Platform, GoogleClientID, GCMSenderId, YoutubeAPIKey  //Version, DeviceName, DeviceModel, AppType, GoogleClientID
    
    func returnAppInfo() -> String {
        switch self {
        case .AppTitle:
            return "Tussly"
            //            case .Version:
            //                return Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
            //            case .DeviceName:
            //                return UIDevice.current.name
            //            case .DeviceModel:
            //                return UIDevice.current.model
        case .DeviceId:
            return (UIDevice.current.identifierForVendor?.uuidString)!
        case .Platform:
            return "IOS"
            //            case .AppType:
            //                return "1"
        case .GoogleClientID:
            return "544075321874-81icuj32b0loq67k0c8hp0ubkjqevm27.apps.googleusercontent.com"
        case .GCMSenderId:
            return "544075321874"
        case .YoutubeAPIKey:
            return "AIzaSyDRLDz7A624PlReDbH0cCzMiE6N7OO-M08"
            
        }
    }
}

// MARK: - Role Wise Category
/**
 Role
 1  -  Admin = "Admin"
 2  -  Employee = "Employee"
 3  -  ZonalManager = "Zonal Manager"
 4  -  NationalManager = "National Manager"
 5  -  SuperAdmin = "Super Admin"
 6  -  HR = "HR"
 7  -  HRAdmin = "HR Admin"
 8  -  Finance = "Finance"
 9  -  Support = "Support"
 10 - CommonUser = "Common User"
 11 - SPZonalManager = "SPZonal Manager"
 12 - CommissionUser = "Commission User"
 13 - PurchaseManager = "Purchase Manager"
 14 - GroupManagerFinance = "Group Manager Finance"
 15 - BusinessPartnerAccess = "Business PartnerAccess"
 16 - TPM = "TPM"
 17 - RandD = "R&D"
 18 - ApplicationSpecialist = "Application Specialist"
 19 - Manager = "Manager"
 */

enum HomeCategory: String, CaseIterable {
    case home = "Home"
    case products = "Product History"
    case businessPartners = "Business Partner"
    case salesOrder = "Sales Order"
    case sampleRequest = "Sample Request"
    case quotation = "Quotations"
    case proformaInvoice = "Proforma Invoice"
    case commission = "Commission"
    case followUp = "Follow Up"
    case draftOrder = "Draft Sales Order"
    //case pendingOrder = "Pending Order"
    case dashboard = "Dashboard"
    case target = "Target"
    case salesPerformance = "Sales Performance"
    case crm = "CRM"
    
    case notification = "Notifications"
    case support = "Support"
    case chat = "Chat"
    case settings = "Settings"
}

enum TaDa: String, CaseIterable {
    case MTP = "MTP"
    case DVR = "DVR"
    case Expense = "Expense"
    
    func getFName() -> String {
        switch self {
        case .MTP:
            return "Monthly Tour Plan"
        case .DVR:
            return "Daily Visit Report"
        case .Expense:
            return "Expense"
        }
    }
}

enum Role {
    case Admin
    case Employee
    case ZonalManager
    case NationalManager
    case SuperAdmin
    case HR
    case HRAdmin
    case Finance
    case Support
    case CommonUser
    case SPZonalManager
    case CommissionUser
    case PurchaseManager
    case GroupManagerFinance
    case BusinessPartnerAccess
    case TPM
    case RandD
    case ApplicationSpecialist
    case Manager
    
    var section: Int {
        switch self {
        case .Admin:
            return 2
        case .Employee:
            return 2
        case .ZonalManager:
            return 2
        case .NationalManager:
            return 2
        case .SuperAdmin:
            return 2
        case .HR:
            return 2
        case .HRAdmin:
            return 2
        case .Finance:
            return 2
        case .Support:
            return 2
        case .CommonUser:
            return 2
        case .SPZonalManager:
            return 2
        case .CommissionUser:
            return 2
        case .PurchaseManager:
            return 2
        case .GroupManagerFinance:
            return 2
        case .BusinessPartnerAccess:
            return 2
        case .TPM:
            return 2
        case .RandD:
            return 1
        case .ApplicationSpecialist:
            return 1
        case .Manager:
            return 1
        }
    }
    
    var categoryCell: [String] {
        switch self {
        case .Admin:                    //  1
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .Employee:                 //  2
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
        case .ZonalManager:             //  3
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
        case .NationalManager:          //  4
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
        case .SuperAdmin:               //  5
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .HR:                       //  6
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .HRAdmin:                  //  7
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .Finance:                  //  8
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .Support:                  //  9
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .CommonUser:               //  10
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
        case .SPZonalManager:           //  11
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .CommissionUser:           //  12
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .PurchaseManager:          //  13
            return ["Product History", "Business Partner", "Sales Order", "Quotations", "Proforma Invoice", "Dashboard"]
        case .GroupManagerFinance:      //  14
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .BusinessPartnerAccess:    //  15
            return ["Business Partner", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
        case .TPM:                      //  16
            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
        case .RandD:                    //  17
            return ["CRM"]
        case .ApplicationSpecialist:    //  18
            return ["CRM"]
        case .Manager:                  //  19
            return ["CRM"]
        }
    }
    
    var TADACell: [String] {
        switch self {
        case .Admin:
            return ["MTP", "DVR", "Expense"]
        case .Employee:
            return ["MTP", "DVR", "Expense"]
        case .ZonalManager:
            return ["MTP", "DVR", "Expense"]
        case .NationalManager:
            return ["MTP", "DVR", "Expense"]
        case .SuperAdmin:
            return ["MTP", "DVR", "Expense"]
        case .HR:
            return ["MTP", "DVR", "Expense"]
        case .HRAdmin:
            return ["MTP", "DVR", "Expense"]
        case .Finance:
            return ["MTP", "DVR", "Expense"]
        case .Support:
            return ["MTP", "DVR", "Expense"]
        case .CommonUser:
            return ["MTP", "DVR", "Expense"]
        case .SPZonalManager:
            return ["MTP", "DVR", "Expense"]
        case .CommissionUser:
            return ["MTP", "DVR", "Expense"]
        case .PurchaseManager:
            return ["MTP", "DVR", "Expense"]
        case .GroupManagerFinance:
            return ["MTP", "DVR", "Expense"]
        case .BusinessPartnerAccess:
            return ["MTP", "DVR", "Expense"]
        case .TPM:
            return ["MTP", "DVR", "Expense"]
        case .RandD:
            return []
        case .ApplicationSpecialist:
            return []
        case .Manager:
            return []
        }
    }
    
    var SideMenu: [String] {
        switch self {
        case .Admin:                    ///  1
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .Employee:                 ///  2
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .ZonalManager:             ///  3
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .NationalManager:          ///  4
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .SuperAdmin:               ///  5
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .HR:                       ///  6
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .HRAdmin:                  ///  7
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .Finance:                  ///  8
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .Support:                  ///  9
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .CommonUser:               ///  10
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .SPZonalManager:           ///  11
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .CommissionUser:           ///  12
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .PurchaseManager:          ///  13
            return ["Home", "Product History", "Business Partner", "Sales Order", "Quotations", "Proforma Invoice", "Dashboard", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .GroupManagerFinance:      ///  14
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .BusinessPartnerAccess:    ///  15
            return ["Home", "Business Partner", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .TPM:                      ///  16
            return ["Home", "Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM", "Monthly Tour Plan", "Daily Visit Report", "Expense", "Notifications", "Support", "Chat", "Settings"]
        case .RandD:                    ///  17
            return ["Home", "CRM", "Notifications", "Support", "Chat", "Settings"]
        case .ApplicationSpecialist:    ///  18
            return ["Home", "CRM", "Notifications", "Support", "Chat", "Settings"]
        case .Manager:                  ///  19
            return ["Home", "CRM", "Notifications", "Support", "Chat", "Settings"]
        }
    }
    
    static func getInfo(forRole: Int) -> (colleSection: Int?, categoryCell: [String]?, TADACell: [String]?) {
        switch forRole {
        case 1:
            return (Role.Admin.section, Role.Admin.categoryCell, Role.Admin.TADACell)
        case 2:
            return (Role.Employee.section, Role.Employee.categoryCell, Role.Employee.TADACell)
        case 3:
            return (Role.ZonalManager.section, Role.ZonalManager.categoryCell, Role.ZonalManager.TADACell)
        case 4:
            return (Role.NationalManager.section, Role.NationalManager.categoryCell, Role.NationalManager.TADACell)
        case 5:
            return (Role.SuperAdmin.section, Role.SuperAdmin.categoryCell, Role.SuperAdmin.TADACell)
        case 6:
            return (Role.HR.section, Role.HR.categoryCell, Role.HR.TADACell)
        case 7:
            return (Role.HRAdmin.section, Role.HRAdmin.categoryCell, Role.HRAdmin.TADACell)
        case 8:
            return (Role.Finance.section, Role.Finance.categoryCell, Role.Finance.TADACell)
        case 9:
            return (Role.Support.section, Role.Support.categoryCell, Role.Support.TADACell)
        case 10:
            return (Role.CommonUser.section, Role.CommonUser.categoryCell, Role.CommonUser.TADACell)
        case 11:
            return (Role.SPZonalManager.section, Role.SPZonalManager.categoryCell, Role.SPZonalManager.TADACell)
        case 12:
            return (Role.CommissionUser.section, Role.CommissionUser.categoryCell, Role.CommissionUser.TADACell)
        case 13:
            return (Role.PurchaseManager.section, Role.PurchaseManager.categoryCell, Role.PurchaseManager.TADACell)
        case 14:
            return (Role.GroupManagerFinance.section, Role.GroupManagerFinance.categoryCell, Role.GroupManagerFinance.TADACell)
        case 15:
            return (Role.BusinessPartnerAccess.section, Role.BusinessPartnerAccess.categoryCell, Role.BusinessPartnerAccess.TADACell)
        case 16:
            return (Role.TPM.section, Role.TPM.categoryCell, Role.TPM.TADACell)
        case 17:
            return (Role.RandD.section, Role.RandD.categoryCell, Role.RandD.TADACell)
        case 18:
            return (Role.ApplicationSpecialist.section, Role.ApplicationSpecialist.categoryCell, Role.ApplicationSpecialist.TADACell)
        case 19:
            return (Role.Manager.section, Role.Manager.categoryCell, Role.Manager.TADACell)
        default:
            return (Role.Manager.section, Role.Manager.categoryCell, Role.Manager.TADACell)
        }
    }
    
    static func getSideMenu(forRole: Int) -> [String] {
        switch forRole {
        case 1:
            return Role.Admin.SideMenu
        case 2:
            return Role.Employee.SideMenu
        case 3:
            return Role.ZonalManager.SideMenu
        case 4:
            return Role.NationalManager.SideMenu
        case 5:
            return Role.SuperAdmin.SideMenu
        case 6:
            return Role.HR.SideMenu
        case 7:
            return Role.HRAdmin.SideMenu
        case 8:
            return Role.Finance.SideMenu
        case 9:
            return Role.Support.SideMenu
        case 10:
            return Role.CommonUser.SideMenu
        case 11:
            return Role.SPZonalManager.SideMenu
        case 12:
            return Role.CommissionUser.SideMenu
        case 13:
            return Role.PurchaseManager.SideMenu
        case 14:
            return Role.GroupManagerFinance.SideMenu
        case 15:
            return Role.BusinessPartnerAccess.SideMenu
        case 16:
            return Role.TPM.SideMenu
        case 17:
            return Role.RandD.SideMenu
        case 18:
            return Role.ApplicationSpecialist.SideMenu
        case 19:
            return Role.Manager.SideMenu
        default:
            return Role.Manager.SideMenu
        }
    }
    
    static func canAddBusinessP(forRole: Int) -> Bool {
        switch forRole {
        case 1:
            return false
        case 2:
            return true
        case 3:
            return true
        case 4:
            return true
        case 5:
            return false
        case 6:
            return false
        case 7:
            return false
        case 8:
            return false
        case 9:
            return false
        case 10:
            return false
        case 11:
            return false
        case 12:
            return true
        case 13:
            return false
        case 14:
            return false
        case 15:
            return false
        case 16:
            return false
        case 17:
            return false
        case 18:
            return false
        case 19:
            return false
        default:
            return false
        }
    }
    
    static func IsSalesPersonVisible(forRole: Int) -> Bool {
        return !([2].contains(forRole))
    }
}

enum TableColleTitle {
    static func getTitles(key: String) -> [[String]] {
        switch key {
        case "BusinessPDetails":
            return [["Sales Order", "Sample Request", "Quotations", "Proforma Invoice"], ["Company", "Contact", "Address", "Transporter(s)"], ["Purchased Products", "Client History"]]
        case "BPProductDetails":
            return [["Date", "Qty", "Amount"]]
        default:
            return [[]]
        }
    }
}

//enum UserRole: String, CaseIterable {
//    
//    case Admin = "Admin"
//    case Employee = "Employee"
//    case ZonalManager = "Zonal Manager"
//    case NationalManager = "National Manager"
//    case SuperAdmin = "Super Admin"
//    case HR = "HR"
//    case HRAdmin = "HR Admin"
//    case Finance = "Finance"
//    case Support = "Support"
//    case CommonUser = "Common User"
//    case SPZonalManager = "SPZonal Manager"
//    case CommissionUser = "Commission User"
//    case PurchaseManager = "Purchase Manager"
//    case GroupManagerFinance = "Group Manager Finance"
//    case BusinessPartnerAccess = "Business PartnerAccess"
//    case TPM = "TPM"
//    case RandD = "R&D"
//    case ApplicationSpecialist = "Application Specialist"
//    case Manager = "Manager"
//
//    func section() -> Int {
//        switch self {
//        case .Admin:
//            return 2
//        case .Employee:
//            return 2
//        case .ZonalManager:
//            return 2
//        case .NationalManager:
//            return 2
//        case .SuperAdmin:
//            return 2
//        case .HR:
//            return 2
//        case .HRAdmin:
//            return 2
//        case .Finance:
//            return 2
//        case .Support:
//            return 2
//        case .CommonUser:
//            return 2
//        case .SPZonalManager:
//            return 2
//        case .CommissionUser:
//            return 2
//        case .PurchaseManager:
//            return 2
//        case .GroupManagerFinance:
//            return 2
//        case .BusinessPartnerAccess:
//            return 2
//        case .TPM:
//            return 2
//        case .RandD:
//            return 1
//        case .ApplicationSpecialist:
//            return 1
//        case .Manager:
//            return 1
//        }
//    }
//    
//    func categoryCell() -> [String] {
//        switch self {
//        case .Admin:                    //  1
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .Employee:                 //  2
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
//        case .ZonalManager:             //  3
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
//        case .NationalManager:          //  4
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
//        case .SuperAdmin:               //  5
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .HR:                       //  6
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .HRAdmin:                  //  7
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .Finance:                  //  8
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .Support:                  //  9
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .CommonUser:               //  10
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
//        case .SPZonalManager:           //  11
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .CommissionUser:           //  12
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .PurchaseManager:          //  13
//            return ["Product History", "Business Partner", "Sales Order", "Quotations", "Proforma Invoice", "Commission", "Dashboard"]
//        case .GroupManagerFinance:      //  14
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .BusinessPartnerAccess:    //  15
//            return ["Business Partner", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance"]
//        case .TPM:                      //  16
//            return ["Product History", "Business Partner", "Sales Order", "Sample Request", "Quotations", "Proforma Invoice", "Commission", "Follow Up", "Draft Sales Order", "Dashboard", "Target", "Sales Performance", "CRM"]
//        case .RandD:                    //  17
//            return ["CRM"]
//        case .ApplicationSpecialist:    //  18
//            return ["CRM"]
//        case .Manager:                  //  19
//            return ["CRM"]
//        }
//    }
//    
//    func TADACell() -> [String] {
//        switch self {
//        case .Admin:
//            return ["MTP", "DVR", "Expense"]
//        case .Employee:
//            return ["MTP", "DVR", "Expense"]
//        case .ZonalManager:
//            return ["MTP", "DVR", "Expense"]
//        case .NationalManager:
//            return ["MTP", "DVR", "Expense"]
//        case .SuperAdmin:
//            return ["MTP", "DVR", "Expense"]
//        case .HR:
//            return ["MTP", "DVR", "Expense"]
//        case .HRAdmin:
//            return ["MTP", "DVR", "Expense"]
//        case .Finance:
//            return ["MTP", "DVR", "Expense"]
//        case .Support:
//            return ["MTP", "DVR", "Expense"]
//        case .CommonUser:
//            return ["MTP", "DVR", "Expense"]
//        case .SPZonalManager:
//            return ["MTP", "DVR", "Expense"]
//        case .CommissionUser:
//            return ["MTP", "DVR", "Expense"]
//        case .PurchaseManager:
//            return ["MTP", "DVR", "Expense"]
//        case .GroupManagerFinance:
//            return ["MTP", "DVR", "Expense"]
//        case .BusinessPartnerAccess:
//            return ["MTP", "DVR", "Expense"]
//        case .TPM:
//            return ["MTP", "DVR", "Expense"]
//        case .RandD:
//            return []
//        case .ApplicationSpecialist:
//            return []
//        case .Manager:
//            return []
//        }
//    }
//    
//    static func getInfo(role: Int) -> (colleSection: Int?, categoryCell: [String]?, TADACell: [String]?) {
//        switch role {
//        case 1:
//            return (UserRole.Admin.section(), UserRole.Admin.categoryCell(), UserRole.Admin.TADACell())
//        case 2:
//            return (UserRole.Employee.section(), UserRole.Employee.categoryCell(), UserRole.Employee.TADACell())
//        case 3:
//            return (UserRole.ZonalManager.section(), UserRole.ZonalManager.categoryCell(), UserRole.ZonalManager.TADACell())
//        case 4:
//            return (UserRole.NationalManager.section(), UserRole.NationalManager.categoryCell(), UserRole.NationalManager.TADACell())
//        case 5:
//            return (UserRole.SuperAdmin.section(), UserRole.SuperAdmin.categoryCell(), UserRole.SuperAdmin.TADACell())
//        case 6:
//            return (UserRole.HR.section(), UserRole.HR.categoryCell(), UserRole.HR.TADACell())
//        case 7:
//            return (UserRole.HRAdmin.section(), UserRole.HRAdmin.categoryCell(), UserRole.HRAdmin.TADACell())
//        case 8:
//            return (UserRole.Finance.section(), UserRole.Finance.categoryCell(), UserRole.Finance.TADACell())
//        case 9:
//            return (UserRole.Support.section(), UserRole.Support.categoryCell(), UserRole.Support.TADACell())
//        case 10:
//            return (UserRole.CommonUser.section(), UserRole.CommonUser.categoryCell(), UserRole.CommonUser.TADACell())
//        case 11:
//            return (UserRole.SPZonalManager.section(), UserRole.SPZonalManager.categoryCell(), UserRole.SPZonalManager.TADACell())
//        case 12:
//            return (UserRole.CommissionUser.section(), UserRole.CommissionUser.categoryCell(), UserRole.CommissionUser.TADACell())
//        case 13:
//            return (UserRole.PurchaseManager.section(), UserRole.PurchaseManager.categoryCell(), UserRole.PurchaseManager.TADACell())
//        case 14:
//            return (UserRole.GroupManagerFinance.section(), UserRole.GroupManagerFinance.categoryCell(), UserRole.GroupManagerFinance.TADACell())
//        case 15:
//            return (UserRole.BusinessPartnerAccess.section(), UserRole.BusinessPartnerAccess.categoryCell(), UserRole.BusinessPartnerAccess.TADACell())
//        case 16:
//            return (UserRole.TPM.section(), UserRole.TPM.categoryCell(), UserRole.TPM.TADACell())
//        case 17:
//            return (UserRole.RandD.section(), UserRole.RandD.categoryCell(), UserRole.RandD.TADACell())
//        case 18:
//            return (UserRole.ApplicationSpecialist.section(), UserRole.ApplicationSpecialist.categoryCell(), UserRole.ApplicationSpecialist.TADACell())
//        case 19:
//            return (UserRole.Manager.section(), UserRole.Manager.categoryCell(), UserRole.Manager.TADACell())
//        default:
//            return (UserRole.Manager.section(), UserRole.Manager.categoryCell(), UserRole.Manager.TADACell())
//        }
//    }
//}

enum Sort: String, CaseIterable {
    case Newest = "new-to-old"
    case Oldest = "old-to-new"
    case Ascending = "asc"
    case Descending = "desc"
    
    static func passingValue(sort : Sort) -> String {
        switch sort {
        case .Newest:
            return Sort.Newest.rawValue
        case .Oldest:
            return Sort.Oldest.rawValue
        case .Ascending:
            return Sort.Ascending.rawValue
        case .Descending:
            return Sort.Descending.rawValue
        }
    }
    
    static func displayValue() -> [String] {
        return ["Newest", "Oldest", "A - Z", "Z - A"]
    }
}

enum ClientStatusColors {
    case Pending
    case Verified
    
    static func statusColor(status: String) -> UIColor {
        switch status {
        case "Pending":
            return UIColor(hexString: "#FE9B4B", alpha: 1.0)
        case "Verified":
            return UIColor(hexString: "#0BA100", alpha: 1.0)
        default:
            return UIColor(hexString: "#A1A1A1", alpha: 1.0)
        }
    }
}

enum PaymentTypes {
    static func getPaymentType(type: Int) -> String {
        switch type {
        case 1:
            return "Advance Payment"
        case 2:
            return "Against Delivery"
        case 3:
            return "Credit Days"
        case 4:
            return "Against PDC(Post Dated Cheque)"
        default:
            return "-"
        }
    }
}

enum SampleOrderQuestions {
    static func questions(no: Int) -> String {
        switch no {
        case 1:
            return "1.Sample for which applications?"
        case 2:
            return "2.Trial Batch Size?"
        case 3:
            return "3.Which brand/product client is currently using?"
        case 4:
            return "4.What is potential?"
        default:
            return ""
        }
    }
}

enum BusinessP {
    static func getTrialHistoryStatus(status: Int) -> String {
        switch status {
        case 1:
            return "Approve(Quotation or PI)"
        case 2:
            return "Win(Create sales order)"
        case 3:
            return "Reject"
        case 4:
            return "WIP(work in process)"
        default:
            return "Pending"
        }
    }
}

enum AddBusinessPartner {
    static func getTab() -> [String] {
        return [ "Company",
                 "Contact",
                 "Billing",
                 "Delivery",
                 "Transport"]
    }
    
    static func getPaymentType(type: String) -> String {
        switch type {
        case "Advance Payment":
            return "1"
        case "Against Delivery":
            return "2"
        case "Credit Days":
            return "3"
        case "Against PDC(Post Dated Cheque)":
            return "4"
        default:
            return "0"
        }
    }
    
    static func getCreditDays() -> [String] {
        return ["5", "7", "10", "15", "21", "30", "45", "60", "90"]
    }
    
    static func getATurnoverUnit() -> [String] {
        return ["Thousand", "Lakh", "Crore"]
    }
    
    static func getCompanyType() -> [String] {
        return ["Company Туре", "Novasol", "GUJARAT FOOD WEB", "Both"]
    }
    
    static func getBusinessType() -> [String] {
        return ["Select Business Type", "Manufacture", "Traders", "Exporter"]
    }
    
    static func getTypesOfFirms() -> [String] {
        return ["Select Type Of Firm", "Proprietors", "Partners", "LLP", "PVT", "LTD"]
    }
}

enum Settings {
    static func myTeamVisible(role: Int) -> Bool {
        return [3, 4, 11].contains(role)
    }
}

enum OrdersMScreen: String, CaseIterable {
    
    case all = "All"
    case pending = "Pending"
    case approved = "Approved"
    case sOBookedInSAP = "SO Booked in SAP"
    case qIBookedInSAP = "QI Booked in SAP"
    case pIBookedInSAP = "PI Booked in SAP"
    case sOApprovalInSAP = "SO Approval in SAP"
    case deliveryGenerated = "Delivery Generated"
    case partiallyDeliveryGenerated = "Partially Delivery Generated"
    case invoiceGenerated = "Invoice Generated"
    case partiallyInvoiceGenerated = "Partially Invoice Generated"
    case materialDispatched = "Material Dispatched"
    case partiallyMaterialDispatched = "Partially Material Dispatched"
    case sOCancelledInSAP = "SO Cancelled in SAP"
    case rejected = "Rejected"
    case sORejectedInSAP = "SO Rejected in SAP"
    case open = "Open"
    case inProcess = "In Process"
    case hold = "Hold"
    case cancelled = "Cancelled"
    case dispatched = "Dispatched"
    case completed = "Completed"
    
    case whiteColor
    case rejectColor
    case purchaseManagerHeighlightColor
    
//    [ "All",
//      "Pending",
//      "Approved",
//      "SO Booked in SAP",
//      "QI Booked in SAP",
//      "PI Booked in SAP",
//      "SO Approval in SAP",
//      "Delivery Generated",
//      "Partially Delivery Generated",
//      "Invoice Generated",
//      "Partially Invoice Generated",
//      "Material Dispatched",
//      "Partially Material Dispatched",
//      "S.O. Cancelled in SAP",
//      "Rejected",
//      "SO Rejected in SAP"
//    ]
    
    static func getTab(intScreen: Int) -> [String] {
        switch intScreen {
        case 0:     // Sales
            return [ OrdersMScreen.all.rawValue,
                     OrdersMScreen.pending.rawValue,
                     OrdersMScreen.approved.rawValue,
                     OrdersMScreen.sOBookedInSAP.rawValue,
                     OrdersMScreen.sOApprovalInSAP.rawValue,
                     OrdersMScreen.deliveryGenerated.rawValue,
                     OrdersMScreen.partiallyDeliveryGenerated.rawValue,
                     OrdersMScreen.invoiceGenerated.rawValue,
                     OrdersMScreen.partiallyInvoiceGenerated.rawValue,
                     OrdersMScreen.materialDispatched.rawValue,
                     OrdersMScreen.partiallyMaterialDispatched.rawValue,
                     OrdersMScreen.sOCancelledInSAP.rawValue,
                     OrdersMScreen.rejected.rawValue,
                     OrdersMScreen.sORejectedInSAP.rawValue
            ]
        case 1:     // QI
            return [ OrdersMScreen.all.rawValue,
                     OrdersMScreen.pending.rawValue,
                     OrdersMScreen.approved.rawValue,
                     OrdersMScreen.qIBookedInSAP.rawValue,
            ]
        case 2:     // PI
            return [ OrdersMScreen.all.rawValue,
                     OrdersMScreen.pending.rawValue,
                     OrdersMScreen.approved.rawValue,
                     OrdersMScreen.pIBookedInSAP.rawValue,
            ]
        case 3:     // Sample
            return [ OrdersMScreen.all.rawValue,
                     OrdersMScreen.pending.rawValue,
                     OrdersMScreen.open.rawValue,
                     OrdersMScreen.approved.rawValue,
                     OrdersMScreen.inProcess.rawValue,
                     OrdersMScreen.hold.rawValue,
                     OrdersMScreen.rejected.rawValue,
                     OrdersMScreen.cancelled.rawValue,
                     OrdersMScreen.dispatched.rawValue,
                     OrdersMScreen.completed.rawValue
            ]
        default:
            return []
        }
    }
    
    static func getOrderBgColor(strColor: OrdersMScreen) -> UIColor {
        switch strColor {
        case .rejectColor:
            return UIColor(hexString: "#E9C0C0", alpha: 1.0)
        case .purchaseManagerHeighlightColor:
            return UIColor(hexString: "#C8C5C5", alpha: 1.0)
        case whiteColor:
            return UIColor(hexString: "#FFFFFF", alpha: 1.0)
            
        default:
            return UIColor(hexString: "#000000", alpha: 1.0)
        }
    }
    
    static func getStatusNo(status: String) -> Int {
        switch status {
        case "Pending":
            return 1
        case "Approved":
            return 2
        case "In Process":
            return 3
        case "Completed":
            return 4
        case "Cancelled":
            return 5
        case "Hold":
            return 6
        case "Rejected":
            return 7
        case "Dispatched":
            return 8
        case "Open":
            return 9
        case "SO Booked in SAP":
            return 11
        case "SO Approval in SAP":
            return 12
        case "Delivery Generated":
            return 13
        case "Partially Delivery Generated":
            return 14
        case "Invoice Generated":
            return 15
        case "Partially Invoice Generated":
            return 16
        case "Material Dispatched":
            return 17
        case "Partially Material Dispatched":
            return 18
        case "SO Cancelled in SAP":
            return 19
        case "QI Booked in SAP":
            return 20
        case "PI Booked in SAP":
            return 21
        case "SO Rejected in SAP":
            return 22
        default:
            return 0
        }
    }
}


enum MTP {
    static func Month(_ month: String) -> Int {
        switch month {
        case "Jan" :
            return 1
        case "Feb" :
            return 2
        case "Mar" :
            return 3
        case "Apr" :
            return 4
        case "May" :
            return 5
        case "Jun" :
            return 6
        case "Jul" :
            return 7
        case "Aug" :
            return 8
        case "Sep" :
            return 9
        case "Oct" :
            return 10
        case "Nov" :
            return 11
        case "Dec" :
            return 12
        default:
            return 0
        }
    }
    static func Month(_ month: Int) -> String {
        switch month {
        case 1 :
            return "Jan"
        case 2 :
            return "Feb"
        case 3 :
            return "Mar"
        case 4 :
            return "Apr"
        case 5 :
            return "May"
        case 6 :
            return "Jun"
        case 7 :
            return "Jul"
        case 8 :
            return "Aug"
        case 9 :
            return "Sep"
        case 10 :
            return "Oct"
        case 11 :
            return "Nov"
        case 12 :
            return "Dec"
        default:
            return ""
        }
    }
}

enum DVR: String {
    case AP = "Approached for Products"
    case PC = "Payment Collection"
    case MT = "Meeting"
    case TL = "Trial"
    case WO = "Work from Office"
    case AE = "Attended Exhibition"
    case LV = "Leave"
    case OC = "Phone Call"
    
    static func getVisitFor(arrVisitFor: [String]) -> String {
        var strVisitFor: String = ""
        for (_, value) in arrVisitFor.enumerated() {
            switch value {
            case "AP":
                strVisitFor = strVisitFor == "" ? DVR.AP.rawValue : "\(strVisitFor),\(DVR.AP.rawValue)"
                break
            case "PC":
                strVisitFor = strVisitFor == "" ? DVR.PC.rawValue : "\(strVisitFor),\(DVR.PC.rawValue)"
                break
            case "MT":
                strVisitFor = strVisitFor == "" ? DVR.MT.rawValue : "\(strVisitFor),\(DVR.MT.rawValue)"
                break
            case "TL":
                strVisitFor = strVisitFor == "" ? DVR.TL.rawValue : "\(strVisitFor),\(DVR.TL.rawValue)"
                break
            case "WO":
                strVisitFor = strVisitFor == "" ? DVR.WO.rawValue : "\(strVisitFor),\(DVR.WO.rawValue)"
                break
            case "AE":
                strVisitFor = strVisitFor == "" ? DVR.AE.rawValue : "\(strVisitFor),\(DVR.AE.rawValue)"
                break
            case "LV":
                strVisitFor = strVisitFor == "" ? DVR.LV.rawValue : "\(strVisitFor),\(DVR.LV.rawValue)"
                break
            case "OC":
                strVisitFor = strVisitFor == "" ? DVR.OC.rawValue : "\(strVisitFor),\(DVR.OC.rawValue)"
                break
            default:
                break
            }
        }
        return strVisitFor
    }
    
    static func getVisitForInitials(arrVisitFor: [String]) -> String {
        var strVisitFor: String = ""
        for (_, value) in arrVisitFor.enumerated() {
            switch value {
            case DVR.AP.rawValue:
                strVisitFor = strVisitFor == "" ? "AP" : "\(strVisitFor),AP"
                break
            case DVR.PC.rawValue:
                strVisitFor = strVisitFor == "" ? "PC" : "\(strVisitFor),PC"
                break
            case DVR.MT.rawValue:
                strVisitFor = strVisitFor == "" ? "MT" : "\(strVisitFor),MT"
                break
            case DVR.TL.rawValue:
                strVisitFor = strVisitFor == "" ? "TL" : "\(strVisitFor),TL"
                break
            case DVR.WO.rawValue:
                strVisitFor = strVisitFor == "" ? "WO" : "\(strVisitFor),WO"
                break
            case DVR.AE.rawValue:
                strVisitFor = strVisitFor == "" ? "AE" : "\(strVisitFor),AE"
                break
            case DVR.LV.rawValue:
                strVisitFor = strVisitFor == "" ? "LV" : "\(strVisitFor),LV"
                break
            case DVR.OC.rawValue:
                strVisitFor = strVisitFor == "" ? "OC" : ", OC"
                break
            default:
                break
            }
        }
        return strVisitFor
    }
    
    static func getVisitFor() -> [String] {
        return [
            DVR.AP.rawValue,
            DVR.PC.rawValue,
            DVR.MT.rawValue,
            DVR.TL.rawValue,
            DVR.WO.rawValue,
            DVR.AE.rawValue,
            DVR.LV.rawValue,
            DVR.OC.rawValue
        ]
    }
    
    static func getClintProduct() -> [String] {
        return [
            "Buttermilk",
            "Biscuite",
            "Bakery",
            "Curd",
            "Candy",
            "Drinking Yogurt",
            "Flavored Milk",
            "Ice Cream",
            "Jelly",
            "Milkshake",
            "MDH",
            "Molding Chocolate",
            "Pharma",
            "Sauce",
            "Snack",
            "Sweet",
            "Toffee",
            "Way Milk",
            "Yogurt",
        ]
    }
}

enum Expenses: String {
    case none = ""
    
    static func getStatusNameColor(status: Int) -> (String, UIColor) {
        switch status {
        case 0:
            return ("Pending", OrderStatus.pendingStatus.statusColor)
        case 1:
            return ("Rejected", OrderStatus.rejectBack.statusColor)
        case 2:
            return ("Hold", OrderStatus.holdStatus.statusColor)
        case 3:
            return ("Approved", OrderStatus.approvedStatus.statusColor)
        case 4:
            return ("Completed", OrderStatus.completedStatus.statusColor)
        default:
            return ("", UIColor(hexString: "#A1A1A1"))
        }
    }
}
