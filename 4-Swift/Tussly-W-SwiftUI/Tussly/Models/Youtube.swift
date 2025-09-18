//
//  Youtube.swift
//  Tussly
//
//  Created by Auxano on 19/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

struct YoutubeData : Codable{
    var items : AllItem?
}

struct AllItem: Codable {
    var snippet: SnippetData?
}

struct SnippetData: Codable {
    var title: String?
}
