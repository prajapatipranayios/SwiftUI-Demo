//
//  APIManager.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 25/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import Foundation
import UIKit

//let HTTP_URL = "http://14.99.147.155:9898/food-flocker-qa/"
//let BASE_URL = HTTP_URL + "public/api/v1/"

let HTTP_URL = "https://foodflocker.com.au/"
let BASE_URL = HTTP_URL + "api/v1/"

//let BASE_URL = HTTP_URL + "public/api/v1/"
let BASE_IMG_URL = HTTP_URL + "images/FoodBackground/"

class APIManager {
    
    private init() {
        
    }
    
    static let sharedManager = APIManager()
    
    var authToken: String = ""
    var notificationCount: Int = 0
    var user: User? {
        willSet {
            
        }
    }
    
    var registerLeagueUrl: String = ""
    var activeLeagueUrl: String = ""
    var pastLeagueUrl: String = ""
    var guideLine: Int = 0
    
    // User Authentication
    let CHECK_EMAIL_MOBILE                  = BASE_URL + "checkEmailMobileNumber"
    let LOGIN                               = BASE_URL + "login"
    let SOCIAL_LOGIN                        = BASE_URL + "socialLogin"
    let GET_USER_DETAIL                     = BASE_URL + "getUserDetail"
    let SIGNUP                              = BASE_URL + "signUp"
    let FORGOT_PASSWORD                     = BASE_URL + "forgotPassword"
    let VERIFY_OTP                          = BASE_URL + "verifyOTP"
    let RESEND_OTP                          = BASE_URL + "resendOTP"
    let RESEND_OTP_MOBILE                   = BASE_URL + "resendOTPToMobile"
    let RESET_PASSWORD                      = BASE_URL + "resetPassword"
    let LOGOUT                              = BASE_URL + "logout"
    
    let GET_NOTIFICATIONS                   = BASE_URL + "getNotificationList"
    let GET_USER_REQUESTS                   = BASE_URL + "getUsersRequestList"
    
    // Upload Media
    let UPLOAD_MEDIA                        = BASE_URL + "uploadImage"

    let ADD_EVENT                           = BASE_URL + "addEvent"
    let UPDATE_EVENT                        = BASE_URL + "updateEvent"
    let ADD_POST                            = BASE_URL + "addPost"
    let ACCEPT_REJECT_USER_REQUEST          = BASE_URL + "acceptRejectUserRequest"
    let UPDATE_POST                         = BASE_URL + "updatePost"

    //Home screen
    let GET_NEAR_BY_POST_EVENTS             = BASE_URL + "getNearByPostEvents"
    let GET_POST_EVENT_DETAILS              = BASE_URL + "getPostEventDetails"
    let FOLLOW_UNFOLLOW_USER                = BASE_URL + "followUnfollowUser"
    let REMOVE_USER                         = BASE_URL + "removeFollower"
    let LIKE_POST_EVENT                     = BASE_URL + "likeUnlikePostEvent"
    let SEND_REQUEST_FOR_POST               = BASE_URL + "sendRequestForPost"

    let REPORT_POST                         = BASE_URL + "sendReport"
    let GET_LIKE_USERS_LIST                 = BASE_URL + "getLikeUserList"

    let SAVE_UNSAVE_EVENT                   = BASE_URL + "saveUnsaveEvent"
    let CHANGE_USER_EVENT_STATUS            = BASE_URL + "changeUserEventStatus"
    let GET_INTERESTED_MAYBE_USER           = BASE_URL + "getIntrestedAndMaybeUser"

    let SEND_QUESTIONS                      = BASE_URL + "sendQuestions"
    let GIVE_REPLY                          = BASE_URL + "giveReply"
    let GET_FORUM_QUESTION_LIST             = BASE_URL + "getForumQuestionList"
    let CONFIRM_EVENT_TICKETS               = BASE_URL + "confirmEventTicket"
    let CANCEL_EVENT_TICKETS                = BASE_URL + "cancelEventTicket"

    let GET_FOLLOW_UNFOLLOW_USERS           = BASE_URL + "getFollowUnfollowUserList"

    let GET_ALL_EVENTS                      = BASE_URL + "getAllEventsList"
    
