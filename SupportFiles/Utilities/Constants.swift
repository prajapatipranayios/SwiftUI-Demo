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
let MIN_USERNAME_LENGTH = 3
let MAX_PASSWORD_LENGTH = 20
//let MIN_MOBILE_LENGTH = 10
let MIN_MOBILE_LENGTH = 10
let MAX_MOBILE_LENGTH = 10
let MIN_TELE_LENGTH = 15
let MAX_TELE_LENGTH = 15
let MAX_PAN_LENGTH = 10
let MAX_ZIP_LENGTH = 6

// For Error Messages
let No_Camera = "Sorry, this device has no camera."
let Network_Error = "No Internet Connection"

// For Validation Message
let Valid_Email = "Please enter valid email address"
let Valid_Forgot_Email = "Invalid email address"
let Valid_Telephone = "Please enter valid telephone number"
let Valid_Mobile = "Please enter valid Mobile Number"
let Valid_Password = "Please enter password between 8 to 20 characters"
let Confirm_Password_Not_Match = "Password and Confirm Password doesn't match"

let Valid_CompanyType = "Please select company type"
let Valid_SelectBranch = "Please select branch"
let Valid_IndustriesCategory = "Please select industries category"
let Valid_BusinessType = "Please select business type"
let Valid_TypesOfFirms = "Please select types of firms"
let Valid_PAN = "Please enter valid pan no"
let Valid_AddBPSelectState = "Please select state"
let Valid_AddBPSelectCity = "Please select city"
let Valid_Zip = "Please enter valid zipcode"
let Valid_GSTNo = "Please enter valid GST no"

//let Valid_OrderSelectBP = ""

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
    static let userId = "userId"
    static let userRole = "userRole"
    static let fcmToken = "fcmToken"
    static let currentSection = "currentSection"
    static let currentRow = "currentRow"
    
    static let notificationCount = "com.app.Tussly"
    static let forBetaPopup = "betaVersionPopupActive"
    static let forDisputePopup = "DisputePopupActive"
    static let updateVersion = "UpdateVersion"
}

//Notification Types
struct NotificationType {
    
}

struct Title {
    //  Product History
    static let ProductCatePopupTitle = "Select Items"
    static let BPCreditDaysTitle = "Credit Days"
    static let BPATurnoverTitle = "Annual Turnover"
    static let BPCompanyTypeTitle = "Company Type"
    static let BPBrachTitle = "Branch"
    static let BPBusinessTypeTitle = "Business Type"
    static let BPTypesOfFirmTitle = "Types Of Firm"
    static let BPIndustriesCategoryTitle = "Industries Category"
    static let BPSSalesPersonTitle = "Select Sales Person"
    static let BPSelectStateTitle = "Select State"
    static let BPSelectCityTitle = "Select City"
    static let ConfirmationPopupTitle = "Novasol Ingredients"
    static let SelectBP = "Select Business Partner"
    static let SelectEmployee = "Select Employee"
    static let QuotationValidity = "Quotation Validity"
    
    // Sales Order
    static let BookingPoint = "Booking Point"
    static let SelectFollowUpDays = "Select FollowUp Days"
    static let SelectOrderAttachment = "Select Attachment"
    
    // Follow Up
    static let SelectProductStatus = "Product Status"
}

struct Messages {
    
    // MARK: User story board
    // GE Sales
    static let GeSales = "GE Sales"
    static let SelectStartDate = "Please Select Start Date."
    static let AddBPTransporterMsg = "You can add upto 3 transporters."
    
    // Business Partner Details
    static let NoPermission = "You does not have permission to see business parter "
    static let PleaseSelectSEDate = "Please select Start Date and End Date."
    
    // Sales Order
    static let SelectVerifiedBP = "Selected business partner not verify !!"
    static let SelectBP = "Please select business partner first."
    
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
