//
//  Slider.swift
//  Day001_BirdSlider
//
//  Created by Pavlo Pryvalov on 07.08.2023.
//

import SwiftUI
import UIKit

struct SliderView: View {
    private let HANDLER_WIDTH: CGFloat = 85
    private let SLIDER_HEIGHT: CGFloat = 60
    private let STEP_COUNTS: Int

    @State var minValue: CGFloat = 0
    @State var maxValue: CGFloat = 120000 + 100
    private let minRange: CGFloat
    private let maxRange: CGFloat
    
    private let softFeedback = UIImpactFeedbackGenerator(style: .soft)
    private let rigidFeedback = UIImpactFeedbackGenerator(style: .rigid)
    
    private var isRangeSelected: Bool {
        minValue != minRange || maxValue <= maxRange
    }
    
    init(
        minValue: CGFloat? = nil,
        maxValue: CGFloat? = nil,
        minRange: CGFloat = 0,
        maxRange: CGFloat = 120000,
        minValueStep: Binding<Int>,
        maxValueStep: Binding<Int>,
        steps: Int = 30
    ) {
        self.minValue = minValue ?? minRange
        self.maxValue = maxValue ?? maxRange + 100
        self.minRange = minRange
        self.maxRange = maxRange
        self._minValueStep = minValueStep
        self._maxValueStep = maxValueStep
        self.STEP_COUNTS = steps
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                if isRangeSelected {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color("SelectedSlider"))
                        .frame(width: geometry.size.width - minOffset + maxOffset, height: SLIDER_HEIGHT)
                        .offset(x: minOffset)
                }
                
