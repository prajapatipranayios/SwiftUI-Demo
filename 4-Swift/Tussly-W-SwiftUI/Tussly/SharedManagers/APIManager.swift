//
//  APIManager.swift
//  - Methods required to make API calls and to handle API Response

//  Tussly
//
//  Created by Jaimesh Patel on 15/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import Foundation

//let BASE_HTTP_URL = "https://tussly.com/"
//let HTTP_URL = "https://api.tussly.com/"

let BASE_HTTP_URL = "https://uat.tussly.com/"
let HTTP_URL = "https://uat.tussly.com/tussly-backend/public/"          //  By Pranay UAT url - 071120231725

//let BASE_HTTP_URL = "http://14.99.147.156:8585/"       //  By Pranay new - 280620221145
//let HTTP_URL = "http://14.99.147.156:8585/tussly-backend/public/"       //  By Pranay new - 280620221145

// Kishan D
//let BASE_HTTP_URL = "http://192.168.2.77:8000/"
//let HTTP_URL = "http://192.168.2.77:8000/"


let BASE_URL = HTTP_URL + "api/v1/"

enum HTTPMethod: String {
    // Standard
    case get     = "GET"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
    case patch   = "PATCH"
    case head    = "HEAD"
    case options = "OPTIONS"
    case trace   = "TRACE"
    case connect = "CONNECT"

    // Rare / non-standard
    case link    = "LINK"
    case unlink  = "UNLINK"
    case purge   = "PURGE"
    
    // WebDAV
    case copy     = "COPY"
    case move     = "MOVE"
    case lock     = "LOCK"
    case unlock   = "UNLOCK"
    case propfind = "PROPFIND"
    case mkcol    = "MKCOL"
    case report   = "REPORT"
    case search   = "SEARCH"
}

enum AuthType {
    case bearer(token: String)                // Authorization: Bearer <token>
    case basic(username: String, password: String) // Authorization: Basic base64
    case apiKeyHeader(name: String, value: String) // x-api-key: <token>
    case queryParam(name: String, value: String)   // ?key=value
    case cookie(name: String, value: String)       // Cookie: key=value
    case none
}

enum OptionalResult<T> {
    case success(T?)
    case failure(Error?)
}




class APIManager {
    
    private init() {
    }
    
    static var sharedManager = APIManager() 
    var authToken: String = ""
    var user: User?
    var myTeamId = 0
    var isAppResigned = 0
    var isAppActived = 0
    var isReminderOpen = 0
    var registerLeagueUrl: String = ""
    var activeLeagueUrl: String = ""
    var pastLeagueUrl: String = ""
    var guideLine: Int = 0
    var match: Match?
    var firebaseId: String?
    var content: Contents?
    var leagueInfo: LeagueInfo?
    var arrDefaultChar = [Any]()
    var currentRound = 0
    var myPlayerIndex = 0
    var timer = Timer()
    var timerRPC = Timer()
    var timerPopup = Timer()
    var leagueType = ""
    var adminId = 0
    
    var gameId : Int = 0
    var eliminationType : String = ""
    let timezone : [String : String] = ["timeZoneName" : "", "timeZoneOffSet" : (TimeZone.current).offsetFromGMT()]
    var playerData: PlayerData?
    var isNotificationClick : Bool = false
    var previousMatch: Match?
    var customStageCharSettings : CustomStageCharSettings?
    var stagePickBan : String?
    var customizeScore: Int? = 0
    var gameSettings: GameSettings?
    var appVersion: Version?
    var isMatchRefresh: Bool = true
    var nextScheduledMatchTimer: Int = 10
    var arenaMatchFinishTimer: Int = 5
    var isManualUpdateFromUpcoming: Int = 0
    var isShoesCharacter: String?
    var maxCharacterLimit: Int?
    
    var isNextMatch: Bool = false
    var tournamentDetail : League?
    var isArenaTabOpen: Bool = false
    var baseUrl: String = BASE_HTTP_URL
    var isPlayerCardOpen: Bool = false
    var isPlayerReportsTabOpen: Bool = false
    var isForChatNotification: Bool = false
    var isMatchForfeit: Bool = false
    var isMatchForfeitByMe: Bool = false
    
