//
//  LoadingView.swift
//  iza-app
//
//  Created by Lukáš Mader on 23/05/2025.
//

import SwiftUI

struct LoadingView: View {
    
    @State private var changeScale: Bool = false
    @State private var isLogoAnimating = false
    @State private var loadingText = "Signing you in"
    @State private var dotCount = 4
    
    let size = UIScreen.main.bounds.width * 0.15
    let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.adaptiveBackground
                .ignoresSafeArea()
            
            VStack(spacing: 40){
                
                // Logo
                HStack(spacing: 0) {
                    Text("Nx")
                        .font(.system(size: 60, weight: .heavy, design: .default))
                        .foregroundColor(.purple)
                    Text("Trip")
                        .font(.system(size: 60, weight: .heavy, design: .default))
                        .foregroundColor(Color.adaptivePrimaryText)
                }
                .scaleEffect(isLogoAnimating ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isLogoAnimating)
                
                // loading circles
                HStack{
                    addCircleView(delayTime: 0.2, endScale: 0.2)
                    addCircleView(delayTime: 0.3, endScale: 0.5)
                    addCircleView(delayTime: 0.7, endScale: 0.2)
                }
                
                // loading text
                VStack(spacing: 12) {
                    Text(loadingText + String(repeating: ".", count: dotCount))
                        .font(.system(size: 18, weight: .medium, design: .monospaced))
                        .foregroundColor(Color.adaptivePrimaryText)
                        .multilineTextAlignment(.center)
                    
                    Text("Please wait")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(Color.adaptiveSecondaryText)
                }
                
            }
            .onAppear(){
                withAnimation{
                    changeScale.toggle()
                }
                isLogoAnimating = true
            }
            .onReceive(timer) { _ in
                dotCount = (dotCount + 1) % 4
                if dotCount == 0 {
                    let messages = [
                        "Signing you in",
                        "Almost there",
                        "Setting up your profile",
                        "Loading your data",
                        "Getting things ready"
                    ]
                    loadingText = messages.randomElement() ?? "Signing you in"
                }
            }
        }
    }
    
    @ViewBuilder
    func addCircleView(delayTime: CGFloat, endScale: CGFloat) -> some View {
        ZStack{
            Circle()
                .fill(Color.purple)
                .frame(width: size, height: size)
                .overlay(
                    Circle()
                        .fill(Color.adaptiveBackground)
                        .scaleEffect(changeScale ? 0.8 : endScale)
                        .animation(.easeInOut(duration: 0.7).repeatForever().delay(delayTime), value: changeScale)
                )
        }
    }
}
