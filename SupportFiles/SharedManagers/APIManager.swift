        //
//  APIManager.swift
//  - Methods required to make API calls and to handle API Response

//  Tussly
//
//  Created by Jaimesh Patel on 15/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import Foundation
import UIKit

//let HTTP_URL = "http://14.99.147.156:8585/ge_new/public/"                 //  New url for iOS
let HTTP_URL = "http://gfw.salesapp.testnftapp.com/"                      //  New common url
//let HTTP_URL = "http://amul.salesapp.testnftapp.com/"                        //  New url for tenetK
        
//let HTTP_URL = "http://192.168.2.45:8000/"                                //  LocalHost Url - Parth R
//let HTTP_URL = "http://192.168.2.44:8000/"                                //  LocalHost Url - Kishan D


let BASE_URL = HTTP_URL + "api/"

class APIManager {
    
    private init() {
    }
    
    static var sharedManager = APIManager()
    //var authToken: String = (Utilities.MD5(string: "GE@!23")).map { String(format: "%02hhx", $0) }.joined()
    var authToken: String = ""
    var userId: Int = 0
    
    var isSideMenuLoad: Bool = false
    
    var isRefreshData: Bool = false
    
    var companyType: Int? = 1
    var isCommissionActive: Bool = false
    
    
    
    // User Authentication
    let LOGIN                                       = BASE_URL + "login"
    let FORGOT_PASSWORD                             = BASE_URL + "forgotPassword"
    let LOGOUT                                      = BASE_URL + "logout"
    
    // Home
    let VIEW_USER_PROFILE                           = BASE_URL + "viewUserProfile"
    
    // Product
    let GET_PRODUCT_CATEGORIES                      = BASE_URL + "getUserCategories"
    let GET_PRODUCT_LIST                            = BASE_URL + "getProductListWithPagination"
    let PRODUCT_ORDER                               = BASE_URL + "productOrder"
    
    // Business Partner
    let GET_BUSINESS_PARTNER_LIST                   = BASE_URL + "getBusinessPartnerList"
    let EMPLOYEES_LIST                              = BASE_URL + "employeesList"
    let GET_BUSINESS_PARTNER_DETAIL                 = BASE_URL + "getSingleBusinessPartner"
    let GET_PRODUCT_LIST_FOR_BUSINESS_PARTNRE       = BASE_URL + "getProductListForBusinessPartner"
    let GENERATE_GENERAL_LEDGER                     = BASE_URL + "generateGeneralLedger"
    let GET_SINGLE_OEDER                            = BASE_URL + "getSingleOrder"           //  For Sales Order, Qi,
    let GET_SAMPLE_ORDER_DETAIL                     = BASE_URL + "getSampleOrderDetail"
    let PRODUCT_STATUS_HISTORY_HOLD_REPLY           = BASE_URL + "productStatusHistoryHoldReply"
    let GET_MY_TEAM                                 = BASE_URL + "getMyTeam"
    let GET_STATES                                  = BASE_URL + "states"
    let GET_CITIES                                  = BASE_URL + "cities"
    let GET_INDUSTRIES_CATEGORY_LIST                = BASE_URL + "industriesCategoryList"
    let SEARCH_EXIST_BUSINESS_PARTNER               = BASE_URL + "searchAlreadyAvailableBusinessPartner"
    let GET_TRANSPORTERS                            = BASE_URL + "getTransporters"
    let GST_NUMBER_VERIFY                           = BASE_URL + "gstNumberVerify"
    let ADD_TRANSPORTER                             = BASE_URL + "AddTransporter"
    let ADD_BUSINESS_PARTNER                        = BASE_URL + "addBusinessPartner"
    let GET_BRANCHES                                = BASE_URL + "branches"
    let VERIFY_BUSINESS_PARTNER                     = BASE_URL + "verifyBusinessPartner"
    
