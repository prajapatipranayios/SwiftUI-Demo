//
//  ApiResponse.swift
//  - This class is used to manage & parse API Response

//  Tussly
//
//  Created by Auxano on 19/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import DynamicCodable

struct ApiResponse: Codable {
    var status: Int?
    var result: Response?
    var message: String
}

struct Response: Codable {
    var redirectUrl: String?
    
    var registrationStatus: Int?
    var leagueMatchStatus: Int?
    //Login
    var userDetail: User?
    var accessToken: String?
    var isVerified: Int?
    
    //Check firebase id
    var firebaseDocumentId: String?
    
    //Forgot Password
    var otp: String?
    
    //SignUp - Get GamerTags
    var gameTags: [GamerTag]?
    
    //CreatTeam
    var team: Team?
    
    //CreatTeam - Get Friend
    var friends: [Player]?
    
    //PlayerCard - Get Games
    var games : [Game]?
    var playerCard: PlayerCard?
    var baseUrl: String?
    
    var createTournamentLink: String?
    
    var receivedCount: Int?
    
    //Tracker network
    var networks : [Networks]?
    
    //Played games
    var playerGames : [PlayerGames]?
    var characters: [Characters]?
    var stages: [Stages]?
    var opposingCharacters: [Characters]?
    
    //Search Player
    var players: Player?
    
    //Search Team , Get League Detail
    var teams: [Team]?
    var gameDetail: Game?
    var userRoles: UserRole?
    var teamDetail: Team?
    var currentWeekNo: Int?
    var currentWeek: Int?
    var teamPlayers: [TeamPlayer]?
    var adminUserInfo: AdminInfo?

    //Home
    var leagues: [League]?
    var registerLeagueUrl: String?
    var activeLeagueUrl: String?
    var pastLeagueUrl: String?
    var leageInvitationCounts: Int?
    var teamInvitationCounts: Int?
    var isShowGuidline: Int?
    var isFcmTokenExpire: Int?
    
    var unreadNotificationCnt : Int?
    var feedbackUrl: String?
    var version: Version?
    var shipBookKeys: ShipBookKeys?
    
    //League Schedules
    var schedule: [Schedule]?
    var byDate: [String]?
    var maxWeekNo: Int?
    
    //League Highlight
    var videos: [Highlight]?
    
    //League Info
    var leagueInfo: LeagueInfo?
    
    //League Roster, Get Substitutes Player
    var leagueRoster: [Player]?
    var substitutePlayers: [Player]?
    
    //League Standings
    var standings: [String: Any]?
    var header: [String]?
    
    var maxCharLimit: Int?
    var playerAllCharacters: [PlayerAllCharacter]?
    
    //League Headlines
    var matchHeadlines: [Headline]?
    
    //Friend Request
    var friendRequests: [FriendRequest]?
    
    
    //League Leaderboard
    var leaderBoardResult: [String: Any]?
    var leaderBoardHeader: [String]?
    
    //League Result
    var results: [Result]?
    var playerResults: [String: Any]?
    var playerHeader: [String]?
    var average: [String: Any]?
    var roundResults: [Result]?
    var scoreInfo: ScoreInfo?
    
    // Player card result
    var playerResult: [String: Any]?
    var resultHeader: [String]?
    var careerTotal: [String: Any]?
    var resultAverage: ResultAverage?
    var filterResult: [FilterResult]?
    
    //League MVP
    var mvp:[Player]?
    var recentVoted: String?
    
    //Notification
    var unReadNotification: [UserNotification]?
    var readNotification: [UserNotification]?
    var hasMore: Int?
    
    //Team Module
    var total: [String: Any]?
    var teamMembers: [Player]?
    var teamInfo: [TeamInfo]?
    var playerInfo: [PlayerInfo]?
    var teamGames: [Game]?
    var teamRosters: [Player]?
    var teamMember: Player?
    
