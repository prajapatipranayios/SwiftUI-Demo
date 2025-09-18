//
//  Constants.swift
//  - Contains all the static constants like messages which will never get changed.

//  Tussly
//
//  Created by Jaimesh Patel on 05/11/19.
//  Copyright © 2019 Auxano. All rights reserved.
//

import Foundation
import UIKit

let MIN_PASSWORD_LENGTH = 8
let MIN_USERNAME_LENGTH = 3     //  By Pranay - Change min length 6 to 3.
let MAX_PASSWORD_LENGTH = 20
//let MIN_MOBILE_LENGTH = 10    //  Comment by Pranay.
let MIN_MOBILE_LENGTH = 7  //  Added by Pranay
let MAX_MOBILE_LENGTH = 17
let SKELETON_ROWHEADER_COUNT = 6

// For Error Messages
let No_Camera = "Sorry, this device has no camera."
let Network_Error = "No Internet Connection"

// For Validation Message
let Valid_Email = "Please enter valid Email Address"
let Valid_Mobile = "Please enter valid Mobile Number"
let Valid_Password = "Please enter password between 8 to 20 characters"
let Confirm_Password_Not_Match = "Password and Confirm Password doesn't match"
let Empty_Gender = "Please enter Your Gender"
let Empty_Team_Bio = "Please enter Team Bio"
let Empty_Player_Bio = "Please enter Player Bio"
let Empty_Caption = "Please enter Video Caption"
let Empty_OTP = "Verification OTP must be of 4 digits"
let Valid_OTP = "Your entered OTP is incorrect"

// Label popup Message
let Forgot_Password_PopUp_Title = "Reset your Password"
let Verification_Title = "Verification Link"
let Add_Card_Title = "Success"
let Remove_Confirmation_Title = "Remove Confirmation"

let Remove_Confirmation_Discription = "Are you sure you want to delete payment details?"
let Add_Card_Discription = "Payment details have been saved successfully"
let Verification_Email_Discription = "We have sent a verification link on your registered email address"
let Forgot_Password_PopUp_Email_Discription = "We have sent a password resent link to your registered email address"
let Forgot_Password_PopUp_Mobile_Discription = "We have sent a password resent link to your registered mobile number"
let Change_Password_PopUp_Title = "Successfully Changed"
let Change_Password_PopUp_Discription = "Password has been changed successfully"

// For User Default
struct UserDefaultType {
//    static let logInParameters = "LogInParameters"
    static let rememberMe = "RememberMe"
    static let accessToken = "accessToken"
    static let fcmToken = "fcmToken"
    static let currentSection = "currentSection"
    static let currentRow = "currentRow"
    // By Pranay
    static let notificationCount = "com.app.Tussly.notification"
    static let chatNotificationCount = "com.app.Tussly.chat"
    static let forBetaPopup = "betaVersionPopupActive"
    static let forDisputePopup = "DisputePopupActive"
    static let updateVersion = "UpdateVersion"
    // .
}

//Notification Types
struct NotificationType {
    
}

struct Messages {
    
    // MARK: User story board
    // Tussly tab
    static let tussly = "Tussly"
    static let loginTussly = "Please login to tussly"
    static let registerLeague = "You have not yet registered for a League"
    static let registerTournament = "You have not yet registered for a Tournament"
    static let schedule = "Scheduler allows you to manage your gaming schedule and schedule practices, scrims, and other events with your team or other players. Register for free with Tussly to gain access to the scheduler"
    static let chat = "Chat allows you to connect with friends, organizers, teammates or even opponents - one on one or in a group. Simply register and login for free to access the chat feature."
    
    // Message change
    static let notification = "Notifications"
    
    static let team = "You have not yet created a team for free"
    static let playerCard = "Register for free at Tussly to receive your free player card"
    static let login = "Login"
    static let close = "Close"
    static let myLeagues = "My Leagues"
    static let myTournament = "My Tournament"
    static let notYetRegisterLeagues = "You have not yet registered for a league."
    static let notYetRegisterTournament = "You have not yet registered for a tournament."
    static let registerNow = "Register Now"
    static let registerForLeague = "Register for a League"
    static let registerForTournament = "Register for a Tournament"
    static let registrationPageYourBrowser = "You will now be taken to Tussly's mobile Web League Registration Page in your browser."
    static let registrationPageYourBrowserForTournament = "You will now be taken to Tussly's mobile Web Tournament Registration Page in your browser."
    static let ok = "Ok"
    static let cancel = "Cancel"
    static let addFriendRequest = "View player or request to add as friend."
    static let searchPlayer = "Search Players"
    static let requestToJoin = "View team or request to join."
    static let searchTeam = "Search Teams"
    //static let searchLeague = "Search Leagues & Tournaments to view details."
    static let searchLeague = "Search Tournaments to view details."
    
