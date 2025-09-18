//
//  Arena.swift
//  Tussly
//
//  Created by Auxano on 28/03/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import Foundation


struct LeagueRounds: Codable {
    var id: Int?
    var roundNo: String?
    var mapTitle: String?
    var gameModeTitle: String?
    var mapImage: String?
    var status: Int?
}

struct Match: Codable {
    var matchId: Int?
    var leagueId: Int?
    var matchNo: Int?
    var onlyTime: String?
    var onlyDate: String?
    var parentHomeTeamMatchNo: Int?
    var parentAwayTeamMatchNo: Int?
    var parentHomeTeamWinnerLabel: String?
    var parentAwayTeamWinnerLabel: String?
    var nextMatchTime: String?
    var nextMatchRoundLabel: String?
    var isManualUpdate: Int?
    var isEliminate: Int?
    var joinStatus: Int?
    var isRematch: Int?
    var isShowReminderPopup: Int?
    var matchDateTime: String?
    var matchDate: String?
    var matchTime: String?
    var remainTime: String?
    var previousFirestoreId: String?
    var opponent: String?
    var duration: Int?
    var homeImage: String?
    var awayImage: String?
    var homeTeamName: String?
    var awayTeamName: String?
    var homeResult: String?
    var awayResult: String?
    var homeTeamId: Int?
    var awayTeamId: Int?
    var firebaseDocumentId: String?
    var matchType: String?
    var league: LeagueSingle?
    var homeTeam: HomeTeam?
    var awayTeam: AwayTeam?
    var homeTeamPlayers: [HomeTeamPlayer]?
    var awayTeamPlayers: [HomeTeamPlayer]?
    
    var stationName : String?
    var scheduleType: String?
    var resetMatch: Int?
    var remainingMiliSeconds: Int?
    var nextScheduledMatchTimer: Int?
    var arenaMatchFinishTimer: Int?
    var isManualUpdateFromUpcoming: Int?
    var manualUpdateFromUpcomingMsg: String?
    var homePlayerCharacters: [Characters]?
    var awayPlayerCharacters: [Characters]?
    
    var chatId: String?
}

struct MatchPlayer: Codable {
    var userId: Int?
    var teamId: Int?
    var role: Int?
    var arenaEntered: Int?
    var displayName: String?
    var avatarImage: String?
    var gamerTags: String?
}

struct RoundScor: Codable {
    var id: Int?
    var homeTeamName: String?
    var awayTeamName: String?
    var homeTeamScore: Int?
    var awayTeamScore: Int?
    var homeImage: String?
    var awayImage: String?
    var roundNo: String?
}


struct GameLobby: Codable {
    var id: Int?
    var stepNo: Int?
    var lobbyContent: String?
    
}

struct HomeTeam: Codable {
    var id: Int?
    var teamSlug: String?
    var teamName: String?
    var homeImage: String?
    var isJoinAsPlayer: Int?
}

struct AwayTeam: Codable {
    var id: Int?
    var teamSlug: String?
    var teamName: String?
    var awayImage: String?
    var isJoinAsPlayer: Int?
}

struct LeagueSingle: Codable {
    var id: Int?
    var gameId: Int?
    var playerMatchSize: Int?
    var leagueName: String?
    var leagueSlug: String?
    var onlineType: String?
    var launchDate: String?
    var otherPlatform: String?
    var platforms: String?
    var gameImage: String?
    var gameBannerImage: String?
    var timeZone: String?
    var abbrevation: String?
    var profileImage: String?
    var bannerImage: String?
    var zoneName: String?
    var discription: String?
    
    var eliminationType : String?
    var isCheckInEnable: String? = "No"
}

struct HomeTeamPlayer: Codable {
    var teamId: Int?
    var matchId: Int?
    var userId: Int?
    var playerDetails: PlayerDetail?
    /// 223 - By Pranay
    var playedCharacter: [Characters]?
    /// 223 .
}

struct PlayerDetail: Codable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var displayName: String?
    var avatarImage: String?
    var isBlockForLeague: Int?
    var connectCode: String?
    
    var isCheckIn: Int? = 0
}

struct Contents: Codable {
    var characters: [Characters]?
    var stages: [Stages]?
    var starterStage: [StarterStage]?
    var counterStage: [StarterStage]?
    var arenaContents: ArenaContent?
    var leagueRules: LeagueRule?
    var arenaRules: ArenaRule?
    var regularArenaTimeSettings: RegularArena?
    var playoffArenaTimeSettings: RegularArena?
    // By Pranay
    var notificationContent: NotificationContent?
    var socialMedias: [SocialMedia]?
    var biography: String?
    var biographyLink: String?
    //.
}