    //Aerna Module
    var arenaEntered: Int?
    var leagueRounds: [LeagueRounds]?
    var match: Match?
    var contents: Contents?
    var howTouseContent: [HowToUseContent]?
    var playerCharacter: Characters?
    var playerStagers: [Int]?
    
    //Tournament
    var bracketData: [BracketData]?
    var remainTime: Int?
    
    var matchType: String?
    var filterPopup: [String]?
    var myPool: String?
    var totalTeams: Int?
    var getLeagueMatches : GetLeagueMatches?
    var playerStagesAndCharacters: PlayerStagesAndCharacters?
    var joinedTournamentDetails : JoinedTournamentDetails?
    var customStageCharSettings: CustomStageCharSettings?
    var gameSetting: GameSettings?
    
    var disputeId: Int?
    
    //FIrestore response
    var fireBaseInfo: FirebaseInfo?
    var fireStoreId : String?
    
    
    var matchPlayers: [MatchPlayer]?
    
    var rounds: [LeagueRounds]?
    var roundScore: [RoundScor]?
    
    var nextMatch: Match?
    
    var status: String?
    
    var gameLobby: [GameLobby]?
    
    // Declare Round Winner
    var isRoundDeclare: Int?
    var isFinish: Int?
    
    var crossLoginUrl: String?
    
    
    enum CodingKeys: String, CodingKey {
        
        //Login
        case redirectUrl
        case registrationStatus
        case leagueMatchStatus
        
        case userDetail
        case accessToken
        case isVerified
        
        //Check firebaseid
        case firebaseDocumentId
        
        //Forgot Password
        case otp
        
        //SignUp - Get GamerTags
        case gameTags
        
        //Creat Team
        case team
        
        //Home
        case leagues
        
        case registerLeagueUrl
        case activeLeagueUrl
        case pastLeagueUrl
        case leageInvitationCounts
        case teamInvitationCounts
        case isShowGuidline
        case isFcmTokenExpire
        
        case unreadNotificationCnt
        case feedbackUrl
        case version
        case shipBookKeys
        
        
        //CreatTeam - Get Friend
        case friends
        
        //PlayerCard - Get Games
        case games
        case playerCard
        case friendRequests
        case baseUrl
        case createTournamentLink
        case receivedCount
        
        //Tracker network
        case networks
        
        //Played games
        case playerGames
        case characters
        case stages
        case opposingCharacters
        
        //Search Player
        case players
        
        //League Module
        case teams
        case gameDetail
        case userRoles
        case teamDetail
        case currentWeekNo
        case currentWeek
        case teamPlayers
        case schedule
        case maxWeekNo
        case videos
        case leagueRoster
        case substitutePlayers
        case standings
        case header
        case byDate
        case leaderBoardResult
        case leaderBoardHeader
        case results
        case playerResults
        case playerResult
        case careerTotal
        case total
        case playerHeader
        case resultHeader
        case average
        case roundResults
        case mvp
        case recentVoted
        case matchHeadlines
        case leagueInfo
        case adminUserInfo
        case resultAverage
        case filterResult
        
        case scoreInfo
        case disputeId
        case remainTime
        
        //Notification
        case unReadNotification
        case readNotification
        case hasMore
        
        //Team Module
        case teamMembers
        case teamInfo
        case playerInfo
        case teamGames
        case teamRosters
        case teamMember
        
        //Arena
        case arenaEntered
        case leagueRounds
        case match
        case contents
        case fireBaseInfo
        case playerCharacter
        case playerStagers
        
        case fireStoreId
        case maxCharLimit
        case playerAllCharacters
        
        
        case matchPlayers
        case howTouseContent
        
        case bracketData
        
        case matchType
        case filterPopup
        case myPool
        case totalTeams
        case getLeagueMatches
        case playerStagesAndCharacters
        case joinedTournamentDetails
        case customStageCharSettings
        case gameSetting
        
        
        case rounds
        case roundScore
        
