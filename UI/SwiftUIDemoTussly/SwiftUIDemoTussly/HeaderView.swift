//
//  HeaderView.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 05/03/24.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        
        HStack {
            Button {
                print("Button Tussly Tap.")
            } label: {
                Image("Aplus")
                    .resizable()
                    .frame(width: 35, height: 35)
            }
            
            Label("Tussly", systemImage: "")
                .font(.headline)
            Spacer()
            
            Button {
                print("Button Tournament Tap.")
            } label: {
                Image("Tournament")
                    .resizable()
                    .frame(width: 35, height: 30)
            }
            
            Button {
                print("Button League Tap.")
            } label: {
                Image("LeagueDeactive")
                    .resizable()
                    .frame(width: 35, height: 30)
            }
            
            Button {
                print("Button TeamCard Tap.")
            } label: {
                Image("Teams")
                    .resizable()
                    .frame(width: 35, height: 30)
            }
            
            Button {
                print("Button PlayerCard Tap.")
            } label: {
                Image("Playercard")
                    .resizable()
                    .frame(width: 35, height: 30)
            }
            
            Button {
                print("Button Settings Tap.")
            } label: {
                Image("Settings")
                    .resizable()
                    .frame(width: 35, height: 30)
            }
            
        }
        .padding([.leading, .trailing, .top], 10)
    }
}

#Preview {
    HeaderView()
}
