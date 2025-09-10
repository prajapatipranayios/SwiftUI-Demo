//
//  TabBarItem.swift
//  SwiftUIDemo
//
//  Created by Auxano on 10/04/24.
//

import SwiftUI

enum TabBarItem: Identifiable, Hashable, CaseIterable {
    
    case home, schedule, chat, notification, menu
    
    var id: Self {
        return self
    }
    
    var image: String {
        switch self {
        case .home: return "house"
        case .schedule: return "magnifyingglass"
        case .chat: return "message"
        case .notification: return "person"
        case .menu: return "house"
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .schedule: return "Schedule"
        case .chat: return "Chat"
        case .notification: return "Notification"
        case .menu: return "More"
        }
    }
    
    var color: Color {
        switch self {
        case .home: return Color.orange
        case .schedule: return Color.blue
        case .chat: return Color.green
        case .notification: return Color.red
        case .menu: return Color.gray
        }
    }
}