        case nextMatch
        
        case status
        
        case gameLobby
        
        // Declare Round Winner
        case isRoundDeclare
        case isFinish
        
        case crossLoginUrl
        
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        redirectUrl = try values.decodeIfPresent(String.self, forKey: .redirectUrl)
        
        registrationStatus = try values.decodeIfPresent(Int.self, forKey: .registrationStatus)
        leagueMatchStatus = try values.decodeIfPresent(Int.self, forKey: .leagueMatchStatus)
        
        
        userDetail = try values.decodeIfPresent(User.self, forKey: .userDetail)
        accessToken = try values.decodeIfPresent(String.self, forKey: .accessToken)
        isVerified = try values.decodeIfPresent(Int.self, forKey: .isVerified)
        otp = try values.decodeIfPresent(String.self, forKey: .otp)
        
        firebaseDocumentId = try values.decodeIfPresent(String.self, forKey: .firebaseDocumentId)
        
        disputeId = try values.decodeIfPresent(Int.self, forKey: .disputeId)
        remainTime = try values.decodeIfPresent(Int.self, forKey: .remainTime)
        
        gameTags = try values.decodeIfPresent([GamerTag].self, forKey: .gameTags)
        team = try values.decodeIfPresent(Team.self, forKey: .team)
        friends = try values.decodeIfPresent([Player].self, forKey: .friends)
        games = try values.decodeIfPresent([Game].self, forKey: .games)
        playerCard = try values.decodeIfPresent(PlayerCard.self, forKey: .playerCard)
        baseUrl = try values.decodeIfPresent(String.self, forKey: .baseUrl)
        createTournamentLink = try values.decodeIfPresent(String.self, forKey: .createTournamentLink)
        receivedCount = try values.decodeIfPresent(Int.self, forKey: .receivedCount)
        
        networks = try values.decodeIfPresent([Networks].self, forKey: .networks)
        
        playerGames = try values.decodeIfPresent([PlayerGames].self, forKey: .playerGames)
        
        characters = try values.decodeIfPresent([Characters].self, forKey: .characters)
        stages = try values.decodeIfPresent([Stages].self, forKey: .stages)
        opposingCharacters = try values.decodeIfPresent([Characters].self, forKey: .opposingCharacters)
        
        friendRequests = try values.decodeIfPresent([FriendRequest].self, forKey: .friendRequests)
        
        players = try values.decodeIfPresent(Player.self, forKey: .players)
        teams = try values.decodeIfPresent([Team].self, forKey: .teams)
        leagues = try values.decodeIfPresent([League].self, forKey: .leagues)
        gameDetail = try values.decodeIfPresent(Game.self, forKey: .gameDetail)
        userRoles = try values.decodeIfPresent(UserRole.self, forKey: .userRoles)
        teamPlayers = try values.decodeIfPresent([TeamPlayer].self, forKey: .teamPlayers)
        
        registerLeagueUrl = try values.decodeIfPresent(String.self, forKey: .registerLeagueUrl)
        activeLeagueUrl = try values.decodeIfPresent(String.self, forKey: .activeLeagueUrl)
        pastLeagueUrl = try values.decodeIfPresent(String.self, forKey: .pastLeagueUrl)
        leageInvitationCounts = try values.decodeIfPresent(Int.self, forKey: .leageInvitationCounts)
        teamInvitationCounts = try values.decodeIfPresent(Int.self, forKey: .teamInvitationCounts)
        isShowGuidline = try values.decodeIfPresent(Int.self, forKey: .isShowGuidline)
        leagueInfo = try values.decodeIfPresent(LeagueInfo.self, forKey: .leagueInfo)
        adminUserInfo = try values.decodeIfPresent(AdminInfo.self, forKey: .adminUserInfo)
        isFcmTokenExpire = try values.decodeIfPresent(Int.self, forKey: .isFcmTokenExpire)
        