    // Sales Order
    let ORDERED_BUSINESS_PARTNERS                   = BASE_URL + "orderedBusinessPartners"
    let GET_ORDERS_LIST_BASED_ON_STATUS             = BASE_URL + "getOrdersListBasedOnStatusV2"
    let CHANGE_ORDER_STATUS                         = BASE_URL + "changeOrderStatus"
    let SAMPLE_ORDER_STATUS_CHANGE                  = BASE_URL + "sampleOrderStatusChange"
    let GET_REJECT_REASON                           = BASE_URL + "rejectReason"
    let GET_BOOKING_POINT                           = BASE_URL + "getBookingPoint"
    let SAVE_TRANSPORTER                            = BASE_URL + "saveTransporter"
    let GET_GST_CALCULATION                         = BASE_URL + "gstCalculation"
    let PLACE_DRAFT_ORDER                           = BASE_URL + "PlaceDraftOrder"
    let ADD_NEW_ORDER                               = BASE_URL + "addNewOrder"
    let SAVE_ORDER_POATTACHMENT                     = BASE_URL + "saveOrderPOAttachment"
    
    // Sample Request
    let GET_SAMPLE_ORDERS_LIST                      = BASE_URL + "getSampleOrdersList"
    let GET_BUSINESS_PARTNER_ADDRESS_DETAIL         = BASE_URL + "getBusinessPartnerAddressDetail"
    let ADD_BP_ADDRESS_DETAIL                       = BASE_URL + "addBusinessPartnerAddressDetail"
    let ADD_OTHER_PRODUCT                           = BASE_URL + "addOtherProduct"
    let PLACE_SAMPLE_ORDER                          = BASE_URL + "placeSampleOrder"
    let CHECK_BUSINESS_PARTNER_ORDER_EXIST          = BASE_URL + "checkBusinessPartnerOrderExist"
    
    // Commission
    let GET_EMPLOYEE_LIST                           = BASE_URL + "employeesList"
    let GET_USER_COMMISSION                         = BASE_URL + "getUserCommission"
    let CLAIM_COMMISSION_REQUEST                    = BASE_URL + "claimCommissionRequest"
    
    // Follow Up
    let CHANGE_SAMPLE_ORDER_DELIVERY_STATUS         = BASE_URL + "changeSampleOrderDeliveryStatus"
    let GET_SAMPLE_REPORTS_DETAILS                  = BASE_URL + "getSampleReportsDetail"
    let SUBMIT_TRAIL_REPORT                         = BASE_URL + "submitTrailReport"
    let UPLOAD_REPORT_ATTACHMENT                    = BASE_URL + "uploadReportAttachment"
    
    // Draft Order
    let GET_DRAFT_ORDER_LIST                        = BASE_URL + "draftOrderList"
    let REMOVE_DRAFT_ORDER                          = BASE_URL + "removeDraftOrder"
    
    // Dashboard
    let GET_BUSINESS_PARTNER_REPORT                 = BASE_URL + "getBusinessPartnerReport"
    let GET_SALES_ORDER_REPORT                      = BASE_URL + "getSaleOrderReport"
    let GET_EMPLOYEE_LIST_ZONE_WISE                 = BASE_URL + "employeeListZoneWise"
    let GET_USER_CATEGORIES                         = BASE_URL + "getUserCategories"
    let GET_SALES_ORDER_REPORT_DETAIL               = BASE_URL + "getSaleOrderReportDetail"
    let GET_STOCK_REPORT                            = BASE_URL + "getStockReport"
    
    // Target
    let GET_EMPLOYEE_GROUP_TARGET                   = BASE_URL + "getEmployeeGroupTarget"
    let CATEGORY_GROUP_LIST                         = BASE_URL + "categoryGroupList"
    let EMPLOYEE_LIST_ZONE_WISE                     = BASE_URL + "employeeListZoneWise"
    let GET_EMPLOYEE_TARGET                         = BASE_URL + "getEmployeeTarget"
    let GET_EMPLOYEE_TARGET_DETAILS                 = BASE_URL + "getEmployeeTargetDetails"
    
    // Sales Performance
    let GET_USER_KRA                                = BASE_URL + "getUserKRA"
    
