//
//  ArenaWorksCardView.swift
//  SwiftUIDemoTussly
//
//  Created by Auxano on 05/03/24.
//

import SwiftUI
//import ASCollectionView

struct ArenaWorksCardView: View {
    
    @State private var selectedIndex: Int?
    
    var body: some View {
        Label("How the Tussly Arena Works", image: "")
            .font(.headline)
            .padding([.top, .bottom])
        
        ScrollView(.horizontal, showsIndicators: false) {
            //HStack(spacing: 10) {
            HStack(spacing: 0) {
                //ForEach(Storage.people) { people in
                ForEach(Storage.people) { people in
                    NavigationLink(destination: Text("Hello = \(people.gameTitle)")) {
                        ArenaGameListView(person: people)
                    }
                }
                //.cornerRadius(15)
                .padding([.leading], 10)
            }
            selectedIndex.map {
                Text("\($0)")
                    .font(.largeTitle)
            }
        }
        
//        ASCollectionView(data: dataExample, dataID: \.self) { item, _ in
//            Color.blue
//                .overlay(Text("\(item)"))
//        }
//        .layout {
//            .grid(layoutMode: .adaptive(withMinItemSize: 100),
//                  itemSpacing: 5,
//                  lineSpacing: 5,
//                  itemSize: .absolute(50))
//        }
        
//        List() {
//            ForEach(0..<8) { _ in
//                HStack {
//                    ForEach(0..<3) { _ in
//                        Image("111")
//                            .resizable()
//                            .scaledToFit()
//                    }
//                }
//            }
//        }
    }
}

#Preview {
    ArenaWorksCardView()
}
