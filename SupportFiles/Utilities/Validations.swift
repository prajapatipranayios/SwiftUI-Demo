//
//  Validations.swift
//  Shela
//
//  Created by Ankit on 27/12/18.
//  Copyright © 2018 ankit. All rights reserved.
//

import Foundation
//enum ValidationResult {
//    case success
//    case failure(Alert,String)
//}
class Validations {
    
    static func isValid(email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    static func isValidPhone(testStr:String) -> Bool {
        let phoneRegEx = "^[6-9]\\d{9}$"
        let phoneNumber = NSPredicate(format:"SELF MATCHES %@", phoneRegEx)
        return phoneNumber.evaluate(with: testStr)
    }
    
    static func isValidPAN(_ pan: String) -> Bool {
        let panRegex = "[A-Z]{5}[0-9]{4}[A-Z]{1}"
        return NSPredicate(format: "SELF MATCHES %@", panRegex).evaluate(with: pan)
    }
    
    static func isValidZip(_ zip: String) -> Bool {
        let checkRegex = "^[0-9]{6}$"
        return NSPredicate(format: "SELF MATCHES %@", checkRegex).evaluate(with: zip)
    }
    
    static func isValidGSTNo(_ gstNo: String) -> Bool {
        let GSTNoRegex = "^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$"
        return NSPredicate(format: "SELF MATCHES %@", GSTNoRegex).evaluate(with: gstNo)
    }
    
    
    
    static func isValidScanNo(_ no: String) -> Bool {
        /*sCreate a regex pattern to validate the number as written below:
        regex= “^[+]{1}(?:[0-9\-\(\)\/\.]\s?){6, 15}[0-9]{1}$”
        Where,
        ^ : start of the string
        [+]{1} :Matches a “+”  character, matches exactly one of the preceding item
        (?:): :Groups multiple tokens together without creating a capture group.
        [0-9\-\(\)\/\.] : matches   any character in the set from 0 to 9, “-“, “(“, “)”, “/”, and “.” .
        \\s : match a white space character
        ? : matches 0 or 1 of the preceding item.
        {6, 14} : This expression will match 6 to 14 of the preceding item.
        [0-9] : This will match values from 0 to 9
        {1} : This expression will match exactly one of the preceding item.
        $ : End of the string.  //  */
        //let NoRegex = "^[+]{1}(?:[0-9\\-\\(\\)\\/\\.]\\s?){6, 15}[0-9]{1}$"
        let NoRegex = "^((\\+)|(00))[0-9]{6,14}$"
        //let NoRegex = "^([0|\\+[0-9]{1,5})?([7-9][0-9]{9})$"
        return NSPredicate(format: "SELF MATCHES %@", NoRegex).evaluate(with: no)
    }
    
    static func isValidPassword(_ password: String) -> Bool {
        ///Minimum eight characters, at least one letter and one number:
        //"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$"
        
        ///Minimum eight characters, at least one letter, one number and one special character:
        //"^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$"
        
        ///Minimum eight characters, at least one uppercase letter, one lowercase letter and one number:
        //"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$"
        
        ///Minimum eight characters, at least one uppercase letter, one lowercase letter, one number and one special character:
        //"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$"
        
        ///Minimum eight and maximum 10 characters, at least one uppercase letter, one lowercase letter, one number and one special character:
        //"^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,10}$"
        
        ///Minimum 8 characters at least 1 Alphabet and 1 Number
        //"^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        
        ///Minimum 8 characters at least 1 Alphabet, 1 Number and 1 Special Character
        //"^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,}$"
        
        ///Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet and 1 Number
        //"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[a-zA-Z\\d]{8,}$"
        
        ///Minimum 8 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character
        //"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[d$@$!%*?&#])[A-Za-z\\dd$@$!%*?&#]{8,}"
        
        ///Minimum 8 and Maximum 10 characters at least 1 Uppercase Alphabet, 1 Lowercase Alphabet, 1 Number and 1 Special Character
        //"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&#])[A-Za-z\\d$@$!%*?&#]{8,10}"
        
        /// least one uppercase,
        /// least one digit
        /// least one lowercase
        /// least one symbol
        /// min 8 characters total
        //"^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&<>*~:`-]).{8,}$"
        
        /*
         // Password validation
         https://medium.com/swlh/password-validation-in-swift-5-3de161569910
         */
        
        /*
         ^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$
         This regex will enforce these rules:

         At least one upper case English letter, (?=.*?[A-Z])
         At least one lower case English letter, (?=.*?[a-z])
         At least one digit, (?=.*?[0-9])
         At least one special character, (?=.*?[#?!@$%^&*-])
         Minimum eight in length .{8,} (with the anchors)
         
         Regex Explanation : -
         ^                         Start anchor
         (?=.*[A-Z].*[A-Z])        Ensure string has two uppercase letters.
         (?=.*[!@#$&*])            Ensure string has one special case letter.
         (?=.*[0-9].*[0-9])        Ensure string has two digits.
         (?=.*[a-z].*[a-z].*[a-z]) Ensure string has three lowercase letters.
         .{8}                      Ensure string is of length 8.
         $                         End anchor.
         */
        
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}