    // MTP
    let GET_MTP_DETAILS_ON_CALENDER_VIEW            = BASE_URL + "getMtpDetailsOnCalenderView"
    let GET_MTP_MASTER_DATA                         = BASE_URL + "getMtpMasterData"
    let SUBMIT_REPLY_MTP                            = BASE_URL + "replyMtp"
    let GET_MTP_DETAILS_FILTER                      = BASE_URL + "getMtpDetailsFilter"
    let GET_EMPLOYEES                               = BASE_URL + "getEmployees"
    let GET_MTP_USED_DATE                           = BASE_URL + "getMtpUsedDate"
    let CHECK_MTP_DATE                              = BASE_URL + "checkMtpDate"
    let ADD_MPT                                     = BASE_URL + "addMtp"
    let UPDATE_MASTER_MPT                           = BASE_URL + "updateMasterMtp"
    
    // DVR
    let GET_DVR_USERS                               = BASE_URL + "getDvrUsers"
    let GET_DVR                                     = BASE_URL + "getDvr"
    let REPORT_URL                                  = BASE_URL + "reportURL"
    let GET_TADA_BUSINESS_PARTNER_LIST              = BASE_URL + "getTaDaBusinessPartnerList"
    let GET_TADA_PRODUCT_LIST                       = BASE_URL + "getTaDaProductList"
    let GET_DVR_CONTACT                             = BASE_URL + "getDvrContact"
    let CHECK_DVR_DATE                              = BASE_URL + "checkDvrDate"
    let ADD_DVR                                     = BASE_URL + "addDvr"
    
    // DVR
    let GET_EXPENSE_USERS                           = BASE_URL + "getExpenseUsers"
    let GET_EXPENSES                                = BASE_URL + "getExpenses"
    let UPDATE_EXPENSE_STATUS                       = BASE_URL + "updateExpenseStatus"
    let GET_EXPENSE_DETAILS                         = BASE_URL + "getExpenseDetail"
    let CHECK_EXPENSES_DATE                         = BASE_URL + "checkExpenseDate"
    let ADD_EXPENSES                                = BASE_URL + "addExpense"
    let GET_EXPENSE_CATEGORY                        = BASE_URL + "getExpenseCategory"
    let GET_TRAVEL_MODE                             = BASE_URL + "getTravelModes"
    let UPLOAD_EXPENSE_ATTACHMENT                   = BASE_URL + "uploadExpenseAttachment"
    let REMOVE_EXPENSE_ATTACHMENT                   = BASE_URL + "removeExpenseAttachment"
    let CLUB_EXPENSE                                = BASE_URL + "clubExpense"
    
    // Notification
    let GET_NOTIFICATION_LIST                       = BASE_URL + "getNotificationList"
    let CLEAR_ALL_NOTIFICATION                      = BASE_URL + "clearAllNotification"
    
    // Support
    let SEND_SUPPORT_QUERY                          = BASE_URL + "sendSupportQuery"
    
    // Settings
    let CHANGE_PASSWORD                             = BASE_URL + "changePassword"
    let GET_CATEGORY_LIST                           = BASE_URL + "categoryList"
    
    
    
    
    // MARK: -  GET | POST | PUT | DELETE Data
    func getData<T: Decodable>(url: String, parameters: Dictionary<String, Any>?, completion:@escaping (T?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.callData(URL: url, PARAMS: parameters, METHOD_TYPE: "GET", COMPLETION: completion)
        }
    }
    
    func postData<T: Decodable>(url: String, parameters: Dictionary<String, Any>?, completion:@escaping (T?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.callData(URL: url, PARAMS: parameters, METHOD_TYPE: "POST", COMPLETION: completion)
        }
    }
    
    func supportPostData<T: Decodable>(url: String, parameters: Dictionary<String, Any>?, image: UIImage?, completion:@escaping (T?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.supportCallData(URL: url, PARAMS: parameters, METHOD_TYPE: "POST", image: image, COMPLETION: completion)
        }
    }
    
    func putData<T: Decodable>(url: String, parameters: Dictionary<String, Any>, methodType: String, completion:@escaping (T?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.callData(URL: url, PARAMS: parameters, METHOD_TYPE: "PUT", COMPLETION: completion)
        }
    }
    
    func deleteData<T: Decodable>(url: String, parameters: Dictionary<String, Any>, methodType: String, completion:@escaping (T?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.callData(URL: url, PARAMS: parameters, METHOD_TYPE: "DELETE", COMPLETION: completion)
        }
    }
    
