//
//  PlayerCard.swift
//  - Describes PlayerCard related information

//  Tussly
//
//  Created by Auxano on 21/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

struct PlayerCard: Codable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var displayName: String?
    var playerDescription: String?
    var userGames: [Game]?
    var userGameTags: [GamerTag]?
}

struct Game: Codable {
    var id: Int?
    var gameName: String?
    var gameLogo: String?
    var gameSlug: String?
    var gameImage: String
    var tierName: String?
    var startDate: String?
    var teamSize: Int?
    var leagueConsole:[GameConsol]?
    var league:[GameConsol]?
    var type: String?
    
    // By Pranay
    var status: Int?
    var gameFullName: String?
    var createdBy: Int?
    var launchDateTZ: String?
    var leagueSlug: String?
    var registrationDeadlineTZ: String?
    var creatorName: String?
    var creatorImage: String?
    // .
}

struct GameConsol: Codable {
    var id: Int?
    var gameId: Int?
    var consoleName: String?
    var leagueName: String?
    var abbrevation: String?
    var type: String?
}

struct Networks: Codable {
    var id: Int?
    var userId: Int?
    var gameId: Int?
    var title: String?
    var trackerNetworkUrl: String?
    var gameName: String?
    var gameSlug: String?
    var gameImage: String?
}

struct PlayerGames: Codable {
    var id: Int?
    var userGameId: Int?
    var userId: Int?
    var gameName: String?
    var gameSlug: String?
    var gameImage: String?
    var isLike: Int?
}
