//
//  InitialViewCard.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 06/03/24.
//

import SwiftUI

struct InitialViewCard: View {
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                LoginSignUpViewCard()
                
                HStack {
                    NavigationLink(destination: Text("Hello = Player Card clicked...")) {
                        //ArenaGameListView(person: people)
                        ProfileCardView(strTitle: "My Player Card", strImageName: "Profile")
                    }
                    //Spacer()
                    NavigationLink(destination: Text("Hello = Teams Card clicked...")) {
                        ProfileCardView(strTitle: "My Teams", strImageName: "Teams")
                    }
                }
                .padding([.leading, .trailing, .bottom], 10)
                //.background(Color.gray)
                
                TournamentCardView()
                
                ArenaWorksCardView()
            }
            //.background(Color.gray)
        }
    }
}

#Preview {
    InitialViewCard()
}