struct RegularArena: Codable {
    var timeForSelectPlayerCharacter: Int?
    var timerForBanOrPickStage: Int?
    var timeBetweenRound: Int?
    var timeForSelectRPS: Int?
}

struct LeagueRule: Codable {
    var codeOfConduct: String?
    var rulesAndRegulation: String?
    var systemSetting: String?
    var showDamage: String?
    var scoreDisplay: String?
    var pausing: String?
    var underdogBoost: String?
    var launchRate: String?
    var teamAttack: String?
    var stageHazards: String?
    var stageMorph: String?
    var firstTo: String?
    var randomStage: String?
    var items: String?
    var itemsOther: String?
    var gameStage: String?
    var damageHandicap: String?
    var CPULevel: Int?
    var gameSpirits: String?
    var fsMeter: String?
    var timeLimit: String?
    var timeLimitOther: String?
    var stock: String?
    var stockOther: String?
    var stamina: Int?
    var style: String?
}

struct ArenaRule: Codable {
    var roomMusic: String?
    var arenaSpirits: String?
    var voiceChat: String?
    var amiibos: String?
    var customStages: String?
    var arenaStage: String?
    var maxPlayer: String?
    var format: String?
    var rotation: String?
    var visibility: String?
    var type: String?
}

struct ArenaContent: Codable {
    var set_your_defaults: DetailContent?
    var how_to_get_battle_arena_id: DetailContent?
    var reminder: DetailData?
    var unselect_to_select: DetailData?
    var battle_arena_id_fail: DetailData?
    var welcome_to_arena: DetailData?
    // By Pranay
    var how_to_get_battle_arena_id_non_host: DetailContent?
    var tied_damage: DetailData?
    // .
}

struct DetailContent: Codable {
    var heading: String?
    var data: [ContentData]?
}

struct DetailData: Codable {
    var heading: String?
    var data: ContentData?
}

struct ContentData: Codable {
    var title: String?
    var description: String?
}

struct HowToUseContent: Codable {
    var stepNo: String?
    var module: String?
    var description: String?
}

struct Characters: Codable {
    var id: Int?
    var name: String?
    var imageUrl: String?
    var imagePath: String?
    var icon: String?
    var defaultCharacterId: Int?
    /// 223 - By Pranay
    var characterUseCnt: Int?
    var characterImage: String?
    /// 223 .
}

struct Stages: Codable {
    var id: Int?
    var mapTitle: String?
    var mapName: String?
    var isPrimary: Int?
    var isBattleField: Int?
    var isOmega: Int?
    var imagePath: String?
    var mapImage: String?
    var matchId: Int?
    var stageId: Int?
    var teamId: Int?
    var stageName: String?
    var name: String?
    
    var playerId: Int?
}

struct StarterStage: Codable {
    var id: Int?
    var title: String?
    var stageName: String?
    var mapImage: String?
    var imagePath: String?
}

struct BanStage: Codable {
    var stageId: Int?
    var playerId: Int?
}