        unreadNotificationCnt = try values.decodeIfPresent(Int.self, forKey: .unreadNotificationCnt)
        feedbackUrl = try values.decodeIfPresent(String.self, forKey: .feedbackUrl)
        version = try values.decodeIfPresent(Version.self, forKey: .version)
        shipBookKeys = try values.decodeIfPresent(ShipBookKeys.self, forKey: .shipBookKeys)
        
        
        teamDetail = try values.decodeIfPresent(Team.self, forKey: .teamDetail)
        currentWeekNo = try values.decodeIfPresent(Int.self, forKey: .currentWeekNo)
        currentWeek = try values.decodeIfPresent(Int.self, forKey: .currentWeek)
        schedule = try values.decodeIfPresent([Schedule].self, forKey: .schedule)
        maxWeekNo = try values.decodeIfPresent(Int.self, forKey: .maxWeekNo)
        
        videos = try values.decodeIfPresent([Highlight].self, forKey: .videos)
        leagueRoster = try values.decodeIfPresent([Player].self, forKey: .leagueRoster)
        substitutePlayers = try values.decodeIfPresent([Player].self, forKey: .substitutePlayers)
        
        scoreInfo = try values.decodeIfPresent(ScoreInfo.self, forKey: .scoreInfo)
        
        standings = try values.decodeIfPresent([String: Any].self, forKey: .standings)
        header = try values.decodeIfPresent([String].self, forKey: .header)
        leaderBoardResult = try values.decodeIfPresent([String: Any].self, forKey: .leaderBoardResult)
        leaderBoardHeader = try values.decodeIfPresent([String].self, forKey: .leaderBoardHeader)
        byDate = try values.decodeIfPresent([String].self, forKey: .byDate)
        maxCharLimit = try values.decodeIfPresent(Int.self, forKey: .maxCharLimit)  //  By Pranay
        playerAllCharacters = try values.decodeIfPresent([PlayerAllCharacter].self, forKey: .playerAllCharacters)
        
        results = try values.decodeIfPresent([Result].self, forKey: .results)
        playerResults = try values.decodeIfPresent([String: Any].self, forKey: .playerResults)
        playerHeader = try values.decodeIfPresent([String].self, forKey: .playerHeader)
        playerResult = try values.decodeIfPresent([String: Any].self, forKey: .playerResult)
        careerTotal = try values.decodeIfPresent([String: Any].self, forKey: .careerTotal)
        resultHeader = try values.decodeIfPresent([String].self, forKey: .resultHeader)
        average = try values.decodeIfPresent([String: Any].self, forKey: .average)
        roundResults = try values.decodeIfPresent([Result].self, forKey: .roundResults)
        resultAverage = try values.decodeIfPresent(ResultAverage.self, forKey: .resultAverage)
        filterResult = try values.decodeIfPresent([FilterResult].self, forKey: .filterResult)
        
        mvp = try values.decodeIfPresent([Player].self, forKey: .mvp)
        recentVoted = try values.decodeIfPresent(String.self, forKey: .recentVoted)
        
        matchHeadlines = try values.decodeIfPresent([Headline].self, forKey: .matchHeadlines)
        
        unReadNotification = try values.decodeIfPresent([UserNotification].self, forKey: .unReadNotification)
        readNotification = try values.decodeIfPresent([UserNotification].self, forKey: .readNotification)
        hasMore = try values.decodeIfPresent(Int.self, forKey: .hasMore)
        total = try values.decodeIfPresent([String: Any].self, forKey: .total)

        teamMembers = try values.decodeIfPresent([Player].self, forKey: .teamMembers)
        teamInfo = try values.decodeIfPresent([TeamInfo].self, forKey: .teamInfo)
        playerInfo = try values.decodeIfPresent([PlayerInfo].self, forKey: .playerInfo)
        teamGames = try values.decodeIfPresent([Game].self, forKey: .teamGames)
        teamRosters = try values.decodeIfPresent([Player].self, forKey: .teamRosters)
        teamMember = try values.decodeIfPresent(Player.self, forKey: .teamMember)
        
