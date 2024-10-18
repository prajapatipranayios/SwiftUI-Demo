//
//  ContentView.swift
//  SwiftUIDemo
//
//  Created by MAcBook on 06/05/23.
//

import SwiftUI

struct ContentView: View {
    
    @State private var name : String = String()
    @State private var fname : String = String()
    @State private var lname : String = String()
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    TextField("First Name", text: $fname)
                    TextField("Last Name", text: $lname)
                }
                .background(Color.gray.opacity(0.4))
                
                Image(systemName: "globe")
                    .scaledToFill()
                    .imageScale(.large)
                    .foregroundColor(.blue)
                    .frame(width: 100, height: 100, alignment: .center)
                    .background(Color.blue.opacity(0.2))
                    //.rotation3DEffect(Angle(degrees: 60), axis: (x: 0, y: 10, z: 0))
                    //.rotationEffect(Angle(degrees: 30))
                    //.scaleEffect(0.9)
                    //.blendMode(.hardLight)
                    //.blur(radius: 0.8)
                    .cornerRadius(10)
                
                Spacer()
                HStack {
                    Button("Home") {
                        debugPrint("Home")
                    }
                    .background(Color.green)
                    //.padding()
                    Button("Scheduled") {
                        debugPrint("Scheduled")
                    }
                    .background(Color.green)
                    //.padding()
                    Button("Chat") {
                        debugPrint("Chat")
                    }
                    .background(Color.green)
                    .padding()
                    Button("Notification") {
                        debugPrint("Notification")
                    }
                    .background(Color.green)
                    //.padding()
                    Button("====") {
                        print("Side Menu")
                    }
                    .background(Color.green)
                    .padding()
                }
                .background(Color.blue.opacity(0.3))
                .padding()
            }
            .multilineTextAlignment(.center)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
        /*VStack {
            Image(systemName: "globe").imageScale(.large).foregroundColor(.accentColor)
            Text("Hello, world!").font(.largeTitle).bold().italic()
            TextField("Username", text: $name)
            Button(action: {
                debugPrint("Button clicked...")
            }, label: {
                Text("Login")
            }).disabled(name.count < 4)
        }
        .padding()  /// */
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