struct FirebaseInfo: Codable {
    var status: String?
    var playerDetails: [ArenaPlayerData]?
    var rounds: [Rounds]?
    var battelArenaId: String?
    var currentRound: Int?
    var stagePicBanPlayerId: Int?
    var bannedStages: [BanStage]?
    var disputeBy: Int?
    var matchId: Int?
    var disputeImagePath: String?
    var hostPlayerId: Int?
    var enteredScoreBy: Int?
    var weAreReadyBy: Int?
    //var isManualUpdate: Int?  //  Comment by Pranay.
    var readyToStagePickBanBy: Int? //Save round winner id if admin confirm score
    var appLozicGroupId: String?
    
    
    //Check dispute score confirm by user or admin
    var disputeConfirmBy: Int?
    var matchForfeit: Int?
    var bestWinRound: Int?
    var hostCharSelect: Int?
    var awayCharSelect: Int?
    var manualUpdate: Int?
    var matchFinish: Int?
    var banRound: Int?
    var gameStartTime: Int?
    //var gameStartTime: UInt64?
    var resetMatch: Int?
    var manualUpdateFromUpcoming: Int?
    //var previousMatchActive: Int?
    var homeBannedStages: [String: [Int]]?
    var awayBannedStages: [String: [Int]]?
    var matchFinished: Int? = 0
    var scheduleRemoved: Int? = 0
    
    
    var dictionary: [String: Any] {
        let data = (try? JSONEncoder().encode(self)) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]) ?? [:]
    }
    
    init(dictionary: [String: Any]) {
        self.status = dictionary["status"] as?String ?? ""
        self.playerDetails = dictionary["playerDetails"] as? [ArenaPlayerData]? ?? []
        self.rounds = dictionary["rounds"] as? [Rounds]? ?? []
        self.battelArenaId = dictionary["battelArenaId"] as? String ??  ""
        self.currentRound = dictionary["currentRound"] as?Int  ?? 0
        self.stagePicBanPlayerId = dictionary["stagePicBanPlayerId"] as?Int ?? 0
        self.bannedStages = dictionary["bannedStages"] as? [BanStage]? ?? []
        self.disputeBy = dictionary["disputeBy"] as?Int  ?? 0
        self.matchId = dictionary["matchId"] as?Int  ?? 0
        self.disputeImagePath = dictionary["disputeImagePath"] as?String  ?? ""
        self.hostPlayerId = dictionary["hostPlayerId"] as?Int  ?? 0
        self.enteredScoreBy = dictionary["enteredScoreBy"] as?Int  ?? 0
        self.weAreReadyBy = dictionary["weAreReadyBy"] as?Int  ?? 0
        self.manualUpdate = dictionary["manualUpdate"] as?Int  ?? 0 //  Update by Pranay.
        self.readyToStagePickBanBy = dictionary["readyToStagePickBanBy"] as?Int  ?? 0
        self.appLozicGroupId = dictionary["appLozicGroupId"] as?String  ?? ""
        
        self.disputeConfirmBy = dictionary["disputeConfirmBy"] as? Int ?? 0
        self.matchForfeit = dictionary["matchForfeit"] as? Int ?? 0
        self.bestWinRound = dictionary["bestWinRound"] as? Int ?? 0
        self.hostCharSelect = dictionary["hostCharSelect"] as? Int ?? 0
        self.awayCharSelect = dictionary["awayCharSelect"] as? Int ?? 0
        self.matchFinish = dictionary["matchFinish"] as? Int ?? 0
        self.banRound = dictionary["banRound"] as? Int ?? 0
        self.gameStartTime = dictionary["gameStartTime"] as? Int ?? 0
        //self.gameStartTime = dictionary["gameStartTime"] as? UInt64 ?? 0
        self.resetMatch = dictionary["resetMatch"] as? Int ?? 0
        self.manualUpdateFromUpcoming = dictionary["manualUpdateFromUpcoming"] as? Int ?? 0
        //self.previousMatchActive = dictionary["previousMatchActive"] as? Int ?? 0
        self.homeBannedStages = dictionary["homeBannedStages"] as? [String: [Int]] ?? [:]
        self.awayBannedStages = dictionary["awayBannedStages"] as? [String: [Int]] ?? [:]
        self.matchFinished = dictionary["matchFinished"] as? Int ?? 0
        self.scheduleRemoved = dictionary["scheduleRemoved"] as? Int ?? 0
    }
    
    enum CodingKeys: String, CodingKey, CaseIterable {
        case status = "status"
        case playerDetails = "playerDetails"
        case rounds = "rounds"
        case battelArenaId = "battelArenaId"
        case currentRound = "currentRound"
        case stagePicBanPlayerId = "stagePicBanPlayerId"
        case bannedStages = "bannedStages"
        case disputeBy = "disputeBy"
        case matchId = "matchId"
        case disputeImagePath = "disputeImagePath"
        case hostPlayerId = "hostPlayerId"
        case enteredScoreBy = "enteredScoreBy"
        case weAreReadyBy = "weAreReadyBy"
        case readyToStagePickBanBy = "readyToStagePickBanBy"
        case appLozicGroupId = "appLozicGroupId"
        
        case disputeConfirmBy = "disputeConfirmBy"
        case bestWinRound = "bestWinRound"
        case hostCharSelect = "hostCharSelect"
        case awayCharSelect = "awayCharSelect"
        case manualUpdate = "manualUpdate"
        case matchFinish = "matchFinish"
        case banRound = "banRound"
        case gameStartTime = "gameStartTime"
        case resetMatch = "resetMatch"
        case manualUpdateFromUpcoming = "manualUpdateFromUpcoming"
        //case previousMatchActive = "previousMatchActive"
        case homeBannedStages = "homeBannedStages"
        case awayBannedStages = "awayBannedStages"
        case matchFinished = "matchFinished"
        case scheduleRemoved = "scheduleRemoved"
    }
    
    static var allCases: [String] {
        return CodingKeys.allCases.map { $0.rawValue }
    }
}

