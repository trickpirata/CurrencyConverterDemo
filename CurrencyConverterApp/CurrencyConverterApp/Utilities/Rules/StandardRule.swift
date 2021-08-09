//
//  StandardRule.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/9/21.
//  Copyright © 2021 Trick Gorospe. All rights reserved.
//

import Foundation

class StandardRule: Rule {
    var commissionFee: Double {
        return 0.007
    }
    
    var maxTries: Int {
        return 5
    }
    
    func computeCommissionFee(forAmount amount: Double,numberOfTries tries: Int) -> Double {
        let noCommission = tries < maxTries
        return noCommission ? 0 : amount * commissionFee
    }
}
