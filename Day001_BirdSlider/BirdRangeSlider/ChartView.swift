//
//  ChartView.swift
//  Day001_BirdSlider
//
//  Created by Pavlo Pryvalov on 07.08.2023.
//

import SwiftUI
import UIKit

struct ChartModel: Identifiable {
    var id = UUID()
    var value: Int
    var height: CGFloat
}

struct ChartView: View {
    private let CHART_HEIGHT: CGFloat = 150
    
    var minValueStep: Int = 0
    var maxValueStep: Int = 0
    var models: [ChartModel] = []
    
    @State var chartAnimated = false
    
    init(minValueStep: Int, maxValueStep: Int, dataCollection: [PriceModel]) {
        self.minValueStep = minValueStep
        self.maxValueStep = maxValueStep
        self.models = calculateHeights(for: dataCollection)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 4) {
            ForEach(models, id: \.id) { model in
                if minValueStep == 0 && maxValueStep == 0 {
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                        .frame(height: chartAnimated ? model.height : 0)
                } else {
                    if let step = models.firstIndex(where: { $0.id == model.id }),
                        step < minValueStep || step >= (models.count + maxValueStep) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                            .frame(height: chartAnimated ? model.height : 0)
                    } else {
                        Capsule()
                            .fill(Color("SelectedHandler"))
                            .frame(height: chartAnimated ? model.height : 0)
                    }
                }
            }
        }
        .frame(height: CHART_HEIGHT, alignment: .bottom)
        .onAppear {
            withAnimation(.bouncy(duration: 0.3).delay(0.2)) {
                chartAnimated = true
            }
        }
    }
    
    private func calculateHeights(for collection: [PriceModel]) -> [ChartModel] {
        let valueProp = CHART_HEIGHT / CGFloat(collection.map({ $0.count }).max() ?? 0)
        
        var array: [ChartModel] = []
        for value in collection.sorted(by: { (Double($0.price) ?? .infinity) < (Double($1.price) ?? .infinity) }).map({$0.count}) {
            array.append(.init(value: value, height: CGFloat(value) *  valueProp))
        }
        
        return array
    }
}

#Preview {
    ContentView()
}
