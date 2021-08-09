//
//  Double+Extensions.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/9/21.
//  Copyright © 2021 Trick Gorospe. All rights reserved.
//

import Foundation

extension Double {
    func roundToTwoDecimal() -> String {
        return String.init(format: "%.2f", self)
    }
}