    // Chat
    var strChatUserId: String = ""
    var intUnreadChatCount: Int = 0
    var chatNotificationPayload: ChatNotificationPayload?
    var isMainTabTap: Bool = false
    var chatActiveConversationId: String = ""
    var strNotificationAction: String = ""
    
    
    
    // User Authentication
    let GET_LEAGUE_LINK                     = BASE_URL + "getLeagueLink"
    let LOGIN                               = BASE_URL + "login"
    let SOCIAL_LOGIN                        = BASE_URL + "socialLogin"
    //let GET_USER_DETAIL                     = BASE_URL + "getUserDetail"
    let GET_USER_DETAIL                     = BASE_URL + "getUserDetail2"   //  Added by Pranay.
    let SIGNUP                              = BASE_URL + "signUp"
    let FORGOT_PASSWORD                     = BASE_URL + "forgotPassword"
    let VERIFY_OTP                          = BASE_URL + "verifyOtp"
    let RESENT_OTP                          = BASE_URL + "resendOtp"
    let RESET_PASSWORD                      = BASE_URL + "resetPassword"
    let LOGOUT                              = BASE_URL + "logout"
    let DELETE_ACCOUNT                      = BASE_URL + "deleteAccount"
    
    let GET_GAMER_TAGS                      = BASE_URL + "getGameTags"
    let GET_PLAYER_GAME_TAGS                = BASE_URL + "getPlayerGameTags"
    let CREATE_TEAM                         = BASE_URL + "teamCreate"
    let SAVE_PLAYER_CARD                    = BASE_URL + "savePlayerCard"
    let GET_PLAYER_CARD                     = BASE_URL + "getPlayerCard"
    let UPLOAD_IMAGE                        = BASE_URL + "uploadImage"
    let GET_FRIENDS                         = BASE_URL + "getFriends"
    let GET_GAMES                           = BASE_URL + "getGames"
    let EDIT_PROFILE                        = BASE_URL + "editProfile"
    let CHANGE_PASSWORD                     = BASE_URL + "changePassword"
    let SEARCH_PLAYER                       = BASE_URL + "searchPlayer"
    let FRIEND_REQUEST                      = BASE_URL + "friendRequest"
    let SEARCH_TEAM                         = BASE_URL + "searchTeams"
    let TEAM_JOIN_REQUEST                   = BASE_URL + "teamJoinRequest"
    let CANCEL_FRIEND_REQUEST               = BASE_URL + "cancelFriendRequest"
    let CANCEL_TEAM_REQUEST                 = BASE_URL + "cancelTeamJoinRequest"
    
    let SEARCH_LEAGUE_TOURNAMENT            = BASE_URL + "getLeagues"
    let GET_STATIC_CONTENTS                 = BASE_URL + "get-static-contents"
    let UPDATE_FCM_TOKEN                    = BASE_URL + "update-fcm-token"
    
    // League Module
    let GET_LEAGUE_MATCHES                  = BASE_URL + "getLeagueMatches"
    let GET_LEAGUE_DETAIL                   = BASE_URL + "getJoinedLeagueDetails"
    let GET_LEAGUE_STANDING                 = BASE_URL + "getLeagueStandings"
    let GET_TOURNAMENT_LEADERBOARD          = BASE_URL + "getTournamentLeaderBoard"
    let GET_LEAGUE_HEADLINES                = BASE_URL + "getHeadLines"
    let GET_LEAGUE_SCHEDULE                 = BASE_URL + "getLeagueSchedules"
    let GET_VIDEOS                          = BASE_URL + "getVideos"
    let DELETE_VIDEOS                       = BASE_URL + "deleteVideo"
    let UPLOAD_VIDEO                        = BASE_URL + "uploadVideo"
    let GET_ARENA_CONTENT                   = BASE_URL + "getArenaContent"
    let GAME_CONTENT                        = BASE_URL + "howToUseContentGameWise"
    let SET_DEFAULT_STAGE                   = BASE_URL + "setDefaultStage"
    let SET_DEFAULT_CHARACTER               = BASE_URL + "setDefaultCharacter"
    let SAVE_FIRESTORE_ID                   = BASE_URL + "saveFireStoreId"
    let CHECK_FIREBASE_ID                   = BASE_URL + "checkMatchFirebaseIdAlreadyStored"
    let GET_LEAGUE_INFO                     = BASE_URL + "getPlayerLeagueInfo"
    
