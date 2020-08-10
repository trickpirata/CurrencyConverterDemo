//
//  Color+Extensions.swift
//  CurrencyConverterUI
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import SwiftUI

extension Color {
    static func randomPastelColor() -> Color {
        let randomColorGenerator = { ()-> CGFloat in
            CGFloat(arc4random() % 256 ) / 256
        }
        
        let red: CGFloat = randomColorGenerator()
        let green: CGFloat = randomColorGenerator()
        let blue: CGFloat = randomColorGenerator()
        
        return Color(red: Double(red), green: Double(green), blue: Double(blue))
    }
}