        arenaEntered = try values.decodeIfPresent(Int.self, forKey: .arenaEntered)
        leagueRounds = try values.decodeIfPresent([LeagueRounds].self, forKey: .leagueRounds)
        contents = try values.decodeIfPresent(Contents.self, forKey: .contents)
        fireBaseInfo = try values.decodeIfPresent(FirebaseInfo.self, forKey: .fireBaseInfo)
        match = try values.decodeIfPresent(Match.self, forKey: .match)
        
        fireStoreId = try values.decodeIfPresent(String.self, forKey: .fireStoreId)
        
        
        howTouseContent = try values.decodeIfPresent([HowToUseContent].self, forKey: .howTouseContent)
        
        bracketData = try values.decodeIfPresent([BracketData].self, forKey: .bracketData)
        // By Pranay
        matchType = try values.decodeIfPresent(String.self, forKey: .matchType)
        filterPopup = try values.decodeIfPresent([String].self, forKey: .filterPopup)
        myPool = try values.decodeIfPresent(String.self, forKey: .myPool)
        totalTeams = try values.decodeIfPresent(Int.self, forKey: .totalTeams)
        getLeagueMatches = try values.decodeIfPresent(GetLeagueMatches.self, forKey: .getLeagueMatches)
        playerStagesAndCharacters = try values.decodeIfPresent(PlayerStagesAndCharacters.self, forKey: .playerStagesAndCharacters)
        joinedTournamentDetails = try values.decodeIfPresent(JoinedTournamentDetails.self, forKey: .joinedTournamentDetails)
        customStageCharSettings = try values.decodeIfPresent(CustomStageCharSettings.self, forKey: .customStageCharSettings)
        gameSetting = try values.decodeIfPresent(GameSettings.self, forKey: .gameSetting)
        
        
        rounds = try values.decodeIfPresent([LeagueRounds].self, forKey: .rounds)
        roundScore = try values.decodeIfPresent([RoundScor].self, forKey: .roundScore)
        
        nextMatch = try values.decodeIfPresent(Match.self, forKey: .nextMatch)
        
        status = try values.decodeIfPresent(String.self, forKey: .status)
        
        gameLobby = try values.decodeIfPresent([GameLobby].self, forKey: .gameLobby)
        playerCharacter = try values.decodeIfPresent(Characters.self, forKey: .playerCharacter)
        playerStagers = try values.decodeIfPresent([Int].self, forKey: .playerStagers)
        
        // Declare Round Winner
        isRoundDeclare = try values.decodeIfPresent(Int.self, forKey: .isRoundDeclare)
        isFinish = try values.decodeIfPresent(Int.self, forKey: .isFinish)
        
        crossLoginUrl = try values.decodeIfPresent(String.self, forKey: .crossLoginUrl)
    }

    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encodeIfPresent(redirectUrl, forKey: .redirectUrl)
            
            try container.encodeIfPresent(registrationStatus, forKey: .registrationStatus)
            try container.encodeIfPresent(leagueMatchStatus, forKey: .leagueMatchStatus)
            
            
            try container.encodeIfPresent(userDetail, forKey: .userDetail)
            try container.encodeIfPresent(accessToken, forKey: .accessToken)
            try container.encodeIfPresent(isVerified, forKey: .isVerified)
            try container.encodeIfPresent(otp, forKey: .otp)
            
            try container.encodeIfPresent(firebaseDocumentId, forKey: .firebaseDocumentId)
            
            try container.encodeIfPresent(disputeId, forKey: .disputeId)
            try container.encodeIfPresent(remainTime, forKey: .remainTime)
            
