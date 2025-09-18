//
//  ArenaInfoCell.swift
//  Tussly
//
//  Created by Auxano on 19/10/21.
//  Copyright © 2021 Auxano. All rights reserved.
//

import UIKit

class ArenaInfoCell: UICollectionViewCell {
    
    //Variables
    var infoType = 0 //0 = arena info, 1 = dispute with photo, 2 = dispute score only
    var index = 0
    
    var arrInfoCount = [2, 1, 2, 4, 1, 2, 3, 2, 1]
    
    var arrScore = [["Once you have elected to dispute a score, choose “Option #2: Score Only” by tapping the button “Proceed #2” as per the image below:"],
                    ["A pop up will appear giving you the opportunity to submit the score that you are claiming was the correct score of the round that you just played. See image below:"],
                    ["The score that you are claiming for the round will be automatically submitted to the Admin and your opponent."],
                    ["Your opponent will have the opportunity to view the score you submitted, dispute your score, and submit photo evidence (if possible) of the score they initially reported.\nOR\nAccept the score you submitted."],
                    ["If your opponent has disputed your score, all the photo evidence and scores will be submitted to the Admin. The Tussly Arena and match will pause while the Admin makes a decision.\n\nPlease note that the Admin may contact you through chat.\n\nIf your opponent has decided not to dispute your score, the match will resume unless it was the final round in which case the match will be over."],
                    ["The Admin can decide to rule in either team’s favor or replay the round. You will be made aware of their decision in the Arena.\n\nOnce a decision has been made, the match will resume unless it was the final round in which case the match will be over."]
    ]
    var arrImgScore = [["Image - Dispute - Photo - How it works - Step 1"],
                       ["Image - Dispute - Photo - How it works - Step 2"],
                       [""],
                       [""],
                       [""],
                       [""]]
    var arrIsScoreExist = [true, true, false, false, false, false]
    
    var arrPhoto = [["Once you have elected to dispute a score, choose “Option #1: Report Score with Photo Evidence” by tapping the button “Proceed #1” as per the image below:"],
                    ["A pop up will appear giving you the opportunity to submit the score that you are claiming was the correct score of the round that you just played. See image below:"],
                    ["Once you submit your score, your camera will open inside the Tussly Arena.\n\nPlease note, if you have not already allowed Tussly access to your camera, you will be asked for permission. If you choose to deny access, you will not be able to use photo evidence in the dispute system."],
                    ["Using the Tussly in app camera, take a photo of the scoreboard of the round you are disputing."],
                    ["Your reported core and photo will be automatically reported to the Admin AND your opponent as evidence of the score you are claiming in the dispute process."],
                    ["Your opponent will have the opportunity to view the score and photo evidence you submitted, dispute your score, and submit photo evidence of their own.\nOR\nAccept the score you submitted."],
                    ["If your opponent has disputed your score, all the photo evidence and scores will be submitted to the Admin. The Tussly Arena and match will pause while the Admin makes a decision.\n\nPlease note that the Admin may contact you through chat.\n\nIf your opponent has decided not to dispute your score, the match will resume, unless it was the final round in which case the match will be over."],
                    ["The Admin can decide to rule in either team’s favor or replay the round. You will be made aware of their decision in the Arena.\n\nOnce a decision has been made, the match will resume, unless it was the final round in which case the match will be over."]
    ]
    var arrImgEvidence = [["Image - Dispute - Photo - How it works - Step 1"],
                          ["Image - Dispute - Photo - How it works - Step 2"],
                          [""],
                          ["Image - Dispute - Photo - How it works - Step 4"],
                          [""],
                          [""],
                          [""],
                          [""]]
    var arrIsPhotoExist = [true, true, false, true, false, false, false, false ]
    // MARK: -
    