    let GET_TOURNAMENT_CONTENT              = BASE_URL + "get-tournament-content"
    let SEND_DISPUTE_NOTIFICATION           = BASE_URL + "send-dispute-notification"
    let GET_CHARACTER_LEADERBOARD           = BASE_URL + "getLeagueCharacterLeaderboards"
    let GET_PLAYER_CHARACTER                = BASE_URL + "getPlayerCharacter"
    let REDIRECT_TO_ARENA_INFO              = BASE_URL + "redirect-to-arena-info"
    let CHECK_IN                            = BASE_URL + "check-in"
    
    
    let GET_LEAGUE_ROSTER                   = BASE_URL + "getLeagueRoster"
    let CHANGE_LEAGUE_PLAYER_ROLE           = BASE_URL + "changeLeaguePlayerRole"
    let SWAP_LEAGUE_PLAYERS                 = BASE_URL + "swapLeaguePlayers"
    let ADD_SUBSTITUTES                     = BASE_URL + "addSubstitutes"
    let GET_SUBSTITUTES_PLAYER              = BASE_URL + "getSubstitutePlayers"
    let GET_RECENT_RESULT                   = BASE_URL + "getLeagueResult"
    let GET_BOX_SCOR_RESULT                 = BASE_URL + "getBoxScoreResult"
    let GET_MATCH_SCOR_INFO                 = BASE_URL + "getMatchScoreInfo"
    let GET_TEAM_RESULT                     = BASE_URL + "get-team-result"
    let GET_TEAM_PLAYER_RESULT              = BASE_URL + "get-team-player-result"
    let GET_LEAGUE_LEADERBOARD              = BASE_URL + "getLeagueLeaderBoard"
    
    let GET_MVP                             = BASE_URL + "getMvp"
    let GET_MVP_PLAYER                      = BASE_URL + "getMvpPlayers"
    let VOTE_MVP                            = BASE_URL + "voteMvp"
    //let GET_HOME_DATA                       = BASE_URL + "getHomeData"
    let GET_HOME_DATA                       = BASE_URL + "getHomeData2"   //  Added by Pranay.
    
    let GET_NOTIFICATION                    = BASE_URL + "getNotificationList"
    let LIKE_DISLIKE_NOTIFICATION           = BASE_URL + "likeDislikeNotification"
    let REMOVE_NOTIFICATION                 = BASE_URL + "removeNotification"
    let NOTIFICATION_ACTION                 = BASE_URL + "notificationAction"
    let DECLARE_ROUND_WINNER                = BASE_URL + "declareRoundWinner"
    let DISPUTE_ROUND                       = BASE_URL + "disputeRound"
    
    //Team Module
    let EDIT_VIDEO                          = BASE_URL + "editVideo"
    let EDIT_TEAM                           = BASE_URL + "editTeam"
    let CHANGE_TEAM_ROLE                    = BASE_URL + "changeTeamRole"
    let GET_ALL_TEAMS                       = BASE_URL + "getTeams"
    let GET_TEAM_PAGE_DETAIL                = BASE_URL + "getTeamPageDetail"
    let DELETE_MEMBER                       = BASE_URL + "removeTeamMember"
    let GET_TEAM_MEMBER                     = BASE_URL + "getTeamMember"
    let CLOSE_TEAM                          = BASE_URL + "closeTeam"
    let GET_TEAM_GAME_RESULT                = BASE_URL + "getTeamGameResult"
    let INVITE_TEAM_MEMBER                  = BASE_URL + "teamMemberInvite"
    let GET_TEAM_GAME                       = BASE_URL + "getTeamGames"
    let GET_TEAM_ROSTER                     = BASE_URL + "getTeamRosters"
    let LEAVE_TEAM                          = BASE_URL + "leaveTeam"
    let GET_TEAM_PLAYER_FILTER              = BASE_URL + "get-team-player-career-filter"
    let GET_TEAM_PLAYER_DETAIL              = BASE_URL + "get-team-player-career-details"
    let GET_TEAM_DETAIL                     = BASE_URL + "getTeamDetail"
    
