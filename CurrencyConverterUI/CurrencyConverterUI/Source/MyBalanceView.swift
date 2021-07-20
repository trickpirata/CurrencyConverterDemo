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
    
    // Picker view
    @State private var expanded = false
    @Binding var selectedPickerIndex: Int
    private var currencies = [String]()
    
    private var pickerInput: _CurrencyPickerView {
        _CurrencyPickerView(withCurrencies: currencies, bindingIndex: $selectedPickerIndex)
    }
    
    public var body: some View {
        ContentView {
            VStack(spacing: 10) {
                HStack {
                    header.padding([.leading, .top, .trailing])
                    Spacer()
                }
                HStack {
                    balance
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text(pickerInput.getCurrencies().count > 0 ? pickerInput.getCurrencies()[selectedPickerIndex] : "")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(expanded ? -90 : 90))
                        .animation(expanded ? .easeOut : .easeIn)
                        .onTapGesture {
                            withAnimation(self.expanded ? .easeOut : .easeIn) {
                                self.expanded.toggle()
                            }
                        }
                    Spacer()
                }.padding([.leading, .bottom])
                
                if expanded {
                    pickerInput
                        .transition(.opacity)
                        .padding()
                }
            }
        }
    }
    
    public init(@ViewBuilder header: () -> Header, @ViewBuilder balance: () -> Text) {
        self.init(header: header, balance: balance, withCurrencies: [String](), andCurrencyIndexValue: .constant(0))
    }
    
    public init(@ViewBuilder header: () -> Header, @ViewBuilder balance: () -> Text,withCurrencies currencies: [String],andCurrencyIndexValue currencyIndexValue: Binding<Int>) {
        self.header = header()
        self.balance = balance()
        self.currencies = currencies
        self._selectedPickerIndex = currencyIndexValue
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
        }, balance: {
            Text("100")
        }, withCurrencies: ["EUR", "USD", "JPY"], andCurrencyIndexValue: .constant(0))
    }
}
#endif
