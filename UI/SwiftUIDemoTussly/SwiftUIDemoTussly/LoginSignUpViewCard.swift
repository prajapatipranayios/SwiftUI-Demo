//
//  LoginSignUpViewCard.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 06/03/24.
//

import SwiftUI

struct LoginSignUpViewCard: View {
    var body: some View {
        HStack {
            Label("Register for free", systemImage: "")
                .font(.headline)
            Spacer()
            Button("Login") {
                
            }
            .font(.headline)
            .frame(width: 90, height: 30)
            .foregroundColor(.black)
            .background(Color.white, in: .rect(cornerSize: CGSize(width: .max, height: .max)))
            
            Button("Sign Up") {
                
            }
            .font(.headline)
            .frame(width: 90, height: 30)
            .foregroundColor(.black)
            .background(Color.white, in: .rect(cornerSize: CGSize(width: .max, height: .max)))
        }
        .padding([.leading, .trailing], 10)
        .frame(height: 55)
        .background(Color(red: 198.0/255.0, green: 26.0/255.0, blue: 27.0/255.0))
    }
}

#Preview {
    LoginSignUpViewCard()
}