    // MARK: - SSBU
    var arrSSBUInfoCount = [2, 1, 2, 4, 1, 2, 3, 2, 1]
    var arrIsSSBUImageExist = [true, true, true, false, true, true, true, true, true]
    var arrSSBUInfo = [["The Tussly Arena will guide you through your match with the following integrated steps and features:",
                        "The Arena is fully customized by the Organizer. All their rules are built into the Arena to remove any confusion of what to do. Follow the Arena prompts and you will always be within the Organizer’s rulesets."],
                       ["The Arena will open 30 minutes before your scheduled match time. Once it is open, you will be able to  enter the match lobby.\n\nWhen both teams are in the lobby, your “Proceed” button will be enabled. Once both teams have tapped “Proceed”, you will advance to the BattleArena ID Exchange or the Blind Character Selection (depending on the Organizer’s customizations)."],
                       ["Organizers can elect to enable the BattleArena ID Exchange in the Arena. This is used for online tournaments and is usually not enabled for LAN tournaments.\n\nIf not enabled, the two players will go straight from the Arena lobby to the Blind Character Selection process.\n\nIf enabled, the host player (usually determined randomly) is responsible for setting up a BattleArena in the game and sending the BattleArena ID to their opponent.",
                        "The opponent will receive the BattleArena ID and once both teams confirm that they are in the BattleArena, they will move forward to the Blind Character Selection process for the first game of the match."],
                       ["The 1st game in a set is a blind character selection. Both teams will select a character within a time limit designated by the organizer. You will not know who your opponent selected until both selections have been officially submitted.",
                        "For the 2nd game onwards. Organizers have several options to customize the Character Selection Process.\n\nThe most used option for SSBU is that the winning player from the previous game selects a character first. The losing player sees who the winning player selected prior to making their own selection.\n\nIn a less used option, the winning player must keep the same Character, but the losing player can change.\n\nFollowing the prompts will always keep you within the designated rules selected by the Organizer.",
                        "The character selections have a time limit set by the organizer. If the timer runs out before you select a character, a random character will be automatically selected unless you set a Default Character. You can set a Default Character before your match starts or in between rounds.",
                        "The Organizer may have banned certain characters from being used. These will not be available in Character Selection. Any bans are viewable in the League Information section of the app."],
                       ["Rock Paper Scissors is used to determine who acts first in the Stage Pick/Ban process of the 1st round. The winner of Rock Paper Scissors decides who bans the first stage."],
                       ["Your organizer customized their stage pick/ban. This includes the available starter stages, counter pick stages, number of bans, total stages banned each turn and DSR rules. Every step of this customized process is built into the Arena so that you are prompted when it is your turn to ban or pick.\n\nIn the 1st round, you will pick/ban only from the starter stages. From the 2nd round onwards, you can select from both the starter stages and the counter pick stages.\n\nStages banned by your opponent will have an indicator. You will be informed of the picked stage before the round starts.",
                        "Each stage pick and ban has a time limit set by the organizer. If the timer runs out before you select a stage, a random stage(s) will be automatically selected unless you Rank Your Stages. You can rank your stage before your match starts or in between rounds.\n\nIn the ban process, if you do not select a stage before the timer runs out, your lowest ranked stage will be automatically banned.\n\nIn the pick process, if you do not select a stage before the timer runs out, your highest ranked stage will be automatically picked.\n\nIf you do not rank your stages and the timer runs out, a random stage will be banned or picked for you."],
                       ["At the end of each round, the score must be reported by tapping the “Report Round Score” button.",
                        "You report the score by entering the stocks remaining for each team in the Report Score pop up.",
                        "Once either team submits a score, the opposing team will receive a pop up to confirm the reported score. If a reported score is not confirmed by the opposing team in 1 minute, it will be considered confirmed."],
                       ["You can dispute a reported score in the score confirmation pop up.",
                        "The dispute system gives you 3 options:\n\n1. Dispute with Photo Evidence\n\nYou will first report your score and then the camera will open in the Tussly Arena for you to take a photo of the scoreboard in the game. Your score and photo will be automatically submitted to the Admin and your opponent.\n\n2. Dispute with Score Only\n\nYou input and submit the score you are claiming which will be automatically submitted to the Admin and your opponent.\n\n3. Abandon Dispute\n\nYou can also choose to abandon the dispute and confirm the score your opponent originally reported."],
                       ["At any time while in the Arena you can chat with your opponent. A red notification will appear if you have a message from your opponent or the admin."]]
    
    var imgSSBUInfo = [["", ""],
                       ["Sample Image 1 - Lobby"],
                       ["Sample Image 2 - Enter BattleArena ID", "Sample Image 3 - Receive BattleArena ID"],
                       ["Sample Image 4 - Character Blind Pick", "Sample Image 5 - Character Non Blind Pick", "Sample Image 6 - Default Character", ""],
                       ["Sample Image 8 - Rock Paper Scissors"],
                       ["Sample Image 7 - Stage Pick.Ban", "Sample Image 9 - Rank Stages"],
                       ["Sample Image 10 - Report Score Button", "Sample Image 11 - Report Score", "Sample Image 12 - Confirm Score"],
                       ["Image - Dispute - Photo - How it works - Step 1-1", "Sample Image 14 - Dispute Options"],
                       ["Sample Image 15 - Chat"]]
    // MARK: -
    
