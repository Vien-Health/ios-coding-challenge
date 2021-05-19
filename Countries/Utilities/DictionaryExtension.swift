//
//  DictionaryExtension.swift
//  Countries
//
//  Created by Syft on 03/03/2020.
//  Copyright © 2020 Syft. All rights reserved.
//

import Foundation

public func += <K, V> ( left: inout [K: V], right: [K: V]) {
    for (k, v) in right {
        left.updateValue(v, forKey: k)
    }
}
