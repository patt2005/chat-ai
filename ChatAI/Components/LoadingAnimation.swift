//
//  LoadingAnimation.swift
//  ChatAI
//
//  Created by Petru Grigor on 27.12.2024.
//

import SwiftUI

struct LoadingAnimation: View {
    @State private var showCircle1 = false
    @State private var showCircle2 = false
    @State private var showCircle3 = false
    
    private func performAnimation() {
        let animation = Animation.easeInOut(duration: 0.4)
        withAnimation(animation) {
            self.showCircle1 = true
            self.showCircle3 = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation (animation) {
                self.showCircle2 = true
                self.showCircle1 = false
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation (animation) {
                self.showCircle2 = false
                self.showCircle3 = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            self.performAnimation()
        }
    }
    
    var body: some View {
        HStack {
            Circle()
                .opacity(showCircle1 ? 1 : 0)
            
            Circle()
                .opacity(showCircle2 ? 1 : 0)
            
            Circle()
                .opacity(showCircle3 ? 1 : 0)
        }
        .foregroundColor(.white)
        .onAppear(perform: performAnimation)
    }
}
