//
//  StaticContents.swift
//  Tussly
//
//  Created by MAcBook on 04/11/22.
//  Copyright © 2022 Auxano. All rights reserved.
//
///  Model file added  --  By Pranay

import Foundation

// MARK: - NotificationContent
struct NotificationContent: Codable {
    let welcomeNotification: WelcomeNotification?
    let endTournament: EndTournament?
}

// MARK: - EndTournament
struct EndTournament: Codable {
    var title: String?
    var desc: String?
    var link: String?
}

// MARK: - WelcomeNotification
struct WelcomeNotification: Codable {
    var title: String?
    var desc: String?
}