    // Player Card Module

    let GET_PLAYERCARD_GAME                 = BASE_URL + "getPlayerGamesLeague"
    let GET_FRIEND_REQUEST                  = BASE_URL + "getFriendRequests"
    let GET_PLAYER_RESULT                   = BASE_URL + "getPlayerCardResultNew"
    let GET_TRACKER_NETWORK                 = BASE_URL + "getGameTrackerNetwork"
    let REMOVE_TRACKER_NETWORK              = BASE_URL + "removeGameTrackerNetwork"
    let ADD_EDIT_TRACKER_NETWORK            = BASE_URL + "addEditGameTrackerNetwork"
    let GET_PLAYER_GAME                     = BASE_URL + "getPlayerGame"
    let REMOVE_PLAYER_GAME                  = BASE_URL + "removePlayerGame"
    let SAVE_PLAYER_GAME                    = BASE_URL + "savePlayerGame"
    let GET_PLAYER_CARD_FILTER              = BASE_URL + "getPlayerCardResultFilters"
    let GET_PLAYERCARD_RESULT_CAREER        = BASE_URL + "getPlayerCardResultCareerDetail"
    let REMOVE_FRIEND                       = BASE_URL + "removeFriend"
    
    //Arena Module
    
    let GET_ARENA_DETAIL                    = BASE_URL + "getArenaMapDetails"
    let GET_ARENA_PLAYER_DETAIL             = BASE_URL + "getArenaPlayerDetails"
    let ENTER_ARENA                         = BASE_URL + "enterArena"
    let GET_ARENA_RESULT                    = BASE_URL + "getArenaResult"
    let GET_ARENA_NEXT_MATCH                = BASE_URL + "getArenaNextGame"
    let UPLOAD_OCR_IMAGE                    = BASE_URL + "uploadOcrImage"
    let GET_OCR_RESULT_STATUS               = BASE_URL + "getOcrResultStatus"
    let GET_LOBY_SETUP                      = BASE_URL + "getGameLobby"
    let UPDATE_GAMER_TAG                    = BASE_URL + "updateGamerTags"
    let GET_FRIEND_COUNT                    = BASE_URL + "getFriendCount"
    let GET_TOURNAMENT_BRACKET              = BASE_URL + "getTournamentBracketInfo"
    let GET_ROUND_REMAIN_TIME               = BASE_URL + "getRoundRemainTime"
    let ARENA_REMINDER                      = BASE_URL + "arena-reminder-popup"
    let GET_PLAYER_STAGE_CHARACTER          = BASE_URL + "getPlayerStagesAndCharacters"
    let START_MATCH                         = BASE_URL + "start-match"
    let DECLARE_FORFEIT_TEAM                = BASE_URL + "declareForFeitTeam"
    
    
    // For Chat
    let ADD_ADMIN_TO_GROUP                  = BASE_URL + "add-admin-to-group"
    
    // MARK: - Cross Login
    let CROSS_PLATFORM_TOKEN                = BASE_URL + "cross-platform-token"
    
    
    
    // MARK: -  GET | POST | PUT | DELETE Data
    