struct ArenaPlayerData: Codable {
    var arenaId: Int?
    var teamId: Int?
    var playerId: Int?
    //var defaultCharacterId: Int?
    var characterId: Int?
    var arenaJoin: Int?
    var firstName: String?
    var lastName: String?
    var displayName: String?
    var teamName: String?
    var characterName: String?
    var characterImage: String?
    var readyStatus: String?
    var stages: [Int]?
    var battleInStatus: Bool?
    var characterCurrent: Bool?
    var rpc: String?
    var rpcSelected: String?
    var teamImage: String?
    var host: Int?
    var avatarImage: String?
    
    
    //if user dispute score then dispute = 1
    var dispute: Int?
    //If user clicked on "View & Accept Opponent's reported score" then set 1 else 0 if user again press on "Dispute" button
    var acceptDisputeOpponentScore: Int?
    //Update disputeScore object every time when user report score for Dispute
    var disputeScore: DisputeScore?
    var ssbmConnectProceed: Int?        // For both player clicked on proceed or not
    
    var defaultCharName: String?
    var defaultCharImage: String?
    var defaultCharId: Int?
}

struct DisputeScore: Codable {
    var team1Score: Int?
    var team2Score: Int?
    var winnerTeamId: Int?
    var disputeImagePath: String?
}

struct Rounds: Codable {
    var counterStageAvailable: Int?
    var team1Score: Int?
    var team2Score: Int?
    var winnerTeamId: Int?
    var played: Int?
    var finalStage: FinalStage?
    var roundId: Int?
    var homeCharacterId: Int?
    var awayCharacterId: Int?
}

struct FinalStage: Codable {
    var id: Int?
    var imagePath: String?
    var stageName: String?
    var playerId: Int?
}

struct LeagueInfo: Codable {
    var biography: String?
    var contactInformation: ContactInfo?
    var socialMedias: [SocialMedia]?
    var specification: Specification?
    var matchDetails: MatchDetail?
    var rulesAndRegulations: Rules?
    var hostGuide: String?
    var captainGameIds: [CaptainDetail]?
}

struct ContactInfo: Codable {
    var email: String?
    var phoneNumber: String?
    var website: String?
    var channels: [Channel]?
}

struct Channel: Codable {
    var type: String?
    var value: String?
}

struct Specification: Codable {
    var basic: Basic?
    var format: Format?
}

struct Basic: Codable {
    var startDate: String?
    var registrationEndDate: String?
    var regionName: String?
    var city: String?
    var country: String?
    var address: String?
    var timezoneName: String?
    var platforms: String?
    var otherPlatform: String?
    var onlineType: String?
    var category: String?
    var PVPSize: String?
    var hostSystem: String?
    var schedulingSystem: String?
    var tusslyUserName: String?
}

struct Format: Codable {
    var totalTeams: String?
    var divisions: String?
    var forfietedTime: String?
    var teamsInPlayoffs: Int?
    var playOffFormats: String?
}

struct MatchDetail: Codable {
    var regularSeason: RegularSeason?
    var playoffs: RegularSeason?
}

struct RegularSeason: Codable {
    var starterStages: [StarterStage]?
    var counterStages: [StarterStage]?
    var bestOfFormat: String?
    var stagePick: String?
    var stagePickFormat: String?
    var timeBetweenMatchRounds: String?
    var timeToSelectStage: String?
    var timeToBanOrPickStage: String?
    var characterBans: [Characters]?
    var omegaAndBattleFieldsStages: [Stages]?
}

struct Rules: Codable {
    var gameSettings: GameSetting?
    var system: String?
    var rules: String?
    var codeOfConduct: String?
}

struct GameSetting: Codable {
    var arenaRules: ArenaRule?
    var gameRules: LeagueRule?
}

struct CaptainDetail: Codable {
    var teamName: String?
    var captainId: Int?
    var joinBy: Int?
    var teamLogo: String?
    var captainName: String?
    var isUsedForOnlySinglePlayer: Int?
    var captainLogo: String?
    var userGameTags: [GamerTag]?
}

struct AdminInfo: Codable {
    var avatarImage: String?
    var adminId: Int?
    var userName: String?
    var displayName: String?
}


// MARK: - GetLeagueMatches
struct GetLeagueMatches: Codable {
    var match: Match?
    var redirectUrl: String?
    var registrationStatus : Int?
    var leagueMatchStatus: Int?
    var stagePickBan: String?
    var customizeScore: Int?
    var discordUrl: String?
    var isShoesCharacter: String?
    var maxCharacterLimit: Int?
    var bracketBaseUrl: String?
    var frontEndBaseUrl: String?
    var checkInRemainingTime: Int?
    var isPlayerCheckIn: Int?
}

