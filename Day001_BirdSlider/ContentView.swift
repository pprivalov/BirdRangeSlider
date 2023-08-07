//
//  ContentView.swift
//  Day001_BirdSlider
//
//  Created by Pavlo Pryvalov on 05.08.2023.
//

import SwiftUI
import UIKit

struct PriceModel: Identifiable {
    var id = UUID()
    var price: String
    var count: Int
}

let testPriceData: [PriceModel] = [
    PriceModel(price: "0", count: 0),
    PriceModel(price: "4000", count: 1),
    PriceModel(price: "5000", count: 5),
    PriceModel(price: "6000", count: 8),
    PriceModel(price: "7000", count: 12),
    PriceModel(price: "8000", count: 15),
    PriceModel(price: "9000", count: 13),
    PriceModel(price: "10000", count: 20),
    PriceModel(price: "11000", count: 16),
    PriceModel(price: "12000", count: 18),
    PriceModel(price: "13000", count: 24),
    PriceModel(price: "14000", count: 22),
    PriceModel(price: "15000", count: 18),
    PriceModel(price: "16000", count: 14),
    PriceModel(price: "17000", count: 12),
    PriceModel(price: "18000", count: 10),
    PriceModel(price: "19000", count: 12),
    PriceModel(price: "20000", count: 15),
    PriceModel(price: "22000", count: 17),
    PriceModel(price: "24000", count: 10),
    PriceModel(price: "26000", count: 12),
    PriceModel(price: "28000", count: 9),
    PriceModel(price: "30000", count: 5),
    PriceModel(price: "35000", count: 10),
    PriceModel(price: "40000", count: 7),
    PriceModel(price: "50000", count: 8),
    PriceModel(price: "60000", count: 1),
    PriceModel(price: "80000", count: 1),
    PriceModel(price: "100000", count: 0),
    PriceModel(price: "120000", count: 1),
    PriceModel(price: ">120000", count: 0)
]

struct ContentView: View {
    @State var selectedMinPrice: PriceModel = testPriceData.first!
    @State var selectedMaxPrice: PriceModel = testPriceData.last!
    
    var rangeTotalCount: Int {
        let startIndex = testPriceData.firstIndex(where: { $0.id == selectedMinPrice.id }) ?? 0
        let endIndex = testPriceData.firstIndex(where: { $0.id == selectedMaxPrice.id }) ?? 0
        
        
        return Array(testPriceData[startIndex...endIndex]).reduce(0) { $0 + $1.count }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 20) {
                BirdRangeSliderView(selectedMinPrice: $selectedMinPrice,
                                    selectedMaxPrice: $selectedMaxPrice,
                                    collectionData: testPriceData)
                Button(action: {}, label: {
                    Text("Показати \(rangeTotalCount) квартир")
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                })
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("SelectedHandler"))
                )
            }
        }
        .padding(.all, 16)
        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .background(Color("Background"))
    }
}

#Preview {
    ContentView()
}