    func sendRequest<T: Decodable>(
        url: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        auth: AuthType = .none,
        completion: @escaping (OptionalResult<T>) -> Void
    ) {
        callData1(url: url, parameters: parameters, method: method, auth: auth, completion: completion)
    }
    
    
    func getData<T: Decodable>(url: String, parameters: Dictionary<String, Any>?, completion:@escaping (T?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.callData(URL: url, PARAMS: parameters, METHOD_TYPE: "GET", COMPLETION: completion)
        }
    }
    
    func postData<T: Decodable>(url: String, parameters: Dictionary<String, Any>?, completion:@escaping (T?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.callData(URL: url, PARAMS: parameters, METHOD_TYPE: "POST", COMPLETION: completion)
        }
    }
    
    func putData<T: Decodable>(url: String, parameters: Dictionary<String, Any>, methodType: String, completion:@escaping (T?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.callData(URL: url, PARAMS: parameters, METHOD_TYPE: "PUT", COMPLETION: completion)
        }
    }
    
    func deleteData<T: Decodable>(url: String, parameters: Dictionary<String, Any>, completion:@escaping (T?, Error?) -> ()) {
        DispatchQueue.global(qos: .background).async {
            self.callData(URL: url, PARAMS: parameters, METHOD_TYPE: "DELETE", COMPLETION: completion)
        }
    }
    
    fileprivate func callData<T: Decodable>(URL url: String, PARAMS parameters: Dictionary<String, Any>?, METHOD_TYPE methodType: String, COMPLETION completion: @escaping (T?, Error?) -> ()) {
        let url1 = URL(string: url)
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        
        var request = URLRequest(url: url1!)
        request.httpMethod = methodType
        request.timeoutInterval = 60
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        
        print("Auth Token --> " + authToken)
        request.cachePolicy = .reloadIgnoringCacheData
        
        let params = parameters
        if methodType != "GET" {
            if params != nil {
                let theJSONData = try? JSONSerialization.data(withJSONObject: params!, options: JSONSerialization.WritingOptions.init(rawValue: 0))
                let JsonString = String.init(data: theJSONData!, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
                
                print("json : \(JsonString!)")
                request.httpBody = JsonString!.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue), allowLossyConversion:true)
            }
        }
        
