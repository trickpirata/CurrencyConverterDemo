//
//  CurrencyExchangeView.swift
//  CurrencyConverterUI
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import SwiftUI

public struct CurrencyExchangeView<Header: View, Detail: View>: View {
    
    private let header: Header
    private let detail: Detail
    
    public var body: some View {
        ContentView {
            VStack(alignment: .leading, spacing: 1) {
                header.padding()
                detail
            }
        }
    }
    
    public init(@ViewBuilder header: () -> Header, @ViewBuilder detail: () -> Detail) {
        self.header = header()
        self.detail = detail()
    }
}

public struct CurrencyExchangeInputView: View {
    @Binding private var input: String
    @State private var expanded = false
    @Binding var selectedPickerIndex: Int
    private var currencies = [String]()
    private let image: Image?
    private let title: Text
    private var inputDisabled = false
    
    private var txtInput: some View {
        TextField(input, text: $input)
    }
    
    private var pickerInput: _CurrencyPickerView {
        _CurrencyPickerView(withCurrencies: currencies, bindingIndex: $selectedPickerIndex)
    }
    
    public var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline, spacing: 20) {
                image?.frame(width: 20, height: 20)
                title
                    .font(.body)
                    .fontWeight(.regular)
                Spacer()
                HStack(spacing: 10) {
                    txtInput
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                        .frame(width: 120)
                        .scaledToFit()
                        .disabled(inputDisabled)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Text(pickerInput.getCurrencies().count > 0 ? pickerInput.getCurrencies()[selectedPickerIndex] : "")
                        .font(.body)
                        .fontWeight(.regular)
                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(expanded ? -90 : 90))
                        .animation(expanded ? .easeOut : .easeIn)
                        .onTapGesture {
                            withAnimation(self.expanded ? .easeOut : .easeIn) {
                                self.expanded.toggle()
                            }
                            
                        }
                }
            }.padding()
            
            if expanded {
                pickerInput
                    .transition(.opacity)
                    .padding()
            }
        }
    }
    
    public init(image: Image?, title: Text,withCurrencies currencies: [String],withValue value: Binding<String>,andCurrencyIndexValue currencyIndexValue: Binding<Int>) {
        self.image = image
        self.title = title
        self.currencies = currencies
        self._input = value
        self._selectedPickerIndex = currencyIndexValue
    }
    
    public init(image: Image?, title: Text,withCurrencies currencies: [String],withValue value: Binding<String>,andCurrencyIndexValue currencyIndexValue: Binding<Int>, disableInput input: Bool) {
        self.image = image
        self.title = title
        self.currencies = currencies
        self._input = value
        self._selectedPickerIndex = currencyIndexValue
        self.inputDisabled = input
    }
}

public struct _CurrencyPickerView: View {
    @Binding private var selectedIndex: Int
    @State private var __selectedIndex = 0
    
    private var currencies = [String]()
    
    private var lblPicker: some View {
        Text("Default").font(.caption)
            .fontWeight(.regular)
    }
    
    public var body: some View {
        let selectedIndexBinding = Binding<Int>(get: {
            self.__selectedIndex
        }, set: {
            self.__selectedIndex = $0
            self.selectedIndex = $0
        })
        
        return Picker(selection: selectedIndexBinding, label: EmptyView()) {
                ForEach(0..<self.currencies.count) {
                    Text(self.currencies[$0]).tag($0)
                }
            }.labelsHidden()
    }

    public init(withCurrencies currencies: [String], bindingIndex: Binding<Int>) {
        self.currencies = currencies
        self._selectedIndex = bindingIndex
    }
    
    public func getCurrencies() -> [String] {
        return currencies
    }
}

#if DEBUG
struct CurrencyExchangeView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyExchangeView (header: {
            HeaderView(title: Text("Currency Exchange"), detail: nil)
        }) {
            CurrencyExchangeInputView(image: Image(systemName: "phone"), title: Text("Sell"), withCurrencies: ["AUS","EUR","USD"], withValue: .constant(""),andCurrencyIndexValue: .constant(0))
            CurrencyExchangeInputView(image: Image(systemName: "phone"), title: Text("Buy"), withCurrencies: ["AUS","EUR","USD"], withValue: .constant(""),andCurrencyIndexValue: .constant(0))
        }
        
    }
}
#endif
