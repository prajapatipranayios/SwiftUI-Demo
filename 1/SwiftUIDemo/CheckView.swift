//
//  CheckView.swift
//  SwiftUIDemo
//
//  Created by Auxano on 10/04/24.
//

import SwiftUI
import AVKit

struct CheckView: View {
    
    //@State private var completionAmount = 0.0
    //let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        
        ScrollView {
            
            
            
//            ZStack {
//                ContainerRelativeShape()
//                    .inset(by: 4)
//                    .fill(.blue)
//                
//                Text("Hello, World!")
//                    .font(.title)
//            }
//            .frame(width: 300, height: 200)
//            .background(.red)
//            .clipShape(Capsule())
            
            //Image("img3")
            //.resizable(resizingMode: .tile)
            //.resizable(capInsets: EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20), resizingMode: .tile)
            
//            Rectangle()
//                .fill(.red)
//                .frame(width: 200, height: 200)
//            
//            Circle()
//                .fill(.blue)
//                .frame(width: 100, height: 100)
//            
//            RoundedRectangle(cornerRadius: 25)
//                .fill(.green)
//                .frame(width: 150, height: 100)
//            
//            Capsule()
//                .fill(.green)
//                .frame(width: 150, height: 100)
            
            
//            Circle()
//                .stroke(.red, lineWidth: 20)
//                .fill(.orange)
//                .frame(width: 150, height: 150)
            
//            Circle()
//                .stroke(.blue, lineWidth: 45)
//                .stroke(.green, lineWidth: 35)
//                .stroke(.yellow, lineWidth: 25)
//                .stroke(.orange, lineWidth: 15)
//                .stroke(.red, lineWidth: 5)
//                .frame(width: 300, height: 150)
            
//            Circle()
//                .strokeBorder(.red, lineWidth: 20)
//                .background(Circle().fill(.orange))
//                .frame(width: 150, height: 150)
            
//            ZStack {
//                Circle()
//                    .fill(.orange)
//
//                Circle()
//                    .strokeBorder(.red, lineWidth: 20)
//            }
//            .frame(width: 150, height: 150)
            
//            Circle()
//                .trim(from: 0, to: 0.5)
//                .frame(width: 200, height: 200)
            
//            Rectangle()
//                .trim(from: 0, to: completionAmount)
//                .stroke(.red, lineWidth: 20)
//                .frame(width: 200, height: 200)
//                .rotationEffect(.degrees(-90))
//                .onReceive(timer) { _ in
//                    withAnimation {
//                        if completionAmount == 1 {
//                            completionAmount = 0
//                        } else {
//                            completionAmount += 0.2
//                        }
//                    }
//                }
        }
    }
}

#Preview {
    CheckView()
}


extension Shape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .stroke(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

extension InsettableShape {
    func fill<Fill: ShapeStyle, Stroke: ShapeStyle>(_ fillStyle: Fill, strokeBorder strokeStyle: Stroke, lineWidth: Double = 1) -> some View {
        self
            .strokeBorder(strokeStyle, lineWidth: lineWidth)
            .background(self.fill(fillStyle))
    }
}

