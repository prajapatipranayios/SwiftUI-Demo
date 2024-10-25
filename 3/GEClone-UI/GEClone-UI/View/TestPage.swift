//
//  TestPage.swift
//  GEClone-UI
//
//  Created by Auxano on 22/10/24.
//

import Foundation
import UIKit

let HTTP_URL = "http://gfw.salesapp.testnftapp.com/"
let BASE_URL = HTTP_URL + "api/"

class APIManager {
    
    static let shared = APIManager()
    private init() {}
    
    var authToken: String = ""
    var userId: Int = 0
    var isSideMenuLoad: Bool = false
    var isRefreshData: Bool = false
    var companyType: Int? = 1
    var isCommissionActive: Bool = false
    
    
    // User Authentication
    let LOGIN = BASE_URL + "login"
    
    
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