                HStack {
                    MinHandler(sliderWidth: geometry.size.width)
                    Spacer()
                    MaxHandler(sliderWidth: geometry.size.width)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.1))
            )
            .onAppear {
                self.setupInitialOffset(sliderWidth: geometry.size.width)
            }
        }
        .frame(height: SLIDER_HEIGHT)
    }
    
    func setupInitialOffset(sliderWidth: CGFloat) {
        let stepOffset = (sliderWidth - 2 * (HANDLER_WIDTH)) / CGFloat(STEP_COUNTS - 2)
        var step: Int = 0
        var tmpValue: CGFloat = 0
        
        while tmpValue != minValue {
            tmpValue = tmpValue + stepValue(for: tmpValue + 1)
            step += 1
        }
        
        minValueStep = step
        minOffset = CGFloat(step) * stepOffset
        lastMinOffset = minOffset
        
        step = 0
        tmpValue = maxRange + 100
        
        while tmpValue != maxValue {
            tmpValue = tmpValue - stepValue(for: tmpValue)
            step += 1
        }
        
        maxValueStep = -step
        maxOffset = CGFloat(-step) * stepOffset
        lastMaxOffset = maxOffset
    }

    // MARK: - Min Handler
    @State var isMinHandlerActive: Bool = false
    @State var minValueText: String = "від"
    @State var minOffset: CGFloat = 0
    @State var lastMinOffset: CGFloat = 0
    @Binding var minValueStep: Int
    
    func MinHandler(sliderWidth: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isRangeSelected ? Color("SelectedHandler") : Color.white.opacity(0.1))
                .frame(width: HANDLER_WIDTH, height: SLIDER_HEIGHT)
            
            Text(minValueText)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .transition(.asymmetric(insertion: .offset(x: 15), removal: .opacity))
                .id("TextId" + minValueText)
        }
        .offset(x: minOffset, y: isMinHandlerActive ? -(SLIDER_HEIGHT + 2) : 0)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged({ gesture in
                withAnimation(.linear(duration: 0.1)) {
                    isMinHandlerActive = true
                }
                
                calcMinOffset(gesture: gesture, sliderWidth: sliderWidth)
                calcMinValue(with: minOffset, sliderWidth: sliderWidth)
            })
            .onEnded({ gesture in
                withAnimation(.linear(duration: 0.1)) {
                    isMinHandlerActive = false
                }
                
                lastMinOffset = minOffset
            })
        )
        .onChange(of: minValue) { _, newValue in
            changeMinLabel(newValue)
        }
        .onChange(of: minOffset) { _, _ in
            changeMinLabel(minValue)
        }
    }
    
    // MARK: - Min Offset
    func calcMinOffset(gesture: DragGesture.Value, sliderWidth: CGFloat) {
        minOffset = lastMinOffset + gesture.translation.width
        
        if minOffset <= 0 {
            minOffset = 0
        }
        
        let offsetEnd = -2 * HANDLER_WIDTH + maxOffset + sliderWidth - 1
        
        if minOffset > offsetEnd {
            minOffset = offsetEnd
        }
    }
    
    // MARK: - Min Value
    func calcMinValue(with offset: CGFloat, sliderWidth: CGFloat) {
        let stepOffset = (sliderWidth - 2 * (HANDLER_WIDTH)) / CGFloat(STEP_COUNTS - 2)
        let step = Int(offset / stepOffset)
        if step != minValueStep {
            let delta: CGFloat = CGFloat((step - minValueStep) / abs(minValueStep - step))
            for _ in 0..<abs(minValueStep - step) {
                minValue = minValue + delta * (stepValue(for: minValue + delta))
                if minValue == minRange {
                    rigidFeedback.impactOccurred(intensity: 1)
                } else {
                    softFeedback.impactOccurred(intensity: 0.7)
                }
            }
            minValueStep = step
        }
    }
    
    // MARK: - Min Label
    func changeMinLabel(_ minValue: CGFloat) {
        if minValue == minRange && maxValue > maxRange {
            withAnimation(.easeIn(duration: 0.1)) {
                minValueText = "від"
                maxValueText = "до"
            }
        } else {
            minValueText = Int(minValue).formatWithSpacing() + " ₴"
            
            if maxValue > maxRange {
                withAnimation(.easeIn(duration: 0.1)) {
                    maxValueText = "∞"
                }
            } else {
                maxValueText = Int(maxValue).formatWithSpacing() + " ₴"
            }
        }
    }
    
    
    // MARK: - Max Handler
    @State var isMaxHandlerActive: Bool = false
    @State var maxValueText: String = "до"
    @State var maxOffset: CGFloat = 0
    @State var lastMaxOffset: CGFloat = 0
    @Binding var maxValueStep: Int
    
    func MaxHandler(sliderWidth: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isRangeSelected ? Color("SelectedHandler") : Color.white.opacity(0.1))
            
            Text(maxValueText)
                .fontWeight(.bold)
                .foregroundStyle(Color.white)
                .transition(.asymmetric(insertion: .offset(x: 15), removal: .opacity))
                .id("TextId" + maxValueText)
        }
        .offset(x: maxOffset, y: isMaxHandlerActive ? -(SLIDER_HEIGHT + 2) : 0)
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged({ gesture in
                withAnimation(.linear(duration: 0.1)) {
                    isMaxHandlerActive = true
                }
                
                calcMaxOffset(gesture: gesture, sliderWidth: sliderWidth)
                calcMaxValue(with: maxOffset, sliderWidth: sliderWidth)
            })
                .onEnded({ gesture in
                    withAnimation(.linear(duration: 0.1)) {
                        isMaxHandlerActive = false
                    }
                    
                    lastMaxOffset = maxOffset
                })
        )
        .frame(width: HANDLER_WIDTH, height: SLIDER_HEIGHT)
        .onChange(of: maxValue) { _, newValue in
            changeMaxLabel(newValue)
        }
        .onChange(of: maxOffset) { _, _ in
            changeMaxLabel(maxValue)
        }
    }
    
    // MARK: - Max Offset
    func calcMaxOffset(gesture: DragGesture.Value, sliderWidth: CGFloat) {
        maxOffset = lastMaxOffset + gesture.translation.width
        
        if maxOffset > 0 {
            maxOffset = 0
        }
        
        let offsetEnd = 2 * HANDLER_WIDTH + minOffset - sliderWidth + 1
        
        if maxOffset < offsetEnd {
            maxOffset = offsetEnd
        }
    }
    
    func calcMaxValue(with offset: CGFloat, sliderWidth: CGFloat) {
    // MARK: - Max Value
        let stepOffset = (sliderWidth - 2 * (HANDLER_WIDTH)) / CGFloat(STEP_COUNTS - 2)
        let step = Int(offset / stepOffset)

        if step != maxValueStep {
            let delta: CGFloat = CGFloat((step - maxValueStep) / abs(step - maxValueStep))
            for _ in 0..<abs(step - maxValueStep) {
                maxValue = maxValue + delta * (stepValue(for: maxValue + delta))
                if maxValue > maxRange {
                    rigidFeedback.impactOccurred(intensity: 1)
                } else {
                    softFeedback.impactOccurred(intensity: 0.7)
                }
            }
            
            maxValueStep = step
        }
    }
    
    // MARK: - Max Label
    func changeMaxLabel(_ newValue: CGFloat) {
        if minValue == minRange && newValue > maxRange {
            withAnimation(.easeIn(duration: 0.1)) {
                minValueText = "від"
                maxValueText = "до"
            }
        } else if newValue > maxRange {
            withAnimation(.easeIn(duration: 0.1)) {
                maxValueText = "∞"
            }
        } else {
            maxValueText = Int(maxValue).formatWithSpacing() + " ₴"
            minValueText = Int(minValue).formatWithSpacing() + (minValue > 0 ? " ₴" : "")
        }
    }
    
    // MARK: - Step Values
    func stepValue(for value: CGFloat) -> CGFloat {
        switch value {
        case 0..<4000: return 4000
        case 4000...20000: return 1000
        case 20000...30000: return 2000
        case 30000...40000: return 5000
        case 40000...60000: return 10000
        case 60000...maxRange: return 20000
        default: return 100
        }
    }
}

extension Int {
    func formatWithSpacing() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = " "

        if let formattedNumber = numberFormatter.string(from: NSNumber(value: self)) {
            return formattedNumber
        } else {
            return ""
        }
    }
}

#Preview {
    ContentView()
}
