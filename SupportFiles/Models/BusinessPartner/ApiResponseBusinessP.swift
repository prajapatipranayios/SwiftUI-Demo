//
//  ApiResponse.swift
//  - This class is used to manage & parse API Response

//  Tussly
//
//  Created by Auxano on 19/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import DynamicCodable

struct ApiResponseBusinessP: Codable {
    var status: Int?
    var result: ResponseBusinessP?
    var message: String
}

struct ResponseBusinessP: Codable {
    
    // BusinessP
    var businessPartners: [BusinessPartner]?
    var employees: [Employee]?
    var businessPartnerDetail: BusinessPartnerDetail?
    var order_detail: [BusinessPOrderDetail]?
    var qiList: [BusinessPOrderDetail]?
    var piList: [BusinessPOrderDetail]?
    var sampleRequestList: [BusinessPOrderDetail]?
    var productList: [BPProductList]?
    var orderDetail: BPOrderDetail?
    var state: [State]?
    var industriesCategory: [String]?
    var bmList: [BmList]?
    var hasMore: Bool?
    var city: [City]?
    var transporters: [Transporter]?
    var legalName: String?
    let businessPartner: BusinessPartner?
    
    enum CodingKeys: String, CodingKey {
        
        // BusinessP
        case businessPartners
        case employees
        case businessPartnerDetail = "business_partner_detail"
        case order_detail
        case qiList = "qi_list"
        case piList = "pi_list"
        case sampleRequestList = "sample_request_list"
        case productList
        case orderDetail
        case teamMembers
        case state
        case industriesCategory
        case bmList
        case hasMore
        case city
        case transporters
        case legalName
        case businessPartner
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        // BusinessP
        businessPartners = try values.decodeIfPresent([BusinessPartner].self, forKey: .businessPartners)
        employees = try values.decodeIfPresent([Employee].self, forKey: .employees)
        businessPartnerDetail = try values.decodeIfPresent(BusinessPartnerDetail.self, forKey: .businessPartnerDetail)
        order_detail = try values.decodeIfPresent([BusinessPOrderDetail].self, forKey: .order_detail)
        qiList = try values.decodeIfPresent([BusinessPOrderDetail].self, forKey: .qiList)
        piList = try values.decodeIfPresent([BusinessPOrderDetail].self, forKey: .piList)
        sampleRequestList = try values.decodeIfPresent([BusinessPOrderDetail].self, forKey: .sampleRequestList)
        productList = try values.decodeIfPresent([BPProductList].self, forKey: .productList)
        orderDetail = try values.decodeIfPresent(BPOrderDetail.self, forKey: .orderDetail)
        state = try values.decodeIfPresent([State].self, forKey: .state)
        industriesCategory = try values.decodeIfPresent([String].self, forKey: .industriesCategory)
        bmList = try values.decodeIfPresent([BmList].self, forKey: .bmList)
        hasMore = try values.decodeIfPresent(Bool.self, forKey: .hasMore)
        city = try values.decodeIfPresent([City].self, forKey: .city)
        transporters = try values.decodeIfPresent([Transporter].self, forKey: .transporters)
        legalName = try values.decodeIfPresent(String.self, forKey: .legalName)
        businessPartner = try values.decodeIfPresent(BusinessPartner.self, forKey: .businessPartner)
    }
    
    func encode(to encoder: Encoder) throws {
        do {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            // BusinessP
            try container.encodeIfPresent(businessPartners, forKey: .businessPartners)
            try container.encodeIfPresent(employees, forKey: .employees)
            try container.encodeIfPresent(businessPartnerDetail, forKey: .businessPartnerDetail)
            try container.encodeIfPresent(order_detail, forKey: .order_detail)
            try container.encodeIfPresent(qiList, forKey: .qiList)
            try container.encodeIfPresent(piList, forKey: .piList)
            try container.encodeIfPresent(sampleRequestList, forKey: .sampleRequestList)
            try container.encodeIfPresent(productList, forKey: .productList)
            try container.encodeIfPresent(orderDetail, forKey: .orderDetail)
            try container.encodeIfPresent(state, forKey: .state)
            try container.encodeIfPresent(industriesCategory, forKey: .industriesCategory)
            try container.encodeIfPresent(bmList, forKey: .bmList)
            try container.encodeIfPresent(hasMore, forKey: .hasMore)
            try container.encodeIfPresent(city, forKey: .city)
            try container.encodeIfPresent(transporters, forKey: .transporters)
            try container.encodeIfPresent(legalName, forKey: .legalName)
            try container.encodeIfPresent(businessPartner, forKey: .businessPartner)
        }
        catch let err {
            print(err)
        }
    }
}


