//
//  AccountBalance.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/9/21.
//  Copyright © 2021 Trick Gorospe. All rights reserved.
//

import Foundation

struct AccountBalance: Equatable {
    let id = UUID()
    var balance: Decimal
    var currency: String
    
    static func == (lhs: AccountBalance, rhs: AccountBalance) -> Bool {
        if (lhs.id ==  rhs.id) { return true }
        return false
    }
}