            try container.encodeIfPresent(gameTags, forKey: .gameTags)
            try container.encodeIfPresent(team, forKey: .team)
            try container.encodeIfPresent(friends, forKey: .friends)
            try container.encodeIfPresent(games, forKey: .games)
            try container.encodeIfPresent(playerCard, forKey: .playerCard)
            try container.encodeIfPresent(friendRequests, forKey: .friendRequests)
            try container.encodeIfPresent(baseUrl, forKey: .baseUrl)
            try container.encodeIfPresent(createTournamentLink, forKey: .createTournamentLink)
            try container.encodeIfPresent(receivedCount, forKey: .receivedCount)
            
            try container.encodeIfPresent(networks, forKey: .networks)
            try container.encodeIfPresent(playerGames, forKey: .playerGames)
            
            try container.encodeIfPresent(characters, forKey: .characters)
            try container.encodeIfPresent(stages, forKey: .stages)
            try container.encodeIfPresent(opposingCharacters, forKey: .opposingCharacters)
            
            try container.encodeIfPresent(players, forKey: .players)
            try container.encodeIfPresent(teams, forKey: .teams)
            try container.encodeIfPresent(leagues, forKey: .leagues)
            try container.encodeIfPresent(gameDetail, forKey: .gameDetail)
            try container.encodeIfPresent(userRoles, forKey: .userRoles)
            try container.encodeIfPresent(leagueInfo, forKey: .leagueInfo)
            try container.encodeIfPresent(adminUserInfo, forKey: .adminUserInfo)
            try container.encodeIfPresent(teamPlayers, forKey: .teamPlayers)
            
            try container.encodeIfPresent(registerLeagueUrl, forKey: .registerLeagueUrl)
            try container.encodeIfPresent(activeLeagueUrl, forKey: .activeLeagueUrl)
            try container.encodeIfPresent(pastLeagueUrl, forKey: .pastLeagueUrl)
            try container.encodeIfPresent(leageInvitationCounts, forKey: .leageInvitationCounts)
            try container.encodeIfPresent(teamInvitationCounts, forKey: .teamInvitationCounts)
            try container.encodeIfPresent(isShowGuidline, forKey: .isShowGuidline)
            try container.encodeIfPresent(isFcmTokenExpire, forKey: .isFcmTokenExpire)
            
            try container.encodeIfPresent(unreadNotificationCnt, forKey: .unreadNotificationCnt)
            try container.encodeIfPresent(feedbackUrl, forKey: .feedbackUrl)
            try container.encodeIfPresent(version, forKey: .version)
            try container.encodeIfPresent(shipBookKeys, forKey: .shipBookKeys)
            
            
            try container.encodeIfPresent(scoreInfo, forKey: .scoreInfo)
            
            try container.encodeIfPresent(teamDetail, forKey: .teamDetail)
            try container.encodeIfPresent(currentWeekNo, forKey: .currentWeekNo)
            try container.encodeIfPresent(currentWeek, forKey: .currentWeek)
            try container.encodeIfPresent(schedule, forKey: .schedule)
            try container.encodeIfPresent(maxWeekNo, forKey: .maxWeekNo)
            
            try container.encodeIfPresent(videos, forKey: .videos)
            try container.encodeIfPresent(leagueRoster, forKey: .leagueRoster)
            try container.encodeIfPresent(substitutePlayers, forKey: .substitutePlayers)
            
            try container.encodeIfPresent(standings, forKey: .standings)
            try container.encodeIfPresent(header, forKey: .header)
            try container.encodeIfPresent(leaderBoardResult, forKey: .leaderBoardResult)
            try container.encodeIfPresent(leaderBoardHeader, forKey: .leaderBoardHeader)
            try container.encodeIfPresent(byDate, forKey: .byDate)
            try container.encodeIfPresent(maxCharLimit, forKey: .maxCharLimit)
            try container.encodeIfPresent(playerAllCharacters, forKey: .playerAllCharacters)
            
