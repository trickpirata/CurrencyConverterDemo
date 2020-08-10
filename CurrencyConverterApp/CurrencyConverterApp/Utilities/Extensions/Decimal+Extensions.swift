//
//  Decimal+Extensions.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import Foundation
extension Decimal {
    var doubleValue:Double {
        return NSDecimalNumber(decimal:self).doubleValue
    }
}