// MARK: - PlayerStagesAndCharacters
struct PlayerStagesAndCharacters: Codable {
    var playerCharacter: Characters?
    var playerStagers: [Int]?
}

// MARK: - JoinedTournamentDetails
struct JoinedTournamentDetails: Codable {
    var userRoles: UserRole?
    var teamDetail: Team?
    var gameDetail: Game?
}

// MARK: - CustomStageCharSettings
/// charSelectByWinner -
/// 0 - Both player select character in every round.
/// 1 - Round 2 onwards only looser player select character, and winner player's character auto select which one is previous match character.
struct CustomStageCharSettings: Codable {
    var charSelectByWinner: Int?
    var stageBanSettings: StageBanSettings?
}

// MARK: - StageBanSettings
/// DSR -
/// 0 - No              - Previous bann system is disabled.
/// 1 - Yes             - Then round 2 onwards, when player go for ban stage that time player get some stage ban which oppoent player already won in previous all matches, and while player go for pick stage then get stage ban in picking player already won in all previous match and which stage oppoent player ban.
/// 2 - Modified     - Then round 2 onwards, when player go for ban stage that time player get some stage ban which oppoent player last won in previous matche, and while player go for pick stage then get stage ban in picking player already won in last match and which stage oppoent player ban.
struct StageBanSettings: Codable {
    var bestOf: Int?
    var dsr: Int?
    var roundSettings: [RoundSettings]?
    //var firstCharSelect: String?
}

// MARK: - RoundSettings
struct RoundSettings: Codable {
    var firstBanBy: String?
    var stagePickBy: String?
    var totalBanStage: Int?
    var banCount: [Int]?
}

// MARK: - GameSettings
struct GameSettings: Codable {
    var colorCode: String?
    var customId: Int?
    var gameFullName: String?
    var gameLabel: String?
    var gameLabel2: String?
    var gameName: String?
    var id: Int?
    var isTournamentHost: Int?
    var isGameSetting: Int?
    var scorePopupInfo: ScorePopupInfo?
}

// MARK: - ScorePopupInfo
struct ScorePopupInfo: Codable {
    var scoreHeader: String?
    var scoreReportSubHeader: String?
    var scoreReportMsg: String?
    var scoreTitle: String?
    var scoreConfirmSubHeader: String?
    var scoreTieMsg: String?
    var scoreDisputeMsg: String?
    var scorePercentageTieMsg: String?
    
    /// Host - Non Host Msg
    var hostMsg: String?
    var nonHostMsg: String?
    var nonHostMsg2: String?
}

// MARK: - NotificationPayload
struct NotificationPayload: Codable {
    var negativeText: String?
    var leagues: [League]?
    var isActionDone, isDetailView: Int?
    var action: String?
    var notificationID, notificationType: Int?
    var positiveText: String?

    enum CodingKeys: String, CodingKey {
        case negativeText, leagues, isActionDone, isDetailView, action
        case notificationID = "notificationId"
        case notificationType, positiveText
    }
}


// MARK: - ChatNotificationPayload
struct ChatNotificationPayload: Codable {
    var googleCFid: String?
    var gcmMessageID: String?                // was Int?
    var title: String?
    var conversationID: String?
    var body: String?
    var senderAvatar: String?
    var receiverAvatar: String?             // not in model before
    var googleCSenderID: String?            // was Int?
    var aps: Aps?
    var receiver: String?                   // was Int?
    var type: String?
    var receiverType: String?
    var sender: String?                     // was Int?
    var tag: String?                        // was Int?
    var receiverName: String?
    var googleCAE: String?                  // was Int?
    var senderName: String?
    
    enum CodingKeys: String, CodingKey {
        case googleCFid = "google.c.fid"
        case gcmMessageID = "gcm.message_id"
        case title
        case conversationID = "conversationId"
        case body, senderAvatar, receiverAvatar
        case googleCSenderID = "google.c.sender.id"
        case aps, receiver, type, receiverType, sender, tag, receiverName
        case googleCAE = "google.c.a.e"
        case senderName
    }
}

struct Aps: Codable {
    var alert: Alert?
    var category: String?
    var mutableContent: Int?
    var sound: String?
    
    enum CodingKeys: String, CodingKey {
        case alert, category
        case mutableContent = "mutable-content"
        case sound
    }
}

struct Alert: Codable {
    var body: String?
    var title: String?
}
