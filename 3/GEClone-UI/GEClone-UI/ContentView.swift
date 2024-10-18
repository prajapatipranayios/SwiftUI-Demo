//
//  ContentView.swift
//  GEClone-UI
//
//  Created by Auxano on 18/10/24.
//

import SwiftUI

struct ContentView: View {
    
    // Persisted login state using @AppStorage
    //@AppStorage("isLoggedIn") private var isLoggedIn: Bool = false
    @EnvironmentObject var loginManager: LoginManager

       var body: some View {
           Group {
               if loginManager.isLoggedIn {
                   HomeView() // Shows the HomeView with side menu after login
               } else {
                   LoginView() // Shows the login screen
               }
           }
       }
}

#Preview {
    ContentView()
}


class LoginManager: ObservableObject {
    @Published var isLoggedIn: Bool = false
}

