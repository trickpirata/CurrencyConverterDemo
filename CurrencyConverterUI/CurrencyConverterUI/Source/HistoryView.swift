//
//  HistoryView.swift
//  CurrencyConverterUI
//
//  Created by Trick Gorospe on 8/9/20.
//  Copyright © 2020 Trick Gorospe. All rights reserved.
//

import SwiftUI

public struct HistoryViewItem: Identifiable {
    public let id = UUID()
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
}

public struct HistoryView<Header: View>: View {
    private let header: Header
    @Binding private var items: [HistoryViewItem]
    public var body: some View {
        ContentView {
            VStack(alignment: .leading, spacing: 10) {
                header.padding()
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack(spacing: 10) {
                        ForEach(items, id: \.id) { data in
                            CircularTextView(detail: Text(data.text))
                                .frame(width: 100, height: 100, alignment: .center)
                                .animation(.easeOut)
                                .transition(.scale)
                        }
                    }
                }
                .frame(height: 150)
                .padding()
            }
        }
    }
    
    public init(@ViewBuilder header: () -> Header,withItems items: Binding<[HistoryViewItem]>) {
        self.header = header()
        self._items = items
    }
    
}

#if DEBUG
struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(header: {
            HeaderView(title: Text("History"), detail: Text("Your past conversions."))
        }, withItems: .constant([HistoryViewItem(text: "1"),HistoryViewItem(text: "1"),HistoryViewItem(text: "1"),HistoryViewItem(text: "1"),HistoryViewItem(text: "1"),HistoryViewItem(text: "1")]))
    }
}
#endif
