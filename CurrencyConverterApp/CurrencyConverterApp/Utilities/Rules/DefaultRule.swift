//
//  DefaultRule.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import Foundation

class DefaultRule {
    private struct Constant {
        static let charge = 0.007
        static let maxFreeTransaction = 5
    }

    var transactionAmount: Double { return commissionFee + amount }
    var commissionFee: Double
    let amount: Double
    
    init(amount: Double,amountOfTries: Int) {
        self.amount = amount
        
        let valid = amountOfTries < Constant.maxFreeTransaction
        commissionFee = valid ? 0 : amount * Constant.charge
    }
}
