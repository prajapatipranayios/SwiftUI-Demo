//
//  Constants.swift
//  FoodFlocker
//
//  Created by Jaimesh Patel on 25/02/20.
//  Copyright © 2020 Auxano. All rights reserved.
//

import Foundation

let MIN_BANK_ACC_NO_LENGTH = 10
let MAX_BANK_ACC_NO_LENGTH = 15

let MIN_MOBILE_LENGTH = 7
let MAX_MOBILE_LENGTH = 15
let MIN_PASSWORD_LENGTH = 6
let MAX_PASSWORD_LENGTH = 12
let MIN_USERNAME_LENGTH = 3
let MAX_USERNAME_LENGTH = 30
let ABN_LENGTH = 14
let TEXTFIELD_LIMIT = 50
let INGREDIANT_LIMIT = 100
let TEXTVIEW_LIMIT = 500
let MAX_DAYS_LENGTH = 3
let MAX_HOURS_LENGTH = 2
let MAX_QUANTITY_LENGTH = 50
let GOOGLE_AUTO_FILTER_BASE_URL = "https://maps.googleapis.com/maps/api/place/autocomplete/json"

var screenSize: CGFloat = 0.0

// For Validation Message
let Valid_Email = "Please enter valid Email Address"
let Valid_Mobile = "Please enter valid Mobile Number"
let Valid_Password = "Please enter password between 6 to 12 characters"
let Confirm_Password_Not_Match = "New Password and Confirm Password doesn't match"
let Empty_OTP = "Verification Code must be of 4 digits"
let Valid_OTP = "Your entered Code is incorrect"
let Valid_ABN = "Please enter valid ABN"
let Valid_Name = "Please enter minimum 3 chars"

let Valid_Bank_Acc_No = "Please enter valid Bank Account Number"
let Valid_Bank_BSB_Code = "Please enter valid BSB Code"

let Valid_Card_Number = "Please enter valid Card Number"
let Valid_Card_Name = "Please enter valid Card Holder's Name"
let Valid_Card_CVV = "Please enter valid CVV"
let Valid_Card_ExpiryDate = "Please enter valid Expiry Date"

// For User Default
struct UserDefaultType {
//    static let logInParameters = "LogInParameters"
    static let isFirstTimeOnly = "isFirstTimeOnly"
    static let accessToken = "accessToken"
    static let fcmToken = "fcmToken"
    static let notification = "notification"
}
