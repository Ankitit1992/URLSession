//
//  NetworkManager.swift
//  UrlSessionDemo
//
//  Created by Ankit Tiwari on 12/6/18.
//  Copyright © 2018 Ankit Tiwari. All rights reserved.
//

import UIKit

enum  HTTPMethod:String {
    case Post   = "post"
    case Get    = "get"
    case Delete = "delete"
    case Put    = "put"
}


let BASE_URL = ""

class NetworkManager: NSObject {
  
    static let shared = NetworkManager()
    private override init() {
        super.init()
    }
    
    func urlRequesttoServer(with url:String,param:[String:Any], method:HTTPMethod, completionHandler:@escaping(Any,URLResponse) -> Void) {
        
        let baseURL = "http://64.150.183.17:1004/calonex/api/users/login"
       
        guard let urlStr = URL(string: baseURL) else {return}
         
       //Serialized data in data form for request body
        let serData = getSerilizedData(dic: param)
       
        var urlRequest = URLRequest(url: urlStr)
       
        // Setting header for server request with content type
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
       
        // Setting default session configuration
        let session = URLSession.shared
        
        switch method {
            case .Post:
               
                urlRequest.httpMethod = HTTPMethod.Post.rawValue
                session.uploadTask(with: urlRequest, from: serData) { (data, response, error) in
                    if let err = error {
                       debugPrint(err.localizedDescription)
                    }
                    if let ndata = data {
                      let jsonString = self.jsonDeserilizedData(from: ndata)
                      completionHandler(jsonString,response!)
                    }

                }.resume()
            
            case .Get:
                 urlRequest.httpMethod = HTTPMethod.Get.rawValue
                 
                 session.dataTask(with: urlRequest) { (data, response, error) in
                    if let err = error {
                        debugPrint(err.localizedDescription)
                    }
                    
                    if let ndata = data {
                        let jsonString = self.jsonDeserilizedData(from: ndata)
                        completionHandler(jsonString,response!)
                    }
                    
                    }.resume()

            case .Delete:
                urlRequest.httpMethod = HTTPMethod.Delete.rawValue
                
                session.dataTask(with: urlRequest) { (data, response, error) in
                    
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    
                    if let ndata = data {
                      let jsonString = self.jsonDeserilizedData(from: ndata)
                        completionHandler(jsonString,response!)
                    }
                    
                    }.resume()
            
            case .Put:
                urlRequest.httpMethod = HTTPMethod.Put.rawValue
                session.uploadTask(with: urlRequest, from: serData) { (data, response, error) in
                   
                    if let err = error {
                       print(err.localizedDescription)
                    }
                    
                    if let ndata = data {
                        let jsonString = self.jsonDeserilizedData(from: ndata)
                      completionHandler(jsonString,response!)
                    }

                }.resume()
        }
    }
    
    func urlMultiPartRequest(url:String, param:[String:Any], imageParam:[[String:Any]],method:HTTPMethod, completionHandler:@escaping(Any, URLResponse) -> Void) {
       
        guard let url =   URL(string: "https://prospero.uatproxy.cdlis.co.uk/prospero/DocumentUpload.ajax") else {return}
        var urlRequest  = URLRequest(url:url)
       
        /*To recognize chucks data which we sending in multiple part**/
        let boundary = "Boundary-\(UUID().uuidString)"
        
        /* set header with content type and boundary*/
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
       
        let session = URLSession.shared
        
        var dataTask: URLSessionDataTask?
        
        
        urlRequest.httpBody = createBody(parameters: param, boundary: boundary, mimeType: "image/jpeg", imageParam: imageParam)
        switch method {
            case .Post:
            urlRequest.httpMethod = HTTPMethod.Post.rawValue
                    dataTask =  session.dataTask(with: urlRequest) { (data, response, error) in
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    
                    if let ndata = data {
                        let jsonString = self.jsonDeserilizedData(from: ndata)
                        completionHandler(jsonString,response!)
                    }
                    }
                   dataTask?.resume()
            case .Put:
                urlRequest.httpMethod = HTTPMethod.Put.rawValue
                session.dataTask(with: urlRequest) { (data, response, error) in
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    
                    if let ndata = data {
                        let jsonString = self.jsonDeserilizedData(from: ndata)
                        completionHandler(jsonString,response!)
                    }
                    }.resume()
            default:
                break
        }
      
    }
    
    func createBody(parameters: [String: Any],
                    boundary: String,
                    mimeType: String,
                    imageParam: [[String:Any]]) -> Data {
        let body = NSMutableData()
        
        let boundaryPrefix = "--\(boundary)\r\n"
        
        for (key, value) in parameters {
            body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        for param in imageParam {
         
                let data = UIImage.jpegData(param["image"] as! UIImage)
                body.appendString(boundaryPrefix)
            body.appendString("Content-Disposition: form-data; name=\"file\"; filename=\"\(param["imageName"] ?? "").png\"\r\n")
                body.appendString("Content-Type: \(mimeType)\r\n\r\n")
                body.append(data(0.7)!)
                body.appendString("\r\n")
                body.appendString("--".appending(boundary.appending("--")))
       
        }
  
        return body as Data
    }
    
    private func jsonDeserilizedData(from data:Data) -> Any {
        do {
            let jsonString = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            return jsonString
        }catch {
           print("")
        }
        return ""
    }
    
    private func getSerilizedData(dic :[String:Any]) -> Data {
        do {
           let data =  try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
            return data
        } catch {
            print("Not string")
        }
        
        return Data()
    }
    
    
    func getDictionary(from data:Any) -> [String:Any] {
        let dic :[String:Any] = data as? [String:Any] ?? [:]
        return dic
    }
    
    func getArrayOfDic(from data:Any) -> [[String:Any]] {
        let dic :[[String:Any]] = data as? [[String:Any]] ?? [[:]]
        return dic
    }
}


extension NSMutableData {
    func appendString(_ string: Any) {
        if let str = string as? String {
            let data = str.data(using: String.Encoding.utf8, allowLossyConversion: false)
            append(data!)
        } else {
            do {
            let jsonData = try JSONSerialization.data(withJSONObject: string, options: .prettyPrinted)
                append(jsonData)
            } catch {
                print ("string isn't find")
            }
        }
    }
}