    static let registrationClose = "Registration for this Tournament is closed."
    static let createTeam = "Create Team"
    static let createTeamMsg = "Login or Register with Tussly to create a team and enjoy the following:\n\nEasy Tournament Registration\nTeam & Team Member Tournament Stats\nGroup Chats\nCustomizable Team Page\nTeam Highlight Videos\nand more..."
    static let playerCardInitial = "Player Card"
    static let playerCardInitialMsg = "Upon Registration, you will be provided a Player Card with the following features:\n\nIndividual and career tournament stats\nAdd Friends and/or followers\nChat with Friends\nCustomizable Player Card\nHighlight videos\nand more..."
    static let searchTournament = "Search Tournament"
    static let notificationMsg = "As a registered user, some of the notifications you will receive include:\n\nMatch times as they are scheduled\nStation assignments on Lan\nSchedule changes\nLate for match warnings\nGroup & individual chats\nFriend requests & acceptances\nand much more..."
    static let search = "Search"
    static let searchMsg = "You must login or register with Tussly to search for the following:\n\nPlayers: View other users' Player Cards, tournament history and statistics. Add as friends, chat and more.\n\nTeams: View Team Pages, tournament history, statistics and highlight videos.\nRequest to join or create your own.\n\nTournaments: View ongoing and registering tournaments, info, brackets, leaderboards and more."
    static let viewTournament = "View Tournament"
    static let viewTournamentMsg = "Please login with tussly to access this feature."
    static let betaVersionTitle = "Early Access"
    static let betaVersionMsg = "Early access means that you are one of the first to use our platform. It also means that you will probably find errors or have ideas for features you would like to see.\n\nYour feedback is extremely important to us. We encourage you to visit our \"Provide Feedback\" section.\n\nEnjoy the Tussly platform! We hope you love using it as much as we love building it."
    static let disputePopupMsg = "Our dispute system is a work in progress and should work on most mobile devices.\n\nHowever, if the dispute system freezes, shut the app down and re-enter the Arena. This will reset it and you can continue forward.\n\nIf you do encounter an issue, please report it to the \"Provide Feedback\" section in the app hamburger menu. This information is extremely valuable to us."
    static let provideFeedback = "Provide Feedback"
    static let provideFeedbackMsg = "Login required"
    static let registerTeam = "Please Create or Join Team."
    static let setting = "Settings"
    
    static let updateTitle = "Update Available"
    static let updateMsg = "The newest version of Tussly is now available."
    static let updateBtnTitle = "Update Now"
    
    // Login tab
    static let welcome = "Welcome"
    static let welcomeToTussly = "Welcome to tussly"
    
    // Sign Up
    static let selectGamertag = "Select Gaming ID"
    static let note = "Note : "
    static let allowAddGamerTag = "It allows the player to add the gaming ID's of the platform which they are considering to use for playing the leagues."
    
    // Setting
    static let uploadProfilePhoto = "Upload Profile Photo"
    static let logout = "Logout"
    static let sureWantToLogout = "Are you sure, you want to logout?"
    static let yes = "Yes"
    static let no = "No"
    static let yesProceed = "Yes, Proceed"
    static let noGoBack = "No, Go back"
    static let heyWait = "Hey Wait!"
    static let saveChanges = "Are you sure, you want to leave this screen without saving changes?"
    static let save = "Save"
    static let DeleteAccount = "Delete Account"
    static let ConfirmAccountDelete = "Are you sure you want to delete your account?\n\nThis action is permanent and will remove all your data. You won’t be able to recover your account once it’s deleted."
    
    // Create Team
    static let founderAndCaptainCanChanged = "The person who creates the page is the default founder and captain but that can be changed."
    static let uploadTeamBanner = "Upload Team Banner"
    static let uploadTeamLogo = "Upload Team Logo"
    static let selectAction = "Select Action"
    static let uploadFile = "Upload File"
    static let visitStore = "Visit Store"
    static let capturePhotoFromCamera = "Capture photo from camera"
    static let selectPhotoFromGallery = "Select photo from gallery"
    static let friendList = "Friend List"
    static let inviteFriend = "Invite Friends"
    static let invite = "Invite"
    static let addFriendToTeam = "Add Friends to Team"
    
    // Create Event
    static let eventRegister = "Event Registration"
    static let eventRegisterMessage = "To register for a league or tournament, you will now be taken to Tussly's mobile web registration page in your browser."
    
    // Friend List
    static let searchByDisplayName = "Search by Display Name"
    static let removeFriendTitle = "Remove Friend"
    static let removeFriendMsg = "Are you sure you want to remove this friend?"
        
