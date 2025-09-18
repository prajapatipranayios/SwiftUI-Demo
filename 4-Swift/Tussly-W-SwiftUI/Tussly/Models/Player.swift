//
//  Player.swift
//  - Describes Player & related information

//  Tussly
//
//  Created by Jaimesh Patel on 13/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import Foundation

struct Player: Codable {
    var id: Int?
    var playerStatus: Int?
    var avatarImage: String?
    var displayName: String?
    var matchId: Int?
    var isStarter: Int?
    var role: Int?
    var isSelected: Bool?
    var logoImage: String?
    var votes: Int?
    var friendStatus: Int?
    var actionUserId: Int?
    var current_page: Int?
    var first_page_url: String?
    var from: Int?
    var last_page_url: String?
    var last_page: Int?
    var next_page_url: String?
    var path: String?
    var prev_page_url: String?
    var per_page: Int?
    var to: Int?
    var total: Int?
    var data: [PlayerData]?
    
    var playerDescription: String?
    var bannerImage: String?
    var friendId: Int?
}

struct ResultAverage: Codable {
    var title: String?
    var wl: String?
    var percantage: String?
    var stocks: Int?
    var isShowStageInLeftSideBar: Int?
    var isShowOppositeCharInHeader: Int?
    var resultHeaderTitle: String?
    var characterOrStageInfo: Characters?
}

struct PlayerData: Codable {
    var displayName: String?
    var id: Int?
    var playerStatus: Int?
    var actionUserId: Int?
    var avatarImage: String?
    
    //  By Pranay
    var playerDescription: String?
    var bannerImage: String?
    // .
}

struct FilterResult: Codable {
    var id: Int?
    var title: String?
    var logo: String?
    var type: String?
    var imgType: String?
    var isSelectedColumn: Int?
    var filterData: [FilterData]?
    var mapImage: String?
    var imagePath: String?
}

struct FilterData: Codable {
    var imageUrl: String?
    var imagePath: String?
    var name: String?
    var id: Int?
    var type: String?
    var imgType: String?
    var rwrl: String?
    var per: String?
    var stock: String?
    //var isRowSelected: Bool?
}

// MARK: - PlayerAllCharacter
struct PlayerAllCharacter: Codable {
    var characters: [Characters]?
    var playerId: Int?
}
