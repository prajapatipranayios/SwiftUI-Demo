//
//  ProfileCardView.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 05/03/24.
//

import SwiftUI

struct ProfileCardView: View {
    
    private let profileHeight: CGFloat = (UIScreen.screenWidth - 24) / 2
    var strTitle: String = "My Player Card"
    var strImageName: String = "Profile"
    
    var body: some View {
        VStack {
            Text(strTitle)
                .font(.headline)
                .padding([.top])
            
            Image(strImageName)
                .resizable()
                .frame(width: profileHeight, height: profileHeight)
                .cornerRadius(15.0)
        }
    }
}

#Preview {
    ProfileCardView()
}