    fileprivate func callData<T: Decodable>(URL url: String, PARAMS parameters: Dictionary<String, Any>?, METHOD_TYPE methodType: String, COMPLETION completion: @escaping (T?, Error?) -> ()) {
        let url1 = URL(string: url)
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        
        var request = URLRequest(url: url1!)
        request.httpMethod = methodType
        request.timeoutInterval = 60
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        //request.addValue(authToken, forHTTPHeaderField: "Authentication")
        print("Bearer " + authToken)
        
        request.cachePolicy = .reloadIgnoringCacheData
        
        let params = parameters
        if methodType != "GET" {
            if params != nil {
                let theJSONData = try? JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                let JsonString = String.init(data: theJSONData!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                print("json : \(JsonString!)")
                request.httpBody = JsonString!.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion:true)
            }
        }
        
        print(URLRequest(url: url1!))
        let task = session.dataTask(with: request, completionHandler:{
            (data, response, error) in
            if error == nil {
                guard let data = data else { return }
                do {
                    let jsonDecoder = JSONDecoder()
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                                                   data, options: [])
                    print("1 -> \(jsonResponse)")
                    let dataReceived = try jsonDecoder.decode(T.self, from: data)
                    completion(dataReceived,error)
                } catch let jsonErr {
                    print(jsonErr)
                    completion( nil,jsonErr)
                }
            } else {
                completion( nil,error)
            }
        })
        task.resume()
    }
    
    fileprivate func supportCallData<T: Decodable>(URL url: String, PARAMS parameters: Dictionary<String, Any>?, METHOD_TYPE methodType: String, image: UIImage?, COMPLETION completion: @escaping (T?, Error?) -> ()) {
        let url1 = URL(string: url)
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        let boundary = UUID().uuidString
        
        var request = URLRequest(url: url1!)
        request.httpMethod = methodType
        request.timeoutInterval = 60
        
        request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        //request.addValue(authToken, forHTTPHeaderField: "Authentication")
        
        print("Bearer " + authToken)
        
        if image != nil {
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let body = createMultipartBody(parameters: parameters, image: image, boundary: boundary)
            request.httpBody = body
        }
        else {
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
            let params = parameters
            if methodType != "GET" {
                if params != nil {
                    let theJSONData = try? JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                    let JsonString = String.init(data: theJSONData!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                    
                    print("json : \(JsonString!)")
                    request.httpBody = JsonString!.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion:true)
                }
            }
        }
        
        request.cachePolicy = .reloadIgnoringCacheData
        
        print(URLRequest(url: url1!))
        
        /*let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            guard let data = data else { return }
            do {
                let jsonDecoder = JSONDecoder()
                let dataReceived = try jsonDecoder.decode(T.self, from: data)
                completion(dataReceived, nil)
            } catch let jsonErr {
                print(jsonErr)
                completion(nil, jsonErr)
            }
        }
        task.resume()   /// */
        
        let task = session.dataTask(with: request, completionHandler:{
            (data, response, error) in
            if error == nil {
                guard let data = data else { return }
                do {
                    let jsonDecoder = JSONDecoder()
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                                                   data, options: [])
                    print(jsonResponse)
                    let dataReceived = try jsonDecoder.decode(T.self, from: data)
                    completion(dataReceived,error)
                } catch let jsonErr {
                    print(jsonErr)
                    completion( nil,jsonErr)
                }
            } else {
                completion( nil,error)
            }
        })
        task.resume()
    }
    
    
    typealias completionBlock = (Bool, Dictionary<String, Any>?, String?) -> Void
    
    func getYoutubeData(url: String, parameters: Dictionary<String, Any>?, completion:@escaping completionBlock)
    {
        DispatchQueue.global(qos: .background).async {
            self.callDataYoutube(URL: url, PARAMS: parameters, METHOD_TYPE: "GET", COMPLETION: completion)
        }
    }
    
    fileprivate func callDataYoutube(URL url: String, PARAMS parameters: Dictionary<String, Any>?, METHOD_TYPE methodType: String, COMPLETION completion: @escaping completionBlock)
    {
        let url1 = URL(string: url)
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        
        var request = URLRequest(url: url1!)
        request.httpMethod = methodType
        request.timeoutInterval = 60
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringCacheData
        
        let task = session.dataTask(with: request, completionHandler:{
            (data, response, error) in
            if error == nil {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    let dictResponse = jsonDict as! Dictionary<String, Any>
                    completion(true, dictResponse, "")
                } catch {
                    print("Something went wrong")
                    completion(false, nil, error.localizedDescription)
                }
            } else {
                completion(false, nil, error?.localizedDescription)
            }
        })
        task.resume()
    }
    
    func uploadImage(url: String,
                     dictiParam: [String: Any],
                     image: Any,
                     type: String,
                     contentType: String,
                     imageKey: String = "attachment",
                     COMPLETION completion: @escaping ((Bool, String) -> Void),
                     errorCompletion: @escaping ((Bool, String) -> Void))
    {
        
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        //urlRequest.setValue(authToken, forHTTPHeaderField: "Authentication")
        
        var data = Data()
        for (key, value) in dictiParam
        {
            if key == "image"
            {
                if type == "image"
                {
                    let img: UIImage = image as! UIImage
                    data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                    //data.append("Content-Disposition: form-data; name=\"\("selectFile")\"; filename=\"\(value as! String)\"\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"\(value as! String)\"\r\n".data(using: .utf8)!)
                    data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
                    data.append(img.pngData()!)
                }
            }
            else
            {
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)".data(using: .utf8)!)
            }
        }
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        print(data)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            DispatchQueue.main.async
            {
                if (error != nil)
                {
                    print("Get error whiile send data -> \(error?.localizedDescription)")
                    return
                }
                
                do {
                    let dictData = try JSONSerialization.jsonObject(with: responseData!, options: .allowFragments) as? NSDictionary
                    let status = dictData!["status"] as! Int
                    
                    if status == 1
                    {
                        //print(dictData)
                        completion(true, dictData!["message"] as! String)
                    }
                    else
                    {
                        let errors = dictData!["message"] as? [[String: Any]]
                        errorCompletion(false, dictData!["message"] as! String)
                    }
                }
                catch
                {
                    errorCompletion(false, "")
                }
            }
        }).resume()
    }
    
    /*func uploadImage(url: String, fileName: String, image: UIImage,type: String, id: Int,COMPLETION completion: @escaping completionBlock) {
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //urlRequest.setValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        urlRequest.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("type")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(type)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("moduleId")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(id)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("image")\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    if (error != nil) {
                        return
                    }
                    do {
                        let dictData = try JSONSerialization.jsonObject(with: responseData!, options: .allowFragments) as? NSDictionary
                        let status = dictData!["status"] as! Int
                        let message = dictData!["message"] as! String
                        if status == 1 {
                            let dic = dictData!["result"] as? [String: Any]
                            completion(true, dic, "")
                        }else {
                            completion(false, nil, message)
                        }
                    }catch {
                        completion(false, nil, error.localizedDescription)
                    }
                }
            }
        }).resume()
    }   //  */
    
    func uploadOCRImage(url: String, fileName: String, image: UIImage,score: Int,teamId: Int, matchId: Int,roundId: Int,COMPLETION completion: @escaping completionBlock) {
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //urlRequest.setValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        urlRequest.setValue(authToken, forHTTPHeaderField: "Authorization")
        
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("teamId")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(teamId)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("matchId")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(matchId)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("score")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(score)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("roundId")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(roundId)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("scoreImage")\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    if (error != nil) {
                        return
                    }
                    do {
                        let dictData = try JSONSerialization.jsonObject(with: responseData!, options: .allowFragments) as? NSDictionary
                        let status = dictData!["status"] as! Int
                        let message = dictData!["message"] as! String
                        if status == 1 {
                            let dic = dictData!["result"] as? [String: Any]
                            completion(true, dic, "")
                        }else {
                            completion(false, nil, message)
                        }
                    }catch {
                        completion(false, nil, error.localizedDescription)
                    }
                }
            }
        }).resume()
    }
    
    
    
    /// For Upload image in form data
    
    func createMultipartBody(parameters: [String: Any]?, image: UIImage?, boundary: String) -> Data {
        var body = Data()

        if let parameters = parameters {
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }

        if let image = image {
            let imageData = image.jpegData(compressionQuality: 0.7)!
            let filename = "attachment.jpg"
            let mimetype = "image/jpeg"

            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"attachment\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        return body
    }

}

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
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
