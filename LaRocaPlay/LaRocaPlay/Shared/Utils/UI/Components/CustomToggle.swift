//
//  CustomToggle.swift
//  LaRocaPlay
//
//  Created by Ancel Dev account on 24/1/26.
//

import SwiftUI

struct CustomToggle: View {
    
    @Binding var isOn: Bool
    
    var body: some View {
        ZStack {
            Capsule()
                .fill(isOn ? .customRed : .dirtyWhite)
            Circle()
                .fill(.white)
                .frame(width: 15)
                .position(x: isOn ? 30 : 11, y: 11)
                .overlay {
                    Circle()
                        .fill(
                            LinearGradient(colors: [.gray.opacity(0.3), .white], startPoint: .bottom, endPoint: .top)
                        )
                        .frame(width: 14)
                        .position(x: isOn ? 230 : 11, y: 10.5)
                }
            Circle()
                .fill(isOn ? .customRed : .dirtyWhite)
                .frame(width: 4)
                .position(x: isOn ? 30 : 11, y: 11)
        }
        .padding(2)
        .frame(width: 44, height: 26)
        
        .onTapGesture {
            withAnimation(.linear(duration: 0.25)) {
                isOn.toggle()
            }
        }
        .enableInjection()
    }
#if DEBUG
    @ObserveInjection var forceRedraw
#endif
}