//
//    func encode(to encoder: Encoder) throws {
//        do {
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            
//            try container.encodeIfPresent(redirectUrl, forKey: .redirectUrl)
//            // By Pranay
//            try container.encodeIfPresent(registrationStatus, forKey: .registrationStatus)
//            try container.encodeIfPresent(leagueMatchStatus, forKey: .leagueMatchStatus)
//            // .
//            
//            try container.encodeIfPresent(userDetail, forKey: .userDetail)
//            try container.encodeIfPresent(accessToken, forKey: .accessToken)
//            try container.encodeIfPresent(isVerified, forKey: .isVerified)
//            try container.encodeIfPresent(otp, forKey: .otp)
//            
//            try container.encodeIfPresent(firebaseDocumentId, forKey: .firebaseDocumentId)
//            
//            try container.encodeIfPresent(disputeId, forKey: .disputeId)
//            try container.encodeIfPresent(remainTime, forKey: .remainTime)
//            
//            try container.encodeIfPresent(gameTags, forKey: .gameTags)
//            try container.encodeIfPresent(team, forKey: .team)
//            try container.encodeIfPresent(friends, forKey: .friends)
//            try container.encodeIfPresent(games, forKey: .games)
//            try container.encodeIfPresent(playerCard, forKey: .playerCard)
//            try container.encodeIfPresent(friendRequests, forKey: .friendRequests)
//            
//            try container.encodeIfPresent(networks, forKey: .networks)
//            try container.encodeIfPresent(playerGames, forKey: .playerGames)
//            
//            try container.encodeIfPresent(characters, forKey: .characters)
//            try container.encodeIfPresent(stages, forKey: .stages)
//            try container.encodeIfPresent(opposingCharacters, forKey: .opposingCharacters)
//            
//            try container.encodeIfPresent(players, forKey: .players)
//            try container.encodeIfPresent(teams, forKey: .teams)
//            try container.encodeIfPresent(leagues, forKey: .leagues)
//            try container.encodeIfPresent(gameDetail, forKey: .gameDetail)
//            try container.encodeIfPresent(userRoles, forKey: .userRoles)
//            try container.encodeIfPresent(leagueInfo, forKey: .leagueInfo)
//            try container.encodeIfPresent(adminUserInfo, forKey: .adminUserInfo)
//            try container.encodeIfPresent(teamPlayers, forKey: .teamPlayers)
//            
//            try container.encodeIfPresent(registerLeagueUrl, forKey: .registerLeagueUrl)
//            try container.encodeIfPresent(activeLeagueUrl, forKey: .activeLeagueUrl)
//            try container.encodeIfPresent(pastLeagueUrl, forKey: .pastLeagueUrl)
//            try container.encodeIfPresent(leageInvitationCounts, forKey: .leageInvitationCounts)
//            try container.encodeIfPresent(teamInvitationCounts, forKey: .teamInvitationCounts)
//            try container.encodeIfPresent(isShowGuidline, forKey: .isShowGuidline)
//            // By Pranay
//            try container.encodeIfPresent(unreadNotificationCnt, forKey: .unreadNotificationCnt)
//            try container.encodeIfPresent(feedbackUrl, forKey: .feedbackUrl)
//            try container.encodeIfPresent(version, forKey: .version)
//            try container.encodeIfPresent(shipBookKeys, forKey: .shipBookKeys)
//            // .
//            
//            try container.encodeIfPresent(scoreInfo, forKey: .scoreInfo)
//            
//            try container.encodeIfPresent(teamDetail, forKey: .teamDetail)
//            try container.encodeIfPresent(currentWeekNo, forKey: .currentWeekNo)
//            try container.encodeIfPresent(currentWeek, forKey: .currentWeek)
//            try container.encodeIfPresent(schedule, forKey: .schedule)
//            try container.encodeIfPresent(maxWeekNo, forKey: .maxWeekNo)
//            
//            try container.encodeIfPresent(videos, forKey: .videos)
//            try container.encodeIfPresent(leagueRoster, forKey: .leagueRoster)
//            try container.encodeIfPresent(substitutePlayers, forKey: .substitutePlayers)
//            
//            try container.encodeIfPresent(standings, forKey: .standings)
//            try container.encodeIfPresent(header, forKey: .header)
//            try container.encodeIfPresent(leaderBoardResult, forKey: .leaderBoardResult)
//            try container.encodeIfPresent(leaderBoardHeader, forKey: .leaderBoardHeader)
//            try container.encodeIfPresent(byDate, forKey: .byDate)
//            try container.encodeIfPresent(maxCharLimit, forKey: .maxCharLimit)  //  By Pranay
//            try container.encodeIfPresent(playerAllCharacters, forKey: .playerAllCharacters) // By Pranay
//            
//            try container.encodeIfPresent(results, forKey: .results)
//            try container.encodeIfPresent(playerResults, forKey: .playerResults)
//            try container.encodeIfPresent(careerTotal, forKey: .careerTotal)
//            try container.encodeIfPresent(playerHeader, forKey: .playerHeader)
//            try container.encodeIfPresent(playerResult, forKey: .playerResult)
//            try container.encodeIfPresent(resultHeader, forKey: .resultHeader)
//            try container.encodeIfPresent(average, forKey: .average)
//            try container.encodeIfPresent(roundResults, forKey: .roundResults)
//            try container.encodeIfPresent(resultAverage, forKey: .resultAverage)
//            try container.encodeIfPresent(filterResult, forKey: .filterResult)
//            
//            try container.encodeIfPresent(playerCharacter, forKey: .playerCharacter)
//            try container.encodeIfPresent(playerStagers, forKey: .playerStagers)
//            
//            try container.encodeIfPresent(mvp, forKey: .mvp)
//            try container.encodeIfPresent(recentVoted, forKey: .recentVoted)
//            try container.encodeIfPresent(matchHeadlines, forKey: .matchHeadlines)
//            try container.encodeIfPresent(total, forKey: .total)
//            
//            try container.encodeIfPresent(unReadNotification, forKey: .unReadNotification)
//            try container.encodeIfPresent(readNotification, forKey: .readNotification)
//            try container.encodeIfPresent(hasMore, forKey: .hasMore)
//            
//            try container.encodeIfPresent(teamMembers, forKey: .teamMembers)
//            try container.encodeIfPresent(teamInfo, forKey: .teamInfo)
//            try container.encodeIfPresent(playerInfo, forKey: .playerInfo)
//            try container.encodeIfPresent(teamGames, forKey: .teamGames)
//            try container.encodeIfPresent(teamRosters, forKey: .teamRosters)
//            try container.encodeIfPresent(teamMember, forKey: .teamMember)
//            
//            try container.encodeIfPresent(arenaEntered, forKey: .arenaEntered)
//            try container.encodeIfPresent(leagueRounds, forKey: .leagueRounds)
//            try container.encodeIfPresent(match, forKey: .match)
//            try container.encodeIfPresent(contents, forKey: .contents)
//            try container.encodeIfPresent(fireBaseInfo, forKey: .fireBaseInfo)
//            // By Pranay
//            try container.encodeIfPresent(fireStoreId, forKey: .fireStoreId)
//            // .
//            
//            //try container.encodeIfPresent(matchPlayers, forKey: .matchPlayers)
//            try container.encodeIfPresent(howTouseContent, forKey: .howTouseContent)
//            
//            try container.encodeIfPresent(bracketData, forKey: .bracketData)
//            
//            // By Pranay
//            try container.encodeIfPresent(matchType, forKey: .matchType)
//            try container.encodeIfPresent(filterPopup, forKey: .filterPopup)
//            try container.encodeIfPresent(myPool, forKey: .myPool)
//            try container.encodeIfPresent(totalTeams, forKey: .totalTeams)
//            try container.encodeIfPresent(getLeagueMatches, forKey: .getLeagueMatches)
//            try container.encodeIfPresent(playerStagesAndCharacters, forKey: .playerStagesAndCharacters)
//            try container.encodeIfPresent(joinedTournamentDetails, forKey: .joinedTournamentDetails)
//            try container.encodeIfPresent(customStageCharSettings, forKey: .customStageCharSettings)
//            try container.encodeIfPresent(gameSetting, forKey: .gameSetting)
//            //try container.encodeIfPresent(stageBanSettings, forKey: .stageBanSettings)
//            //.
//            
//            try container.encodeIfPresent(rounds, forKey: .rounds)
//            try container.encodeIfPresent(roundScore, forKey: .roundScore)
//            try container.encodeIfPresent(nextMatch, forKey: .nextMatch)
//            
//            try container.encodeIfPresent(status, forKey: .status)
//            
//            try container.encodeIfPresent(gameLobby, forKey: .gameLobby)
//            
//            /// 443 - By Pranay
//            // Declare Round Winner
//            try container.encodeIfPresent(isRoundDeclare, forKey: .isRoundDeclare)
//            try container.encodeIfPresent(isFinish, forKey: .isFinish)
//            /// 443 .
//        }
//        catch let err {
//            print(err)
//        }
//    }
//}
