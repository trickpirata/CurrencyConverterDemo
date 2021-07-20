//
//  HeaderView.swift
//  CurrencyConverterUI
//
//  Created by Trick Gorospe on 8/9/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import SwiftUI

public struct HeaderView: View {
    
    private let title: Text
    private let detail: Text?

    public var body: some View {
        VStack(alignment: .leading) {
            title
                .font(.headline)
                .fontWeight(.bold)
                
            detail?
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(Color(UIColor.systemGray2))
        }
        
    }
    
    public init(title: Text, detail: Text?){
        self.title = title
        self.detail = detail
    }
}

#if DEBUG
struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView(title: Text("Header"), detail: Text("Detail"))
    }
}
#endif