    // Create Player Card
    static let changePlayerCardAnytime = "You will be able to change player card anytime."
    static let uploadPlayercardBanner = "Upload Player Card Banner"
    static let uploadPlayercardLogo = "Upload Player Card Logo"
    
    // Select Game
    static let selectGame = "Select Game"
    
    // Select Type
    static let selectType = "Select Type"
    
    // Admin Tools
    static let relinquishOwnership = "Relinquish Ownership"
    static let relinquishOwnershipMessage = "In order to give up on the ownership of this team, you need to select a new founder for this team."
    static let ownerLeaveTeam = "In order to leave this team, you need to first assign a new founder of this team."
    static let confirmNewFounder = "Confirm New Founder"
    static let scorboard = "Scoreboard"
    static let confirm = "Confirm"
    static let confirmAndLeave = "Confirm & Leave"
    static let newFounderSelection = "New Founder Selection"
    static let founderSelection = "Founder Selection"
    static let makeNewFounder = "Make New Founder"
    static let searchForPlayers = "Search for players"
    static let assignNewFounder = "Assign New Founder"
    static let closeTeam = "Close Team"
    static let sureWantToClose = "Are you sure that you want to close this team?"
    static let alert = "Alert"
    static let closeTeamMessage = "This team page will be closed once all the registered leagues under this team banner is closed. Also, no further league registrations will be allowed."
    static let noFurtherLeagueAllow = "Also, no further league registrations will be allowed."
    
    // Team Tab
    static let leaveTeam = "Leave Team"
    static let sureWantToLeave = "Are you sure,you want to leave this team?"
    static let leave = "Leave"
    
    // Make Admin
    static let adminSelection = "Admin Selection"
    static let captainSelection = "Captain Selection"
    static let deleteMembers = "Delete Members"
    static let removeMembers = "Remove Members"
    
    static let makeAdmin = "Make Admin"
    static let makeCaptain = "Make Captain"
    static let delete = "Delete"
    
    // Remove Admin
    static let searchAdmin = "Search Admins"
    static let searchCaptain = "Search Captains"
    static let removeAdmin = "Remove Admin"
    static let removeCaptain = "Remove Captain"
    static let remove = "Remove"
    
    // Delete Video
    static let deleteVideo = "Delete Video"
    static let removeVideo = "Remove Video"
    
    // Invite Member
    static let inviteMemberDiscription = "Use referral code sdfdfdf  to sign up. Invite a friend and earn 100 Tokens on each Signup"
    
    // Manage League Roster
    static let selectPlayerMakeAssistantCaptain = "Select Player to make him Assistant Captain"
    static let selectEqualAmount = "Please select equal amount of Players for swapping"
    static let addAssistantcaptain = "Add an Assistant Captain"
    static let firstAddCaptainToLeague = "You need to first add an Assistant captain for this league in order to manage rosters."
    static let selectPlayerAlreadyCaptain = "Selected player is already Captain. Please choose another player"
    static let selectPlayerAlreadyViceCaptain = "Selected player is already Vice Captain. Please choose another player"
    static let add = "Add"
    
    // Stat Camera
    static let accessCameraTitle = "‘Tussly’ would like to Access the Camera"
    static let accessCameraMessage = "The Tussly App uses your camera to scan the QR Code"
    static let dontAllow = "Don’t Allow"
    static let allow = "Allow"
    
    // Highlight
    static let deleteHighlight = "Delete Highlight"
    
    // Tied Damage
    static let tiedDamage = "Tied Damage %"
    static let areYouSureTheWasTied = "Are you sure the % was tied?"
    static let areYouSureCofirmOpponentScore = "Are you sure you want to confirm your opponent's score in this dispute?"
    
    static let singleLifeRematch = "Round score was tied. Play a single life rematch (Same Stage & Character) to select the winner."
    static let selectTheWinner = "Round score was tied. Select the winner."
    static let lowestDamage = "Tie Breaker. The player with lowest damage % wins. If % is tied click here > "
    
    static let suddenDeath = "Tie Breaker. The winner is determined by sudden death."
    
    //Unselect stage
    static let unselectToSelect = "Unselect to Select"
    static let unselectStage = "Unselect a current stage to select a new one."
    
    //Scoreboard popup waiting messages
    //static let waitToConfirm = "Waiting for your opponent to confirm the score you submitted. Keep your \(APIManager.sharedManager.gameSettings?.id == 11 ? "SSBU" : "SSBM") Scoreboard up until the score is confirm."   //  By Pranay Condition
    //static let waitToConfirm = "Waiting for your opponent to confirm the score you submitted. Keep your \(APIManager.sharedManager.gameSettings?.gameName ?? "") Scoreboard up until the score is confirm."   //  By Pranay Condition
    static var waitToConfirm: String {
        return "Waiting for your opponent to confirm the score you submitted. Keep your \(APIManager.sharedManager.gameSettings?.gameName ?? "") Scoreboard up until the score is confirm."
    }
    static let waitToConfirmOrDispute = "Waiting for your opponent to confirm or deny your score."
    static let timerToConfirm = "You have 60 seconds to confirm the scores"
    