    // MARK: - SSBM
    var arrSSBMInfoCount = [2, 1, 1, 4, 1, 2, 3, 2, 1]
    var arrIsSSBMImageExist = [true, true, true, false, true, true, true, true, true]
    var arrSSBMInfo = [["The Tussly Arena will guide you through your match with the following integrated steps and features:",
                        "The Arena is fully customized by the Organizer. All their rules are built into the Arena to remove any confusion of what to do. Follow the Arena prompts and you will always be within the Organizer’s rulesets."],
                       ["The Arena will open 30 minutes before your scheduled match time. Once it is open, you will be able to enter the match lobby.\n\nWhen both teams are in the lobby, your “Proceed” button will be enabled. Once both teams have tapped “Proceed”, you will advance to the Connect Code ID Exchange or the Blind Character Selection (depending on the Organizer’s customizations)."],
                       ["Organizers can elect to enable the Connect Code ID Exchange in the Arena. This is usually used for online tournaments and rarely enabled for LAN tournaments.\n\nIf not enabled, the two players will go straight from the Arena lobby to the Blind Character Selection process.\n\nIf enabled, all players will include their Connect Code when registering for the tournament. Your Connect Code will be provided to your opponent at this stage of the Arena. Once both players have confirmed that they have successfully connected in the game, they will be moved forward to the Blind Character Selection process in the Arena."],
                       ["The 1st game in a set is a blind character selection. Both teams will select a character within a time limit designated by the organizer. You will not know who your opponent selected until both selections have been officially submitted.",
                        "For the 2nd game onwards. Organizers have several options to customize the Character Selection Process.\n\nThe most used option for SSBM is that the winning player from the previous game selects a character first. The losing player sees who the winning player selected prior to making their own selection.\n\nIn a less used option, the winning player must keep the same Character, but the losing player can change.\n\nFollowing the prompts will always keep you within the designated rules selected by the Organizer.",
                        "The character selections have a time limit set by the organizer. If the timer runs out before you select a character, a random character will be automatically selected unless you set a Default Character. You can set a Default Character before your match starts or in between rounds.",
                        "The Organizer may have banned certain characters from being used. These will not be available in Character Selection. Any bans are viewable in the League Information section of the app."],
                       ["Rock Paper Scissors is used to determine who acts first in the Stage Pick/Ban process of the 1st round. The winner of Rock Paper Scissors decides who bans the first stage."],
                       ["Your organizer customized their stage pick/ban. This includes the available starter stages, counter pick stages, number of bans, total stages banned each turn and DSR rules. Every step of this customized process is built into the Arena so that you are prompted when it is your turn to ban or pick.\n\nIn the 1st round, you will pick/ban only from the starter stages. From the 2nd round onwards, you can select from both the starter stages and the counter pick stages.\n\nStages banned by your opponent will have an indicator. You will be informed of the picked stage before the round starts.",
                        "Each stage pick and ban has a time limit set by the organizer. If the timer runs out before you select a stage, a random stage(s) will be automatically selected unless you Rank Your Stages. You can rank your stage before your match starts or in between rounds.\n\nIn the ban process, if you do not select a stage before the timer runs out, your lowest ranked stage will be automatically banned.\n\nIn the pick process, if you do not select a stage before the timer runs out, your highest ranked stage will be automatically picked.\n\nIf you do not rank your stages and the timer runs out, a random stage will be banned or picked for you."],
                       ["At the end of each round, the score must be reported by tapping the “Report Round Score” button.",
                        "You report the score by entering the stocks remaining for each team in the Report Score pop up.",
                        "Once either team submits a score, the opposing team will receive a pop up to confirm the reported score. If a reported score is not confirmed by the opposing team in 1 minute, it will be considered confirmed."],
                       ["You can dispute a reported score in the score confirmation pop up.",
                        "The dispute system gives you 3 options:\n\n1. Dispute with Photo Evidence\n\nYou will first report your score and then the camera will open in the Tussly Arena for you to take a photo of the scoreboard in the game. Your score and photo will be automatically submitted to the Admin and your opponent.\n\n2. Dispute with Score Only\n\nYou input and submit the score you are claiming which will be automatically submitted to the Admin and your opponent.\n\n3. Abandon Dispute\n\nYou can also choose to abandon the dispute and confirm the score your opponent originally reported."],
                       ["At any time while in the Arena you can chat with your opponent. A red notification will appear if you have a message from your opponent or the admin."]]
    
