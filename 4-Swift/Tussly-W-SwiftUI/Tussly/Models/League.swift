//
//  League.swift
//  - Describes League & related information

//  Tussly
//
//  Created by Auxano on 30/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

struct UserRole: Codable {
    var id: Int?
    var role: String?
    var canJoinTeam: Int?
    var canLeaveTeam: Int?
    var canPostVideo: Int?
    var canDeleteOwnVideo: Int?
    var canCreateGroupChat: Int?
    var canInvitePlayer: Int?
    var canJoinLeague: Int?
    var canRecruiting: Int?
    var canScrims: Int?
    var canEditTeamPage: Int?
    var canDeleteVideo: Int?
    var canMakeAdmin: Int?
    var canMakeCaptain: Int?
    var canCloseTeam: Int?
    var canVoteMvp: Int?
    var canManageRoster: Int?
    var canRemoveMember: Int?
    var canRemoveAdmin: Int?
    var canRemoveCaptain: Int?
    var canChangeOwner: Int?
    var canAdminTools: Int?
    var canCreateEvent: Int?
    var createdAt: String?
    var updatedAt: String?
    
    // By Pranay
    var joinStatus: Int?
    // .
}

struct Schedule: Codable {
    var id: Int?
    var homeTeamId: Int?
    var awayTeamId: Int?
    var homeTeamName: String?
    var awayTeamName: String?
    var matchDate: String?
    var matchTime: String?
    var matchType: String?
    var homeTeamLogoImage: String?
    var awayTeamLogoImage: String?
    var leagueWeekNo: Int?
}


struct Highlight: Codable {
    var id: Int
    var userId: Int
    var videoLink: String
    var thumbnail: String
    var videoType: String
    var videoCaption: String
    var duration: String
    var weekNo: Int
    var displayName: String
    var viewCount: String
    var dateTime: String
    
}

struct Result: Codable {
    var id: Int?
    var homeTeamId: Int?
    var awayTeamId: Int?
    var homeTeamName: String?
    var awayTeamName: String?
    var matchType: String?
    var homeTeamLogoImage: String?
    var awayTeamLogoImage: String?
    var leagueWeekNo: Int?
    var homeTeamRoundWin: Int?
    var awayTeamRoundWin: Int?
//    var homeTeamScore: Int
//    var awayTeamScore: Int
    var tiedRound: Int?
    var decideBy: String?
}

struct League: Codable {
    var gameName: String?
    var gameId: Int
    var gameImage: String?
    var profileImage: String?
    var abbrevation: String?
    var weekDays: String?
    var id: Int
    var leagueName: String?
    var status: Int
    var bannerImage: String?
    var leagueMatch: LeagueMatch?
    var type: String?
    
    // By Pranay    -   new var for league tournament search
    var leagueId: Int?
    var leagueSlug: String?
    var joinStatus: Int?
    //let leagueName: String?
    var onlineType: String?
    var launchDate: String?
    var playerMatchSize: Int?
    var prizePool: String?
    //let status: Int?
    var isEntryPaid: Int?
    var totalEntryFee: String?
    var platforms: String?
    var otherPlatform: String?
    var entryFee: Int?
    var leagueType: String?
    var accessType: String?
    //let gameImage: String?
    var gameBannerImage: String?
    //let gameName: String?
    var gameSlug: String?
    var region: String?
    var teamSize: String?
    var logo: String?
    var bannerImageForWebsite: String?
    var registrationDeadlineTZ: String?
    var launchDateTZ: String?
    // .
}

struct LeagueMatch: Codable {
    var id: Int?
    var matchNo: Int?
    var awayTeamId: Int?
    var homeTeamId: Int?
    var matchDate: String?
    var matchTime: String?
    var leagueId: Int?
    var teamId: Int?
    var status: Int?
    var winnerLabel: String?
    var teamLogo: String?
    var teamName: String?
    
    // By Pranay
    var stationName : String?
    var displayName : String?
    //.
}

struct ScoreInfo: Codable {
    var id: Int?
    var homeTeamRoundWin: Int?
    var awayTeamRoundWin: Int?
    var homeUserName: String?
    var awayUserName: String?
    var homeUserLogo: String?
    var awayUserLogo: String?
    var rounds: [Boxscore]?
}

struct Boxscore: Codable {
    var matchId: Int?
    var awayCharName: String?
    var homeCharName:String?
    var homeCharId: Int?
    var awayCharId: Int?
    var winnerTeamId: Int?
    var homeCharLogo: String?
    var awayCharLogo: String?
    var isHomeWinner: Int?
    var isAwayWinner: Int?
    var awayTeamId: Int?
    var homeTeamId: Int?
    var homeTeamScore: Int?
    var awayTeamScore: Int?
    var stageName: String?
    var stageImage: String?
}

struct Headline: Codable {
    var id: Int
    var content: String
    var weekNo: Int
}

struct SocialMedia: Codable {
    var type: String?
    var value: String?
    var imageUrl: String?
}

struct LeagueSchedule: Codable {
    var id: Int
    var day: String
    var time: String
}

struct BracketData: Codable {
    var tabName: String?
    var data: [BracketDetail]?
    
    // By Pranay
    var bracketType : String?
    //.
}

struct BracketDetail: Codable {
    var matchNo: Int?
    var id: Int
    var matchStatus: Int?
    var onlyDate: String?
    var onlyTime: String?
    var parentHomeTeamMatchNo: Int?
    var parentAwayTeamMatchNo: Int?
    var leagueId: Int?
    var homeTeamId: Int?
    var awayTeamId: Int?
    var matchDateTime: String?
    var matchTime: String?
    var isBye: Int?
    var roundLabel: String?
    var isMyGame: String?
    var awayTeamScore: Int?
    var homeTeamScore: Int?
    var parentHomeTeamWinnerLabel: String?
    var parentAwayTeamWinnerLabel: String?
    var isPlayed: Int?
    var homeTeamSeedNumber: Int?
    var awayTeamSeedNumber: Int?
    var decideBy: String?
    var homeTeam: Home?
    var awayTeam: Home?
    var homeTeamRoundWin: Int?
    var awayTeamRoundWin: Int?
    
    // By Pranay
    var poolType: String?
    var bracketType: String?
    var roundType: String?
    var poolTypeLabel: String?
    var isShowBoxScore: Int?
    var stationName: String?
    //.
}

struct Home: Codable {
    var id: Int
    var userId: Int?
    var userName: String?
    var isJoinAsPlayer: Int?
    var lastName: String?
    var teamName: String?
    var firstName: String?
    var teamSlug: String?
    var homeImage: String?
    var awayImage: String?
    
    var displayName: String?
}

// By Pranay
struct filterPoolBracket: Codable {
    var poolType: String?
    var poolTypeLabel: String?
    var myPool: Bool? = false
}

// MARK: - Version
struct Version: Codable {
    var android: String?
    var ios: String?
    var forceUpdate: String?
    var iosForceUpdate: String?
    var iosNavigationUrl: String?
}

// MARK: - ShipBookKeys
struct ShipBookKeys: Codable {
    var ios: Keys?
    var android: Keys?
}

// MARK: - Keys
struct Keys: Codable {
    var appId: String?
    var appKey: String?
}
