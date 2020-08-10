//
//  TransactionHistory.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import Foundation

struct TransactionHistory: Identifiable {
    let id: UUID
    var currency: String
    var value: Decimal
    var charge: Decimal?
}