    var imgSSBMInfo = [["", ""],
                       ["Sample Image 1 - Lobby"],
                       ["Sample Image 2 - Connect Code Exchange"],
                       ["Sample Image 4 - Character Blind Pick", "Sample Image 5 - Character Non Blind Pick", "Sample Image 6 - Default Character", ""],
                       ["Sample Image 8 - Rock Paper Scissors"],
                       ["Sample Image 7 - Stage Pick.Ban", "Sample Image 9 - Rank Stages"],
                       ["Sample Image 10 - Report Score Button", "Sample Image 11 - Report Score", "Sample Image 12 - Confirm Score"],
                       ["Image - Dispute - Photo - How it works - Step 1-1", "Sample Image 14 - Dispute Options"],
                       ["Sample Image 15 - Chat"]]
    // MARK: -
    
    // MARK: - Tekken
    var arrTekkenInfoCount = [2, 1, 1, 4, 1, 2, 3, 2, 1]
    var arrIsTekkenImageExist = [true, true, true, false, true, true, true, true, true]
    var arrTekkenInfo = [["The Tussly Arena will guide you through your match with the following integrated steps and features:",
                          "The Arena is fully customized by the Organizer. All their rules are built into the Arena to remove any confusion of what to do. Follow the Arena prompts and you will always be within the Organizer’s rulesets."],
                         ["The Arena will open 30 minutes before your scheduled match time. Once it is open, you will be able to enter the match lobby.\n\nWhen both teams are in the lobby, your “Proceed” button will be enabled. Once both teams have tapped “Proceed”, you will advance to the Player ID Exchange or the Blind Character Selection (depending on the Organizer’s customizations)."],
                         ["Organizers can elect to enable the Player ID Exchange in the Arena. This is usually used for online tournaments and rarely enabled for LAN tournaments.\n\nIf not enabled, the two players will go straight from the Arena lobby to the Blind Character Selection process.\n\nIf enabled, all players will include their PSN, Steam or Xbox ID when registering for the tournament. Your Player ID will be provided to your opponent at this stage of the Arena. Once both players have confirmed that they have successfully connected in the game, they will be moved forward to the Blind Character Selection process in the Arena."],
                         ["The 1st game in a set is a blind character selection. Both teams will select a character within a time limit designated by the organizer. You will not know who your opponent selected until both selections have been officially submitted.",
                          "For the 2nd game onwards. organizers have several options to customize the Character Selection Process.\n\nThe most used option for Tekken is that the winning player from the previous game must keep the same Character but the losing player can change.\n\nA less used option allows both players to change but the winning player must select their character first.\nThere is also an option to allow the losing player to choose between selecting the next stage or changing their character.\n\nFollowing the prompts will always keep you within the designated rules selected by the Organizer.",
                          "The character selections have a time limit set by the organizer. If the timer runs out before you select a character, a random character will be automatically selected unless you set a Default Character. You can set a Default Character before your match starts or in between rounds.",
                          "The Organizer may have banned certain characters from being used. These will not be available in Character Selection. Any bans are viewable in the League Information section of the app."],
                         ["Rock Paper Scissors is used to determine who acts first in the Stage Pick/Ban process of the 1st round. The winner of Rock Paper Scissors decides who bans the first stage."],
                         ["Tournament Organizers have the option to use a built in Stage Pick Ban system. If they opt to include one, they can fully customize it by selecting the available starter stages, counter pick stages, number of bans, total stages banned each turn and DSR rules for each game of a match. Every step of this customized process is built into the Arena so that you are prompted when it is your turn to ban or pick.\n\nIn the 1st round, you will pick/ban only from the starter stages. From the 2nd round onwards, you can select from both the starter stages and the counter pick stages.\n\nStages banned by your opponent will have an indicator. You will be informed of the picked stage before the round starts.",
                          "Each stage pick and ban has a time limit set by the organizer. If the timer runs out before you select a stage, a random stage(s) will be automatically selected unless you Rank Your Stages. You can rank your stage before your match starts or in between rounds.\n\nIn the ban process, if you do not select a stage before the timer runs out, your lowest ranked stage will be automatically banned.\n\nIn the pick process, if you do not select a stage before the timer runs out, your highest ranked stage will be automatically picked.\n\nIf you do not rank your stages and the timer runs out, a random stage will be banned or picked for you."],
                         ["At the end of each round, the score must be reported by tapping the “Report Round Score” button.",
                          "You report the score by entering the stocks remaining for each team in the Report Score pop up.",
                          "Once either team submits a score, the opposing team will receive a pop up to confirm the reported score. If a reported score is not confirmed by the opposing team in 1 minute, it will be considered confirmed."],
                         ["You can dispute a reported score in the score confirmation pop up.",
                          "The dispute system gives you 3 options:\n\n1. Dispute with Photo Evidence\n\nYou will first report your score and then the camera will open in the Tussly Arena for you to take a photo of the scoreboard in the game. Your score and photo will be automatically submitted to the Admin and your opponent.\n\n2. Dispute with Score Only\n\nYou input and submit the score you are claiming which will be automatically submitted to the Admin and your opponent.\n\n3. Abandon Dispute\n\nYou can also choose to abandon the dispute and confirm the score your opponent originally reported."],
                         ["At any time while in the Arena you can chat with your opponent. A red notification will appear if you have a message from your opponent or the admin."]]
    
