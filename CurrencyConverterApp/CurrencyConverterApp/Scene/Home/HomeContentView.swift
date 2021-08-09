//
//  HomeContentView.swift
//  CurrencyConverterApp
//
//  Created by Trick Gorospe on 8/10/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import SwiftUI
import CurrencyConverterUI
import ActivityIndicatorView
import Combine

struct HomeContentView<ViewModel>: View where ViewModel: HomeViewModel {
    @ObservedObject var viewModel: ViewModel
    @Binding private var historyItems: [HistoryViewItem]
    @State private var showErrorAlert: (Bool, String?) = (false, nil)
    @State private var showResetAlert: Bool = false
    
    var body: some View {
        let history = Binding<[HistoryViewItem]>(
            get: {
                self.viewModel.history.map { (history) -> HistoryViewItem in
                    let formatter = NumberFormatter.currency
                    let value = formatter.string(from: history.value as NSDecimalNumber) ?? ""
                    return HistoryViewItem(text:"\(value)\n\(history.currency)")
                }
            },
            set: {
                self.historyItems = $0
            }
        )
        
        return NavigationView {
            ZStack {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 20) {
                        //User Balance
                        MyBalanceView(header: {
                            HeaderView(title: Text("My Balance"), detail: Text("Current remaining balance."))
                        }, balance: {
                            Text("\(self.viewModel.txtBalance)")
                        }, withCurrencies: self.viewModel.currencies,
                        andCurrencyIndexValue: $viewModel.selectedBalanceCurrency)
                        
                        //User input for currency exchange
                        CurrencyExchangeView(header: {
                            HeaderView(title: Text("Currency Exchange"), detail: nil)
                        }, detail: {
                            CurrencyExchangeInputView(image: Image("imgSell"),
                                                      title: Text("Sell"),
                                                      withCurrencies: viewModel.currencies,
                                                      withValue: $viewModel.txtSellInput,
                                                      andCurrencyIndexValue: $viewModel.selectedCurrencyInput)
                            
                            CurrencyExchangeInputView(image: Image("imgReceive"),
                                                      title: Text("Buy"),
                                                      withCurrencies: viewModel.currencies,
                                                      withValue: $viewModel.txtSellOutput,
                                                      andCurrencyIndexValue: $viewModel.selectedCurrencyOutput,
                                                      disableInput: true)
                        }).alert(isPresented: self.$showErrorAlert.0, content: {
                            return Alert(title: Text("Ooops"),
                                         message: Text(self.showErrorAlert.1 ?? "An unexpected error occurred."),
                                         dismissButton: .default(Text("OK")))
                        })
                        
                        
                        //History View
                        HistoryView(header: {
                            HeaderView(title: Text("History"), detail: Text("Your balances."))
                        }, withItems: history)
                        
                        //Bottom Buttons
                        VStack(spacing: 5.0) {
                            //Submit button
                            Button(action: {
                                viewModel.convertCurrency(withRule: StandardRule()).sink { _ in
                                    
                                } receiveValue: { result in
                                    switch result {
                                    case .failure(.unknown):
                                        self.showErrorAlert = (true, "Unknown error occurred")
                                    case .failure(.cannotBeZero):
                                        self.showErrorAlert = (true, "Current balance cannot be zero")
                                    case .failure(.inputLower):
                                        self.showErrorAlert = (true, "Sell order is high than your current balance.")
                                    case .failure(.incompleteDetails):
                                        self.showErrorAlert = (true, "Please fill all required details")
                                    case .failure(.networkingError(let error)):
                                        self.showErrorAlert = (true, error.localizedDescription)
                                    default:
                                        break
                                    }
                                }.store(in: &viewModel.cancelBag)

                            }) {
                                Text("Submit")
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(40)
                            .alert(isPresented: self.$viewModel.showConversion) { () -> Alert in
                                return Alert(title: Text("Currency converted"), message: Text(viewModel.outputMessage), dismissButton: .default(Text("OK")))
                            }
                            
                            //Reset button
                            Button(action: {
                                showResetAlert.toggle()
                            }) {
                                Text("Reset")
                            }
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(40)
                            .alert(isPresented: $showResetAlert) { () -> Alert in
                                return Alert(title: Text("Wait!"),
                                             message: Text("Are you sure you want to reset the data?"),
                                             primaryButton: .cancel(Text("Cancel")),
                                             secondaryButton: .destructive(Text("Reset"), action: {
                                                viewModel.reset()
                                             }))
                            }
                        }
                        
                        
                    }.padding()
                }
                            
                //HUD loader
                ActivityIndicatorView(isVisible: $viewModel.isLoading, type: .default)
                    .frame(width: 50.0, height: 50.0)
            
                
            }.navigationBarTitle("Currency Converter")

        }
        .navigationViewStyle(StackNavigationViewStyle())
        
    }
}

extension HomeContentView {
    public init(model: HomeViewModelImp,historyItems: Binding<[HistoryViewItem]> = .constant([]),currencyOutputIndex: Binding<Int> = .constant(0)) {
        self.viewModel = model as! ViewModel
        self._historyItems = historyItems
    }
}

#if DEBUG
struct HomeContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeContentView<HomeViewModelImp>(model: HomeViewModelImp())
    }
}
#endif
