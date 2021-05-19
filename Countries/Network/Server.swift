//
//  Server.swift
//  CodeTest
//
//  Created by Syft on 03/03/2020.
//  Copyright © 2020 Syft. All rights reserved.
//

import Alamofire
import ObjectMapper
import AlamofireObjectMapper
import Foundation
import CoreData


// Create an account at https://rapidapi.com/developer/dashboard and add a new app to get an API key.
// https://docs.rapidapi.com/docs/keys

let kRapidAPIKey = "SIGN-UP-FOR-KEY"


public typealias JSON = [String : Any]

public extension Notification.Name {
    static let ServerReachabilityDidChange  = Notification.Name("ServerReachabilityDidChange")
}


class Server {

    public static let shared = Server()
    
    var host: String
    private let path: String
    private let networkReachabilityManager: NetworkReachabilityManager?
    
    
    lazy var session: Session = {
        return Session.default
    }()
    
    
    
    init(host: String, path: String) {
                
        self.host = host
        self.path = path
        
        networkReachabilityManager = NetworkReachabilityManager(host: host)
        networkReachabilityManager?.startListening(onUpdatePerforming: { (status) in
            NotificationCenter.default.post(name: .ServerReachabilityDidChange, object: nil)
        })
    }
    
    private convenience init() {
        self.init(host: "restcountries-v1.p.rapidapi.com", path: "/")
    }

    
    /// Create URL to call given call path
    ///
    /// - Parameters:
    ///     - path: *path* to call
    ///
    /// - returns: URL
    public func url( for path: String ) -> String {
        return "https://\(host)\(self.path)\(path)"
    }
    
    
    /// Create list of headers to send to server
    ///
    /// - returns: list of headers
    public func headers( extraHeaders: [String: String]? = nil ) -> [String: String] {
        
        var headers: [String: String] = [
            "X-RapidAPI-Host": "restcountries-v1.p.rapidapi.com",
            "X-RapidAPI-Key": kRapidAPIKey
        ]
        
        if let extraHeaders = extraHeaders {
            headers += extraHeaders
        }
        
        return headers
    }
    
    
    /// Perform request to server.
    ///
    /// - Parameters:
    ///     - path:               *path* for the operation.
    ///     - parameters:         The *parameters* to be send to server as JSON.
    ///     - statusCode:         The list of valid *status codes*
    ///     - completionHandler:  A *closure* to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    func request<T: Mappable>( _ method: HTTPMethod,
                  path: String,
                  object: T.Type,
                  parameters: [String : Any]? = nil,
                  completionHandler: @escaping ( _ response: [Mappable]?, _ error: Error? ) -> Void ) -> DataRequest {
        
        return request(method,
                       path: path,
                       object: object,
                       parameters: parameters,
                       completionHandler: { (response: Any?, error: Error?) in
            completionHandler( response as? [Mappable], error )
        })
    }
    
    
    /// Perform request to server.
    ///
    /// - Parameters:
    ///     - path:               *path* for the operation.
    ///     - parameters:         The *parameters* to be send to server as JSON.
    ///     - statusCode:         The list of valid *status codes*
    ///     - completionHandler:  A *closure* to be executed once the request has finished.
    ///
    /// - returns: The request.
    @discardableResult
    func request<T: Mappable>( _ method: HTTPMethod,
                  path: String,
                  object: T.Type,
                  parameters: [String : Any]? = nil,
                  extraHeaders: [String : String]? = nil,
                  completionHandler: @escaping ( _ response: Any?, _ error: Error? ) -> Void ) -> DataRequest {
        
        assert(parameters == nil || JSONSerialization.isValidJSONObject(parameters!), "parameters must be valid JSON")

        #if DEBUG
        print("### \(method.rawValue): \(host)\(self.path)\(path)")
        #endif
        
        return session.request(url(for: path),
                               method: method,
                               parameters: parameters,
                               encoding: method == .get ? URLEncoding() : JSONEncoding(),
                               headers: HTTPHeaders(self.headers(extraHeaders: extraHeaders)))
            .validate(statusCode: method == .post ? [200, 201] : [200])
            .responseArray { (response: DataResponse<[T], AFError>) in
                
                switch response.result {
                case .success(let value):
                    
                    value.forEach {DataStore.shared.viewContext.insert($0 as! NSManagedObject)}
                    
                    do {
                        try DataStore.shared.viewContext.save()
                    } catch {
                        assertionFailure("There was an error: \(error)")
                    }
                    
                    completionHandler(value, nil)
                    
                case .failure(let error):
                    completionHandler(nil, error)
                }
        }
    }
    
}