    //Battleid message
    //static let waitForBattleId = "Waiting for your opponent to send a BattleArena ID. This may take a few minutes."
    static let waitForBattleId = "Waiting for your opponent to send a \(APIManager.sharedManager.gameSettings?.gameLabel ?? ""). This may take a few minutes."
    //static let battleIdSent = "BattleArena ID has been sent. Waiting on your opponent to enter the BattleArena. Next step Character Selection."
    static let battleIdSent = "\(APIManager.sharedManager.gameSettings?.gameLabel ?? "") has been sent. Waiting on your opponent to enter the BattleArena. Next step Character Selection."
    static let waitingForPlayer = "Waiting for player..."
    static let readyToStart = "Ready to start!"
    
    //Games played
    static let addGame = "Add a game you play"
    static let searchGameToAdd = "search for a game to add to your card"
    
    //Stage pick ban waiting messages
    static let opponentPicking = "Your opponent is picking a stage to play on."
    static let opponentSelecting = "Your opponent is selecting a stage to ban."
    //static let selectToPlay = "Select a stage to play on!"
    static let selectToPlay = "PICK a stage to play on!"
    static let ban2Stage = "Select 2 stages to ban."
    static let ban1Stage = "Select 1 stage to ban"
    static let ban2StageToContinue = "Opponent banned 1 stage. Select 2 stages to ban."
    static let pleaseSelectToPlay = "Please pick a stage to play on!"
    
    //League/Tournament
    static let waitForJoinMatch = "Waiting for your opponent to join match."
    static let readyToJoinMatch = "Are you ready to join match?"
    static let confirmBothReady = "Confirm that both players are in the BattleArena and proceed to Character Selection"
    static let gameOver = "Game Over"
    static let finalResult = "Final Results"
    static let startMatch = "Start Match"
    static let toBeDetermined = "To Be Determined"
    static let arenaOpen = "The Arena is now open!"
    static let arenaBefore30Min = "Opens 30 minutes before Game Time"
    static let selectChar = "Select Character"
    static let matchNotFound = "Match not found"
    static let waitForConfirm = "Waiting for your opponent to Confirm."
    static let howToUseID = "How to Use the BattleArena ID"
    static let arenaClose = "The Arena is now closed"
    static let regular = "REGULAR"
    static let playoff = "PLAYOFF"
    static let tournament = "TOURNAMENT"
    //static let enterBattleId = "Please enter BattleArena ID."
    static let enterBattleId = "Please enter \(APIManager.sharedManager.gameSettings?.gameLabel ?? "")."
    
    static let waitForOppoToChoose = "Waiting for your opponent to select a option."
    
    static let arenaReset = "Arena reset by organizer"
    static let arenaResetMsg1 = "Due to a technical error, the match cannot continue in the Arena. The Organizer is currently reviewing the reported scores, if any, and will contact you to discuss next steps to complete the match, if necessary.\n\nYou can also contact the Organizer for further details here:"
    static let arenaResetMsg2 = "The Arena will be accessible for all future matches in this tournament. We apologize for the inconvenience."
    static let waitingToChar = "Waiting for your opponent to proceed."
    static let leaderboardCharNotAvailable = "Character(s) not available."
    static let forfeit = "Forfeit"
    static let forfeitMatch = "Forfeit Match"
    static let forfeitMsg = "Are you sure you want to forfeit this match ?"
    
    //Chat
    static let addAdminTitle = "Add Admin"
    static let addAdminMsg = "Are you sure you want to add a tournament administrator to this chat?"
    
    
    //Firestore keys
    
    //Arena status
    static let waitingToProceed = "Waiting to proceed"
    static let readyToProceed = "Ready to proceed"
    static let enteringBattleId = "Entering BattelArenaID"
    static let enteredBattleId = "Entered BattelArenaID"
    static let battleIdFail = "BattelArenaID failed"
    static let characterSelection = "Character Selection"
    static let selectRPC = "Select RPC"
    static let rpcResultDone = "RPC result done"
    static let stagePickBan = "Stage pick ban"
    static let playinRound = "Playing round"
    static let enteringScore = "Entering score"
    static let enteredScore = "Entered score"
    static let scoreConfirm = "Score confirmed"
    static let dispute = "Dispute"
    static let enterDisputeScore = "Entered dispute score"
    static let matchFinished = "Match finished"
    static let waitingToStagePickBan = "Waiting to Stage pick ban"
    
    static let waitingToCharacterSelection = "Waiting to character selection"
}
