//
//  APIManager-1.swift
//
//  Created by Pranay on 22/10/24.
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
    func getData<T: Decodable>(url: String, parameters: [String: Any]?, completion: @escaping (T?, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.callData(url: url, parameters: parameters, methodType: "GET", completion: completion)
        }
    }
    
    func postData<T: Decodable>(url: String, parameters: [String: Any]?, completion: @escaping (T?, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.callData(url: url, parameters: parameters, methodType: "POST", completion: completion)
        }
    }
    
    func putData<T: Decodable>(url: String, parameters: [String: Any], completion: @escaping (T?, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.callData(url: url, parameters: parameters, methodType: "PUT", completion: completion)
        }
    }
    
    func deleteData<T: Decodable>(url: String, parameters: [String: Any], completion: @escaping (T?, Error?) -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.callData(url: url, parameters: parameters, methodType: "DELETE", completion: completion)
        }
    }
    
    fileprivate func callData<T: Decodable>(url: String, parameters: [String: Any]?, methodType: String, completion: @escaping (T?, Error?) -> Void) {
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = methodType
        request.timeoutInterval = 60
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        if methodType != "GET", let parameters = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else { return }
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(decodedData, nil)
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
    // MARK: - Upload Image in Multipart Form-Data
    func uploadImage(url: String, parameters: [String: Any], image: UIImage, imageKey: String = "attachment", completion: @escaping (Bool, String) -> Void) {
        let boundary = UUID().uuidString
        guard let url = URL(string: url) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        
        let body = createMultipartBody(parameters: parameters, image: image, boundary: boundary, imageKey: imageKey)
        
        URLSession.shared.uploadTask(with: request, from: body) { data, response, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                completion(false, "Invalid response data")
                return
            }
            
            if let status = json["status"] as? Int, status == 1 {
                completion(true, json["message"] as? String ?? "Success")
            } else {
                completion(false, json["message"] as? String ?? "Upload failed")
            }
        }.resume()
    }
    
    /*func uploadImage(url: String,
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
    }   //  */
    
    // Helper function to create multipart body
    private func createMultipartBody(parameters: [String: Any], image: UIImage, boundary: String, imageKey: String) -> Data {
        var body = Data()
        
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.append("\(value)\r\n")
        }
        
        let imageData = image.jpegData(compressionQuality: 0.7) ?? Data()
        body.append("--\(boundary)\r\n")
        body.append("Content-Disposition: form-data; name=\"\(imageKey)\"; filename=\"image.jpg\"\r\n")
        body.append("Content-Type: image/jpeg\r\n\r\n")
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n")
        
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