    var imgTekkenInfo = [["", ""],
                         ["Sample Image 1 - Lobby"],
                         ["Sample Image 2 - Connect Code Exchange"],
                         ["Sample Image 4 - Character Blind Pick", "Sample Image 5 - Character Non Blind Pick", "Sample Image 6 - Default Character", ""],
                         ["Sample Image 8 - Rock Paper Scissors"],
                         ["Sample Image 7 - Stage Pick.Ban", "Sample Image 9 - Rank Stages"],
                         ["Sample Image 10 - Report Score Button", "Sample Image 11 - Report Score", "Sample Image 12 - Confirm Score"],
                         ["Image - Dispute - Photo - How it works - Step 1-1", "Sample Image 14 - Dispute Options"],
                         ["Sample Image 15 - Chat"]]
    // MARK: -
    
    // MARK: - Virtua Fighter 5
    var arrVF5InfoCount = [2, 1, 2, 4, 1, 2, 3, 2, 1]
    var arrIsVF5ImageExist = [true, true, true, false, true, true, true, true, true]
    var arrVF5Info = [["The Tussly Arena will guide you through your match with the following integrated steps and features:",
                       "The Arena is fully customized by the Organizer. All their rules are built into the Arena to remove any confusion of what to do. Follow the Arena prompts and you will always be within the Organizer’s rulesets."],
                      ["The Arena will open 30 minutes before your scheduled match time. Once it is open, you will be able to  enter the match lobby.\n\nWhen both teams are in the lobby, your “Proceed” button will be enabled. Once both teams have tapped “Proceed”, you will advance to the Room ID Exchange or the Blind Character Selection (depending on the Organizer’s customizations)."],
                      ["Organizers can elect to enable the Room ID Exchange in the Arena. This is used for online tournaments and is usually not enabled for LAN tournaments.\n\nIf not enabled, the two players will go straight from the Arena lobby to the Blind Character Selection process.\n\nIf enabled, the host player (usually determined randomly) is responsible for setting up a Room in the game and sending the Room ID to their opponent.",
                       "The opponent will receive the Room ID and once both teams confirm that they are in the Room, they will move forward to the Blind Character Selection process for the first game of the match."],
                      ["The 1st game in a set is a blind character selection. Both teams will select a character within a time limit designated by the organizer. You will not know who your opponent selected until both selections have been officially submitted.",
                       "For the 2nd game onwards. organizers have several options to customize the Character Selection Process.\n\nThe most used option for Virtua Fighter 5 is that the winning player from the previous game must keep the same Character but the losing player can change.\n\nA less used option allows both players to change but the winning player must select their character first.\n\nFollowing the prompts will always keep you within the designated rules selected by the Organizer",
                       "The character selections have a time limit set by the organizer. If the timer runs out before you select a character, a random character will be automatically selected unless you set a Default Character. You can set a Default Character before your match starts or in between rounds.",
                       "The Organizer may have banned certain characters from being used. These will not be available in Character Selection. Any bans are viewable in the League Information section of the app."],
                      ["Rock Paper Scissors is used to determine who acts first in the Stage Pick/Ban process of the 1st round. The winner of Rock Paper Scissors decides who bans the first stage."],
                      ["Tournament Organizers have the option to use a built in Stage Pick Ban system. If they opt to include one, they can fully customize it by selecting the available starter stages, counter pick stages, number of bans, total stages banned each turn and DSR rules for each game of a match. Every step of this customized process is built into the Arena so that you are prompted when it is your turn to ban or pick.\n\nIn the 1st round, you will pick/ban only from the starter stages. From the 2nd round onwards, you can select from both the starter stages and the counter pick stages.\n\nStages banned by your opponent will have an indicator. You will be informed of the picked stage before the round starts.",
                       "Each stage pick and ban has a time limit set by the organizer. If the timer runs out before you select a stage, a random stage(s) will be automatically selected unless you Rank Your Stages. You can rank your stage before your match starts or in between rounds.\n\nIn the ban process, if you do not select a stage before the timer runs out, your lowest ranked stage will be automatically banned.\n\nIn the pick process, if you do not select a stage before the timer runs out, your highest ranked stage will be automatically picked.\n\nIf you do not rank your stages and the timer runs out, a random stage will be banned or picked for you."],
                      ["At the end of each round, the score must be reported by tapping the “Report Round Score” button.",
                       "You report the score by entering the stocks remaining for each team in the Report Score pop up.",
                       "Once either team submits a score, the opposing team will receive a pop up to confirm the reported score. If a reported score is not confirmed by the opposing team in 1 minute, it will be considered confirmed."],
                      ["You can dispute a reported score in the score confirmation pop up.",
                       "The dispute system gives you 3 options:\n\n1. Dispute with Photo Evidence\n\nYou will first report your score and then the camera will open in the Tussly Arena for you to take a photo of the scoreboard in the game. Your score and photo will be automatically submitted to the Admin and your opponent.\n\n2. Dispute with Score Only\n\nYou input and submit the score you are claiming which will be automatically submitted to the Admin and your opponent.\n\n3. Abandon Dispute\n\nYou can also choose to abandon the dispute and confirm the score your opponent originally reported."],
                      ["At any time while in the Arena you can chat with your opponent. A red notification will appear if you have a message from your opponent or the admin."]]
    
