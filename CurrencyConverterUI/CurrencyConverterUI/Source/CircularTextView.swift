//
//  CircularContentView.swift
//  CurrencyConverterUI
//
//  Created by Trick Gorospe on 8/9/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//


import SwiftUI

public struct CircularTextView: View {
    
    private let detail: Text

    public var body: some View {
        GeometryReader{ geo in
            ZStack {
                Circle().fill(Color.accentColor)
                self.detail
                    .lineLimit(2)
                    .scaledToFit()
                    .minimumScaleFactor(0.5)
                    .font(.system(size: geo.size.height > geo.size.width ? geo.size.width * 0.4: geo.size.height * 0.4))
                    .foregroundColor(Color.white)
                    .multilineTextAlignment(.center)
                    
            }
            .clipShape(Circle())
            .font(Font.body.weight(.semibold))
        }
        
    }
    
    public init(detail: Text) {
        self.detail = detail
    }
}

#if DEBUG
struct CircularTextView_Previews: PreviewProvider {
    static var previews: some View {
        CircularTextView(detail: Text("500 USD")).frame(height: 90)
    }
}
#endif