    let GET_ALL_USER_POST                   = BASE_URL + "getAllUserPost"

    let GET_ALL_USER_Event                   = BASE_URL + "getAllUserEvent"
    
    let GET_ALL_USER_MEDIA                  = BASE_URL + "getUsersAllMedia"
    let DELETE_MEDIA_POST                   = BASE_URL + "deleteMediaPost"
    let GET_USERS_REVIEW                    = BASE_URL + "getUsersReview"
    let GET_OTHER_USER_DETAILS              = BASE_URL + "getAnotherUserDetails"
    
    let SET_REMINDER                        = BASE_URL + "setReminder"
    let DELETE_POST_EVENT                   = BASE_URL + "deletePostEvent"
    
    let GET_CONVERSATIONS                   = BASE_URL + "getConversations"
    let GET_CHAT_MESSAGES                   = BASE_URL + "getChats"
    let SEND_MESSAGE                        = BASE_URL + "sendMessage"
    let DELETE_CONVERSATION                 = BASE_URL + "deleteConversations"

    let GET_POST_REQUESTS                   = BASE_URL + "getSentReceivePostRequest"
    let ACCEPT_REJECT_POST                  = BASE_URL + "acceptRejectPost"
    let GIVE_RATE_REVIEW                    = BASE_URL + "giveRateAndReview"

    let GET_FOLLOWER_POST                   = BASE_URL + "getFollowerPost"
     
    let ADD_MEDIA_POST                      = BASE_URL + "addMediaPost"
    let SEARCH_FOOD_FLOCKER                 = BASE_URL + "searchFoodFlocker"
    let GET_SEARCH_POST_EVENT               = BASE_URL + "getSearchPostEvent"

    let GET_POST_HISTORY                    = BASE_URL + "getPostHistory"
    let GET_CARDS                           = BASE_URL + "getCards"
    let ADD_CARD                            = BASE_URL + "addCard"
    let REMOVE_CARD                         = BASE_URL + "removeCard"
    let SET_DEFAULT_CARD                    = BASE_URL + "setDefaultCard"
    
    let EDIT_PROFILE                        = BASE_URL + "editProfile"
    let UPLOAD_PROFILE                      = BASE_URL + "uploadProfile"
    let GET_TERMS_POLICY                    = BASE_URL + "getTermAndPolicy"
    let GET_ABOUT_US                        = BASE_URL + "getAboutUs"
    let CHANGE_PASSWORD                     = BASE_URL + "changePassword"
    let GET_FAQs                            = BASE_URL + "getFAQs"
    let USER_LOGOUT                         = BASE_URL + "logout"

    let GET_BANK_DETAIL                     = BASE_URL + "getBankDetail"
    let ADD_BANK_DETAIL                     = BASE_URL + "addBankDetail"
    let UPDATE_BANK_DETAIL                  = BASE_URL + "updateBankDetail"
    let TRANSACTION                         = BASE_URL + "transaction"

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
        
        let task = session.dataTask(with: request, completionHandler:{
            (data, response, error) in
            if error == nil {
                guard let data = data else { return }
                do {
                    let jsonDecoder = JSONDecoder()
                    let dataReceived = try jsonDecoder.decode(T.self, from: data)
                    completion(dataReceived, error)
                } catch let jsonErr {
                    completion(nil, jsonErr)
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
    
    //type: String, id: Int
    func uploadImageOrVideo(url: String, fileName: String, image: UIImage?, movieDataURL: URL?, params: Dictionary<String, Any>?, COMPLETION completion: @escaping completionBlock) {
        
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        var data = Data()
        
        if params != nil {
            for (key, value) in params! {
                print("Key: \(key)")
                data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"\("\(key)")\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(value)".data(using: .utf8)!)
            }
        }
                
        let mimetype = image != nil ? "image/\(image!.pngData()?.format ?? "png")" : "video/mov"
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\(fileName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
        if image != nil {
            data.append(image!.pngData()!)
        } else {
            do {
                data.append(try Data(contentsOf: movieDataURL!))
            } catch {
                print(error.localizedDescription)
            }
        }
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
                            completion(true, dic, message)
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
}