    var imgVF5Info = [["", ""],
                      ["Sample Image 1 - Lobby"],
                      ["Sample Image 2 - Enter BattleArena ID", "Sample Image 3 - Receive BattleArena ID"],
                      ["Sample Image 4 - Character Blind Pick", "Sample Image 5 - Character Non Blind Pick", "Sample Image 6 - Default Character", ""],
                      ["Sample Image 8 - Rock Paper Scissors"],
                      ["Sample Image 7 - Stage Pick.Ban", "Sample Image 9 - Rank Stages"],
                      ["Sample Image 10 - Report Score Button", "Sample Image 11 - Report Score", "Sample Image 12 - Confirm Score"],
                      ["Image - Dispute - Photo - How it works - Step 1-1", "Sample Image 14 - Dispute Options"],
                      ["Sample Image 15 - Chat"]]
    // MARK: -
    
    // MARK: - NASB2
    var arrNASB2InfoCount = [2, 1, 2, 4, 1, 2, 3, 2, 1]
    var arrIsNASB2ImageExist = [true, true, true, false, true, true, true, true, true]
    var arrNASB2Info = [["The Tussly Arena will guide you through your match with the following integrated steps and features:",
                        "The Arena is fully customized by the Organizer. All their rules are built into the Arena to remove any confusion of what to do. Follow the Arena prompts and you will always be within the Organizer’s rulesets."],
                        
                       ["The Arena will open 30 minutes before your scheduled match time. Once it is open, you will be able to enter the match lobby.\n\nWhen both teams are in the lobby, your “Proceed” button will be enabled. Once both teams have tapped “Proceed”, you will advance to the Lobby Password Exchange or the Blind Character Selection (depending on the Organizer’s customizations)."],
                        
                       ["Organizers can elect to enable the Lobby Password Exchange in the Arena. This is used for online tournaments and is usually not enabled for LAN tournaments.\n\nIf not enabled, the two players will go straight from the Arena lobby to the Blind Character Selection process.\n\nIf enabled, the host player (usually determined randomly) is responsible for setting up a Lobby in the game and sending the Lobby Password to their opponent.",
                        "The opponent will receive the Lobby Password and once both teams confirm that they are in the Lobby, they will move forward to the Blind Character Selection process for the first game of the match."],
                        
                       ["The 1st game in a set is a blind character selection. Both teams will select a character within a time limit designated by the organizer. You will not know who your opponent selected until both selections have been officially submitted.",
                        "For the 2nd game onwards. organizers have several options to customize the Character Selection Process.\n\nThe most used option for Nickelodeon All Star Brawl 2 is that the winning player from the previous game selects a character first. The losing player sees who the winning player selected prior to making their own selection.\n\nIn a less used option, the winning player must keep the same Character, but the losing player can change.\n\nFollowing the prompts will always keep you within the designated rules selected by the Organizer.",
                        "The character selections have a time limit set by the organizer. If the timer runs out before you select a character, a random character will be automatically selected unless you set a Default Character. You can set a Default Character before your match starts or in between rounds.",
                        "The Organizer may have banned certain characters from being used. These will not be available in Character Selection. Any bans are viewable in the League Information section of the app."],
                        
                       ["Rock Paper Scissors is used to determine who acts first in the Stage Pick/Ban process of the 1st round. The winner of Rock Paper Scissors decides who bans the first stage."],
                        
                       ["Your organizer customized their stage pick/ban. This includes the available starter stages, counter pick stages, number of bans, total stages banned each turn and DSR rules. Every step of this customized process is built into the Arena so that you are prompted when it is your turn to ban or pick.\n\nIn the 1st round, you will pick/ban only from the starter stages. From the 2nd round onwards, you can select from both the starter stages and the counter pick stages.\n\nStages banned by your opponent will have an indicator. You will be informed of the picked stage before the round starts.",
                        "Each stage pick and ban has a time limit set by the organizer. If the timer runs out before you select a stage, a random stage(s) will be automatically selected unless you Rank Your Stages. You can rank your stage before your match starts or in between rounds.\n\nIn the ban process, if you do not select a stage before the timer runs out, your lowest ranked stage will be automatically banned.\n\nIn the pick process, if you do not select a stage before the timer runs out, your highest ranked stage will be automatically picked.\n\nIf you do not rank your stages and the timer runs out, a random stage will be banned or picked for you."],
                        
                       ["At the end of each game, the score must be reported by tapping the “Report Round Score” button.",
                        "You report the score by entering the stocks remaining for each team in the Report Score pop up.",
                        "Once either team submits a score, the opposing team will receive a pop up to confirm the reported score. If a reported score is not confirmed by the opposing team in 1 minute, it will be considered confirmed."],
                        
                       ["You can dispute a reported score in the score confirmation pop up.",
                        "The dispute system gives you 3 options:\n\n1. Dispute with Photo Evidence\n\nYou will first report your score and then the camera will open in the Tussly Arena for you to take a photo of the scoreboard in the game. Your score and photo will be automatically submitted to the Admin and your opponent.\n\n2. Dispute with Score Only\n\nYou input and submit the score you are claiming which will be automatically submitted to the Admin and your opponent.\n\n3. Abandon Dispute\n\nYou can also choose to abandon the dispute and confirm the score your opponent originally reported."],
                        
                       ["At any time while in the Arena you can chat with your opponent. A red notification will appear if you have a message from your opponent or the admin."]]
    
