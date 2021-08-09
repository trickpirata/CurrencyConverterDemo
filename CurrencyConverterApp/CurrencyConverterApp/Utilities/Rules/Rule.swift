//
//  Rule.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/9/21.
//  Copyright © 2021 Trick Gorospe. All rights reserved.
//

import Foundation

protocol Rule {
    var commissionFee: Double { get }
    var maxTries: Int { get }
    func computeCommissionFee(forAmount amount: Double,numberOfTries tries: Int) -> Double
}
