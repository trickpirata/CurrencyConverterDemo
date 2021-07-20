//
//  Errors.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 7/20/21.
//  Copyright © 2021 Trick Gorospe. All rights reserved.
//

import Foundation

enum TransactionValidationError: Error {
    case cannotBeZero
    case inputLower
    case incompleteDetails
    case cannotConvert
    case invalid
    case unknown
}
