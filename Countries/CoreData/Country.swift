//
//  Country.swift
//  Countries
//
//  Created by Syft on 04/03/2020.
//  Copyright © 2020 Syft. All rights reserved.
//

import Foundation
import CoreData
import ObjectMapper


@objc(Country)
class Country: NSManagedObject, Mappable {
        
    private override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    required init?(map: Map) {
        
        guard map.JSON["name"] != nil,
            map.JSON["capital"] != nil,
            map.JSON["population"] != nil else {
                assertionFailure("Failed to create Country")
                return nil
        }
        
        super.init(entity: Self.entity(), insertInto: nil)
    }
    
    func mapping(map: Map) {
        
        DispatchQueue.main.async {
            self.name <- map["name"]
            self.capital <- map["capital"]
            self.population <- map["population"]
        }
    }
    
}
