//
//  ServerError.swift
//  Countries
//
//  Created by Syft on 03/03/2020.
//  Copyright © 2020 Syft. All rights reserved.
//

import Foundation


public enum ServerError: Error {
    case invalidAccessTokenError(errorDescription: String)
    case versionOutdated(errorDescription: String)
    case bannedError(errorDescription: String)
    case invalidFieldsError(errorDescription: String, fields: [JSON]?, nested: [JSON]?)
    case requestError(errorDescription: String, errorCode: String?, underlyingErrors: [Error]?)
    
    func errors( in errorList: [JSON] ) -> String? {
        var errorsString = ""
        
        for error in errorList {
            let property = error["property"] as? String
            if let items = error["items"] as? [JSON] {
                for item in items {
                    if let fields = item["fields"] as? [JSON] {
                        for field in fields {
                            if let property = property {
                                errorsString += "\n.\(property).\(field["field"]!) - \(field["message"]!)"
                            } else {
                                errorsString += "\n.\(field["field"]!) - \(field["message"]!)"
                            }
                        }
                    }
                    
                    if let nested = item["nested"] as? [JSON], let nestedErrors = errors( in: nested ) {
                        errorsString += nestedErrors
                    }
                }
            }
        }
        
        return errorsString.isEmpty ? nil : errorsString
    }

    func fields( in errorList: [JSON] ) -> [String : String]? {
        var errorsFields = [String : String]()
        
        for error in errorList {
            let property = error["property"] as? String
            if let items = error["items"] as? [JSON] {
                for item in items {
                    if let fields = item["fields"] as? [JSON] {
                        for field in fields {
                            if let property = property {
                                errorsFields[".\(property).\(field["field"]!)"] = field["message"] as! String?
                            } else {
                                errorsFields[".\(field["field"]!)"] = field["message"] as! String?
                            }
                        }
                    }
                    
                    if let nested = item["nested"] as? [JSON], let nestedFields = fields( in: nested ) {
                        errorsFields += nestedFields
                    }
                }
            }
        }
        
        return errorsFields.isEmpty ? nil : errorsFields
    }
    
}


extension ServerError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .invalidAccessTokenError(let errorDescription):
            return errorDescription
        case .versionOutdated(let errorDescription):
            return errorDescription
        case .bannedError(let errorDescription):
            return errorDescription
        case .invalidFieldsError(let errorDescription, let fields, let nested):
            var errorDescription = errorDescription
            
            if let fields = fields, let errors = errors( in: [["items": [["fields": fields]]]] )  {
                errorDescription += "\n" + errors
            }
            
            if let nested = nested, let errors = errors( in: nested ) {
                errorDescription += "\n" + errors
            }
            
            return errorDescription
        case .requestError(let errorDescription, _, _):
            return errorDescription
        }
    }

}