            try container.encodeIfPresent(results, forKey: .results)
            try container.encodeIfPresent(playerResults, forKey: .playerResults)
            try container.encodeIfPresent(careerTotal, forKey: .careerTotal)
            try container.encodeIfPresent(playerHeader, forKey: .playerHeader)
            try container.encodeIfPresent(playerResult, forKey: .playerResult)
            try container.encodeIfPresent(resultHeader, forKey: .resultHeader)
            try container.encodeIfPresent(average, forKey: .average)
            try container.encodeIfPresent(roundResults, forKey: .roundResults)
            try container.encodeIfPresent(resultAverage, forKey: .resultAverage)
            try container.encodeIfPresent(filterResult, forKey: .filterResult)
            
            try container.encodeIfPresent(playerCharacter, forKey: .playerCharacter)
            try container.encodeIfPresent(playerStagers, forKey: .playerStagers)
            
            try container.encodeIfPresent(mvp, forKey: .mvp)
            try container.encodeIfPresent(recentVoted, forKey: .recentVoted)
            try container.encodeIfPresent(matchHeadlines, forKey: .matchHeadlines)
            try container.encodeIfPresent(total, forKey: .total)
            
            try container.encodeIfPresent(unReadNotification, forKey: .unReadNotification)
            try container.encodeIfPresent(readNotification, forKey: .readNotification)
            try container.encodeIfPresent(hasMore, forKey: .hasMore)
            
            try container.encodeIfPresent(teamMembers, forKey: .teamMembers)
            try container.encodeIfPresent(teamInfo, forKey: .teamInfo)
            try container.encodeIfPresent(playerInfo, forKey: .playerInfo)
            try container.encodeIfPresent(teamGames, forKey: .teamGames)
            try container.encodeIfPresent(teamRosters, forKey: .teamRosters)
            try container.encodeIfPresent(teamMember, forKey: .teamMember)
            
            try container.encodeIfPresent(arenaEntered, forKey: .arenaEntered)
            try container.encodeIfPresent(leagueRounds, forKey: .leagueRounds)
            try container.encodeIfPresent(match, forKey: .match)
            try container.encodeIfPresent(contents, forKey: .contents)
            try container.encodeIfPresent(fireBaseInfo, forKey: .fireBaseInfo)
            try container.encodeIfPresent(fireStoreId, forKey: .fireStoreId)
            
            try container.encodeIfPresent(howTouseContent, forKey: .howTouseContent)
            
            try container.encodeIfPresent(bracketData, forKey: .bracketData)
            
            try container.encodeIfPresent(matchType, forKey: .matchType)
            try container.encodeIfPresent(filterPopup, forKey: .filterPopup)
            try container.encodeIfPresent(myPool, forKey: .myPool)
            try container.encodeIfPresent(totalTeams, forKey: .totalTeams)
            try container.encodeIfPresent(getLeagueMatches, forKey: .getLeagueMatches)
            try container.encodeIfPresent(playerStagesAndCharacters, forKey: .playerStagesAndCharacters)
            try container.encodeIfPresent(joinedTournamentDetails, forKey: .joinedTournamentDetails)
            try container.encodeIfPresent(customStageCharSettings, forKey: .customStageCharSettings)
            try container.encodeIfPresent(gameSetting, forKey: .gameSetting)
            
            
            try container.encodeIfPresent(rounds, forKey: .rounds)
            try container.encodeIfPresent(roundScore, forKey: .roundScore)
            try container.encodeIfPresent(nextMatch, forKey: .nextMatch)
            
            try container.encodeIfPresent(status, forKey: .status)
            
            try container.encodeIfPresent(gameLobby, forKey: .gameLobby)
            
            // Declare Round Winner
            try container.encodeIfPresent(isRoundDeclare, forKey: .isRoundDeclare)
            try container.encodeIfPresent(isFinish, forKey: .isFinish)
            
            try container.encodeIfPresent(crossLoginUrl, forKey: .crossLoginUrl)
        }
        catch let err {
            print(err)
        }
    }
}