        print(URLRequest(url: url1!))
        let task = session.dataTask(with: request, completionHandler:{
            (data, response, error) in
            if error == nil {
                guard let data = data else { return }
                do {
                    let jsonDecoder = JSONDecoder()
                    let jsonResponse = try JSONSerialization.jsonObject(with:
                                                   data, options: [])
                    print(jsonResponse)
                    let dataReceived = try jsonDecoder.decode(T.self, from: data)
                    completion(dataReceived,error)
                } catch let jsonErr {
                    print(jsonErr)
                    completion( nil,jsonErr)
                }
            } else {
                completion( nil,error)
            }
        })
        task.resume()
    }
    
    
    fileprivate func callData1<T: Decodable>(
        url: String,
        parameters: [String: Any]?,
        method: HTTPMethod,
        auth: AuthType = .none,
        completion: @escaping (OptionalResult<T>) -> Void
    ) {
        guard let url1 = URL(string: url) else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url1)
        request.httpMethod = method.rawValue
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        if !(method == .get || method == .head), let params = parameters {
            request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let data = data, !data.isEmpty else {
                completion(.success(nil))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decoded))
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    

    private func applyAuth(_ auth: AuthType, request: inout URLRequest, url: inout String) {
        switch auth {
        case .queryParam(let name, let value):
            url += url.contains("?") ? "&\(name)=\(value)" : "?\(name)=\(value)"
            
        case .bearer(let token):
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            
        case .basic(let username, let password):
            let loginString = "\(username):\(password)"
            if let loginData = loginString.data(using: .utf8) {
                let base64 = loginData.base64EncodedString()
                request.setValue("Basic \(base64)", forHTTPHeaderField: "Authorization")
            }
            
        case .apiKeyHeader(let name, let value):
            request.setValue(value, forHTTPHeaderField: name)
            
        case .cookie(let name, let value):
            request.setValue("\(name)=\(value)", forHTTPHeaderField: "Cookie")
            
        case .none:
            break
        }
    }

    
    
    typealias completionBlock = (Bool, Dictionary<String, Any>?, String?) -> Void
    
    func getYoutubeData(url: String, parameters: Dictionary<String, Any>?, completion:@escaping completionBlock)
    {
        DispatchQueue.global(qos: .background).async { 
            self.callDataYoutube(URL: url, PARAMS: parameters, METHOD_TYPE: "GET", COMPLETION: completion)
        }
    }
    
    fileprivate func callDataYoutube(URL url: String, PARAMS parameters: Dictionary<String, Any>?, METHOD_TYPE methodType: String, COMPLETION completion: @escaping completionBlock)
    {
        let url1 = URL(string: url)
        let config = URLSessionConfiguration.default // Session Configuration
        let session = URLSession(configuration: config) // Load configuration into Session
        
        var request = URLRequest(url: url1!)
        request.httpMethod = methodType
        request.timeoutInterval = 60
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringCacheData
        
        let task = session.dataTask(with: request, completionHandler:{
            (data, response, error) in
            if error == nil {
                do {
                    let jsonDict = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers)
                    let dictResponse = jsonDict as! Dictionary<String, Any>
                    completion(true, dictResponse, "")
                } catch {
                    print("Something went wrong")
                    completion(false, nil, error.localizedDescription)
                }
            } else {
                completion(false, nil, error?.localizedDescription)
            }
        })
        task.resume()
    }
    
    func uploadImage(url: String, fileName: String, image: UIImage,type: String, id: Int,COMPLETION completion: @escaping completionBlock) {
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("type")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(type)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("moduleId")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(id)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("image")\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    if (error != nil) {
                        return
                    }
                    do {
                        let dictData = try JSONSerialization.jsonObject(with: responseData!, options: .allowFragments) as? NSDictionary
                        let status = dictData!["status"] as! Int
                        let message = dictData!["message"] as! String
                        if status == 1 {
                            let dic = dictData!["result"] as? [String: Any]
                            completion(true, dic, "")
                        }else {
                            completion(false, nil, message)
                        }
                    }catch {
                        completion(false, nil, error.localizedDescription)
                    }
                }
            }
        }).resume()
    }
    
    func uploadOCRImage(url: String, fileName: String, image: UIImage,score: Int,teamId: Int, matchId: Int,roundId: Int,COMPLETION completion: @escaping completionBlock) {
        let boundary = UUID().uuidString
        let session = URLSession.shared
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Bearer " + authToken, forHTTPHeaderField: "Authorization")
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("teamId")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(teamId)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("matchId")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(matchId)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("score")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(score)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("roundId")\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(roundId)".data(using: .utf8)!)
        
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"\("scoreImage")\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        data.append(image.pngData()!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        session.uploadTask(with: urlRequest, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                DispatchQueue.main.async {
                    if (error != nil) {
                        return
                    }
                    do {
                        let dictData = try JSONSerialization.jsonObject(with: responseData!, options: .allowFragments) as? NSDictionary
                        let status = dictData!["status"] as! Int
                        let message = dictData!["message"] as! String
                        if status == 1 {
                            let dic = dictData!["result"] as? [String: Any]
                            completion(true, dic, "")
                        }else {
                            completion(false, nil, message)
                        }
                    }catch {
                        completion(false, nil, error.localizedDescription)
                    }
                }
            }
        }).resume()
    }
}

/// CometChat
class CometAppConstants {
    // Staging
//    static var APP_ID = "2738010d421da86d"
//    static var AUTH_KEY = "4ceb72a7d047e9b332efdd343e62c41ae16cd7b6"
//    static var REGION = "US"
//    static var PROVIDER_ID = "Tussly-Staging-Provider"
    
    // Live
    static var APP_ID = "27339275eadec8b8"
    static var AUTH_KEY = "472732cb2c74f96cefdde631770f2121fcbc1fc1"
    static var REGION = "us"
    static var PROVIDER_ID = "Tussly-Live-Provider"
    
}
