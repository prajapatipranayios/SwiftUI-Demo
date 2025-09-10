//
//  TournamentOverlay.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 05/03/24.
//

import SwiftUI

struct TournamentOverlay: View {
    var body: some View {
        VStack {
            Text("No Match Scheduled")
                //.font(.title2)
                .font(.title2)
                .foregroundColor(.white)
                //.background(Color.black)
                .padding([.leading, .bottom])
            
            Text("You are not registered for any\nLeagues or Tournaments")
                .foregroundColor(.white)
                //.background(Color.black)
                .padding([.leading])
            
            Button("Search Tournaments") {
                print("Serach Tournament button tapped.")
            }
            .padding()
            .font(.headline)
            .frame(height: 30)
            .foregroundColor(.white)
            .background(Color(red: 198.0/255.0, green: 26.0/255.0, blue: 27.0/255.0), in: .rect(cornerSize: CGSize(width: .max, height: .max)))
            .frame(alignment: .leading)
        }
        .frame(width: UIScreen.screenWidth, alignment: .leading)
        .padding([.top, .bottom, .leading])
        //.background(Color.blue)
    }
}

#Preview {
    TournamentOverlay()
}