    var imgNASB2Info = [["", ""],
                       ["Sample Image 1 - Lobby"],
                       ["Sample Image 2 - Enter BattleArena ID", "Sample Image 3 - Receive BattleArena ID"],
                       ["Sample Image 4 - Character Blind Pick", "Sample Image 5 - Character Non Blind Pick", "Sample Image 6 - Default Character", ""],
                       ["Sample Image 8 - Rock Paper Scissors"],
                       ["Sample Image 7 - Stage Pick.Ban", "Sample Image 9 - Rank Stages"],
                       ["Sample Image 10 - Report Score Button", "Sample Image 11 - Report Score", "Sample Image 12 - Confirm Score"],
                       ["Image - Dispute - Photo - How it works - Step 1-1", "Sample Image 14 - Dispute Options"],
                       ["Sample Image 15 - Chat"]]
    // MARK: -
    
    //Outlets
    @IBOutlet weak var tvData: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tvData.rowHeight = UITableView.automaticDimension
        tvData.estimatedRowHeight = 245.0
        tvData.reloadData()
    }
}

extension ArenaInfoCell: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return infoType == 0 ? arrInfoCount[index] : 1
        return (infoType == 0 ? arrInfoCount[index] : (infoType == 3 ? arrSSBMInfoCount[index] : (infoType == 4 ? arrTekkenInfoCount[index] : (infoType == 5 ? arrVF5InfoCount[index] : (infoType == 6 ? arrVF5InfoCount[index] : 1)))))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArenaInfoDataCell", for: indexPath) as! ArenaInfoDataCell
        cell.selectionStyle = .none
        var arrText = [String]()
        var arrImg = [String]()
        
        if infoType == 0 {
            if index == 0 && indexPath.row == 0 {
                cell.viewOverview.isHidden = false
                cell.lblOverview.text = "\u{2022} Lobby\n\u{2022} BattleArena ID Exchange\n\u{2022} Character Selection\n\u{2022} Rock Paper Scissors\n\u{2022} Stage Pick/Ban\n\u{2022} Score Reporting\n\u{2022} Dispute System\n\u{2022} Chat"
            } else {
                cell.viewOverview.isHidden = true
            }
            arrText = arrSSBUInfo[index]
            arrImg = imgSSBUInfo[index]
            if arrIsSSBUImageExist[index] == false && arrImg[indexPath.row] == "" {
                cell.imgHeight.constant = 0
            } else {
                //cell.imgHeight.constant = 200
                cell.imgHeight.constant = (index == 0 && indexPath.row == 1) ? 0 : 200
            }
        }
        else if infoType == 3 {
            if index == 0 && indexPath.row == 0 {
                cell.viewOverview.isHidden = false
                cell.lblOverview.text = "\u{2022} Lobby\n\u{2022} Connect Code Exchange\n\u{2022} Character Selection\n\u{2022} Rock Paper Scissors\n\u{2022} Stage Pick/Ban\n\u{2022} Score Reporting\n\u{2022} Dispute System\n\u{2022} Chat"
            } else {
                cell.viewOverview.isHidden = true
            }
            arrText = arrSSBMInfo[index]
            arrImg = imgSSBMInfo[index]
            if arrIsSSBMImageExist[index] == false && arrImg[indexPath.row] == "" {
                cell.imgHeight.constant = 0
            } else {
                //cell.imgHeight.constant = 200
                cell.imgHeight.constant = (index == 0 && indexPath.row == 1) ? 0 : 200
            }
        }
        else if infoType == 4 {
            if index == 0 && indexPath.row == 0 {
                cell.viewOverview.isHidden = false
                cell.lblOverview.text = "\u{2022} Lobby\n\u{2022} Player ID Exchange\n\u{2022} Character Selection\n\u{2022} Rock Paper Scissors\n\u{2022} Stage Pick/Ban\n\u{2022} Score Reporting\n\u{2022} Dispute System\n\u{2022} Chat"
            } else {
                cell.viewOverview.isHidden = true
            }
            arrText = arrTekkenInfo[index]
            arrImg = imgTekkenInfo[index]
            if arrIsTekkenImageExist[index] == false && arrImg[indexPath.row] == "" {
                cell.imgHeight.constant = 0
            } else {
                //cell.imgHeight.constant = 200
                cell.imgHeight.constant = (index == 0 && indexPath.row == 1) ? 0 : 200
            }
        }
        else if infoType == 5 {
            if index == 0 && indexPath.row == 0 {
                cell.viewOverview.isHidden = false
                cell.lblOverview.text = "\u{2022} Lobby\n\u{2022} Room ID Exchange\n\u{2022} Character Selection\n\u{2022} Rock Paper Scissors\n\u{2022} Stage Pick/Ban\n\u{2022} Score Reporting\n\u{2022} Dispute System\n\u{2022} Chat"
            } else {
                cell.viewOverview.isHidden = true
            }
            arrText = arrVF5Info[index]
            arrImg = imgVF5Info[index]
            if arrIsVF5ImageExist[index] == false && arrImg[indexPath.row] == "" {
                cell.imgHeight.constant = 0
            } else {
                //cell.imgHeight.constant = 200
                cell.imgHeight.constant = (index == 0 && indexPath.row == 1) ? 0 : 200
            }
        }
        else if infoType == 6 {
            if index == 0 && indexPath.row == 0 {
                cell.viewOverview.isHidden = false
                cell.lblOverview.text = "\u{2022} Lobby\n\u{2022} Lobby Password Exchange\n\u{2022} Character Selection\n\u{2022} Rock Paper Scissors\n\u{2022} Stage Pick/Ban\n\u{2022} Score Reporting\n\u{2022} Dispute System\n\u{2022} Chat"
            } else {
                cell.viewOverview.isHidden = true
            }
            arrText = arrNASB2Info[index]
            arrImg = imgNASB2Info[index]
            if arrIsNASB2ImageExist[index] == false && arrImg[indexPath.row] == "" {
                cell.imgHeight.constant = 0
            } else {
                //cell.imgHeight.constant = 200
                cell.imgHeight.constant = (index == 0 && indexPath.row == 1) ? 0 : 200
            }
        }
        else if infoType == 1 {
            arrText = arrPhoto[index]
            arrImg = arrImgEvidence[index]
            if arrIsPhotoExist[index] == false && arrImg[indexPath.row] == "" {
                cell.imgHeight.constant = 0
            }
        } else {
            arrText = arrScore[index]
            arrImg = arrImgScore[index]
            if arrIsScoreExist[index] == false && arrImg[indexPath.row] == "" {
                cell.imgHeight.constant = 0
            }
        }
        
        /*if index == 3 {
         //let str = NSMutableAttributedString(string: arrText[indexPath.row])
         let str : NSAttributedString = arrText[indexPath.row] as? NSAttributedString ?? ""
         //cell.lblInfo.text = arrText[indexPath.row]
         cell.lblInfo.text = str.setAttributedString(boldString: "unless", fontSize: 16.0)
         } else {
         cell.lblInfo.text = arrText[indexPath.row]
         }   //  */
        cell.lblInfo.text = arrText[indexPath.row]
        cell.imgInfo.image = UIImage(named: arrImg[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
