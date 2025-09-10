//
//  TournamentCardView.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 05/03/24.
//

import SwiftUI

struct TournamentCardView: View {
    
    var isTournament: Bool = false
    
    var body: some View {
        Section {
            if isTournament {
                
            }
            else {
                Text("My Tournaments")
                    .font(.headline)
                    .padding([.top, .bottom])
                
                Image("NoLeagueFound")
                    .resizable()
                    .frame(width: UIScreen.screenWidth - 20, height: 170)
                    .cornerRadius(15.0)
                    .overlay(alignment: .leading) {
                        TournamentOverlay()
                    }
            }
        }
    }
}

#Preview {
    TournamentCardView()
}
