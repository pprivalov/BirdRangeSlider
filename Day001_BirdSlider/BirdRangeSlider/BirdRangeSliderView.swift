//
//  BirdRangeSliderView.swift
//  Day001_BirdSlider
//
//  Created by Pavlo Pryvalov on 07.08.2023.
//

import SwiftUI
import UIKit

struct BirdRangeSliderView: View {
    @Binding var selectedMinPrice: PriceModel
    @Binding var selectedMaxPrice: PriceModel
    
    @State var minValueStep: Int = 0
    @State var maxValueStep: Int = 0
    
    let collectionData: [PriceModel]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Ціна")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .padding(.leading, 10)
            
            ChartView(
                minValueStep: minValueStep,
                maxValueStep: maxValueStep,
                dataCollection: testPriceData
            )
            
            SliderView(
                minRange: collectionData.map({ Double($0.price) ?? 0 }).min() ?? 0,
                maxRange: collectionData.map({ Double($0.price) ?? 0 }).max() ?? 0,
                minValueStep: $minValueStep,
                maxValueStep: $maxValueStep,
                steps: collectionData.count - 1
            )
        }
        .padding(.all, 16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.09))
        )
        .onChange(of: minValueStep) { _, newValue in
            self.selectedMinPrice = collectionData[newValue]
        }
        .onChange(of: maxValueStep) { _, newValue in
            self.selectedMaxPrice = collectionData[collectionData.count + newValue - 1]
        }
    }
}

#Preview {
    ContentView()
}

