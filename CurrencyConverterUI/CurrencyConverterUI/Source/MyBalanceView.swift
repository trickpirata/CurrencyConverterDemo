//
//  MyBalanceView.swift
//  CurrencyConverterUI
//
//  Created by Trick Gorospe on 8/9/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import SwiftUI

public struct MyBalanceView<Header: View>: View {
    
    private let header: Header
    private let balance: Text
    
    public var body: some View {
        ContentView {
            VStack {
                HStack {
                    header.padding([.leading, .top, .trailing])
                    Spacer()
                }
                HStack {
                    balance
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    Spacer()
                }
                
                
            }
        }
    }
    
    public init(@ViewBuilder header: () -> Header, @ViewBuilder balance: () -> Text) {
        self.header = header()
        self.balance = balance()
    }
}

#if DEBUG
struct MyBalanceView_Previews: PreviewProvider {
    private static var header: some View {
        HeaderView(title: Text("My Balance"), detail: Text("Current remaining balance"))
    }
    
    static var previews: some View {
        MyBalanceView(header: {
            header
        }) { () -> Text in
            Text("100 EURO")
        }
    }
}
#endif
