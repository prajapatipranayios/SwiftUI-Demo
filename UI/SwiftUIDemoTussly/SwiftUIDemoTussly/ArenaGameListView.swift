//
//  ArenaGameListView.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 05/03/24.
//

import SwiftUI

struct ArenaGameListView: View {
    
    //private let gameTitle: [String] = ["SSBU", "NASB 2", "SSBM", "Tekken", "Virtua Fighter 5"]
    var person: Person
    
    var body: some View {
        VStack() {
            Image(person.gameImage)
                .resizable()
                .scaledToFit()
                //.frame(width: 170, height: 170)
                .frame(maxWidth: 170, maxHeight: 170)
                .background(Color.yellow)
                .cornerRadius(.infinity)
            
            Text(person.gameTitle)
                .font(.headline)
                .background(Color.white)
                .foregroundColor(.black)
            //Text(person.lastName).font(.headline).color(.white)
        }
    }
}

#Preview {
    ArenaGameListView(person: Person(id: 1,
                                     gameTitle: "SSBU",
                                     gameImage: "111"))
}
