//
//  SettingsView.swift
//  Tussly
//


import SwiftUI
import UIKit
import CropViewController
import CometChatSDK

// MARK: - User Profile Model
struct UserProfile {
    var displayName: String = ""
    var email: String = ""
    var username: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var gender: String = ""
    var avatarURL: String = ""
}

// MARK: - ViewModel
class SettingsViewModel: ObservableObject {
    @Published var profile = UserProfile()
    @Published var avatarImage: UIImage? = nil
    @Published var showImagePicker = false
    @Published var showLogoutConfirmation = false
    @Published var showDeleteConfirmation = false
    
    // Load from APIManager
    func loadProfile() {
        if let user = APIManager.sharedManager.user {
            profile.displayName = user.displayName ?? ""
            profile.email = user.email.isEmpty ? user.mobileNo : user.email
            profile.username = user.userName
            profile.firstName = user.firstName
            profile.lastName = user.lastName
            profile.gender = user.genderText ?? ""
            profile.avatarURL = user.avatarImage
        }
    }
    
    func saveProfile() {
        let params: [String: Any] = [
            "displayName": profile.displayName.trimmedString,
            "firstName": profile.firstName.trimmedString,
            "lastName": profile.lastName.trimmedString,
            "gender": profile.gender,
            "genderText": profile.gender
        ]
        
        APIManager.sharedManager.sendRequest(
            url: APIManager.sharedManager.EDIT_PROFILE,
            method: .post,
            parameters: params,
            auth: .bearer(token: APIManager.sharedManager.authToken)
        ) { (result: OptionalResult<ApiResponse>) in
            
            switch result {
            case .success(let response):
                if let response = response, response.status == 1 {
                    APIManager.sharedManager.user = response.result?.userDetail
                    Utilities.showPopup(title: "Profile edited successfully", type: .success)
                } else {
                    Utilities.showPopup(title: response?.message ?? "Error", type: .error)
                }
                
            case .failure(let error):
                Utilities.showPopup(title: error?.localizedDescription ?? "Unknown error", type: .error)
            }
        }
    }
    
    func logout() {
        // Wrap your CometChat + API logout
        print("Logout tapped")
    }
    
    func deleteAccount() {
        // Wrap your API delete account
        print("Delete Account tapped")
    }
    
    func uploadImage(_ image: UIImage) {
        APIManager.sharedManager.uploadImage(
            url: APIManager.sharedManager.UPLOAD_IMAGE,
            fileName: "image",
            image: image,
            type: "AvatarImage",
            id: APIManager.sharedManager.user?.id ?? 0
        ) { success, response, message in
            if success {
                DispatchQueue.main.async {
                    self.profile.avatarURL = response?["filePath"] as? String ?? ""
                    Utilities.showPopup(title: "Avatar updated", type: .success)
                }
            } else {
                Utilities.showPopup(title: message ?? "", type: .error)
            }
        }
    }
}

// MARK: - SwiftUI SettingsView
struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        if #available(iOS 15.0, *) {
            ScrollView {
                VStack(spacing: 20) {
                    
                    // Profile Image
                    Button {
                        viewModel.showImagePicker = true
                    } label: {
                        if let avatar = viewModel.avatarImage {
                            Image(uiImage: avatar)
                                .resizable()
                                .scaledToFill()
                                .frame(width: (UIScreen.main.bounds.width / 5) * 2.5, height: (UIScreen.main.bounds.width / 5) * 2.5)
                                .clipShape(Circle())
                        } else {
                            AsyncImage(url: URL(string: viewModel.profile.avatarURL)) { phase in
                                if let img = phase.image {
                                    img.resizable()
                                } else {
                                    Color.gray
                                }
                            }
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.width / 5) * 2.5, height: (UIScreen.main.bounds.width / 5) * 2.5)
                            .clipShape(Circle())
                        }
                    }
                    
                    // Text Fields
                    Group {
                        TextField("Display Name", text: $viewModel.profile.displayName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("First Name", text: $viewModel.profile.firstName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Last Name", text: $viewModel.profile.lastName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Gender", text: $viewModel.profile.gender)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .disableAutocorrection(true)
                    }
                    
                    // Save Button
                    Button("Save Changes") {
                        viewModel.saveProfile()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    // Account Actions
                    VStack(spacing: 10) {
                        Button("Change Password") {
                            // Navigate to ChangePasswordVC
                            if let topVC = UIApplication.shared.windows.first?.rootViewController {
                                let vc = UIStoryboard(name: "Main", bundle: nil)
                                    .instantiateViewController(withIdentifier: "ChangePasswordVC")
                                topVC.navigationController?.pushViewController(vc, animated: true)
                            }
                        }
                        Button("Log Out", role: .destructive) {
                            viewModel.showLogoutConfirmation = true
                        }
                        
                        Button("Delete Account", role: .destructive) {
                            viewModel.showDeleteConfirmation = true
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.loadProfile()
            }
            .alert("Log Out?", isPresented: $viewModel.showLogoutConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Log Out", role: .destructive) {
                    //viewModel.logout()
                    self.cometChatUnregisterPushToken()
                }
            }
            .alert("Delete Account?", isPresented: $viewModel.showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    viewModel.deleteAccount()
                }
            }
            .sheet(isPresented: $viewModel.showImagePicker) {
                ImagePickerWithCrop { image in
                    if let img = image {
                        viewModel.avatarImage = img
                        viewModel.uploadImage(img)
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    func cometChatUnregisterPushToken() {
        CometChatNotifications.unregisterPushToken { success in
            print("unregisterPushToken: \(success)")
            self.cometChatLogout()
        } onError: { error in
            print("unregisterPushToken: \(error.errorCode) \(error.errorDescription)")
            self.cometChatLogout()
        }
    }
    
    func cometChatLogout(count: Int = 1)  {
        print("Logout tapped...")
        if CometChat.getLoggedInUser() != nil {
            CometChat.logout { Response in
                print("CometChat Logout successful.")
                self.userLogout()
            } onError: { (error) in
                print("CometChat Logout failed with error: " + error.errorDescription);
                let temp = count + 1
                if temp < 3 {
                    self.cometChatLogout(count: temp)
                }
                else {
                    Utilities.showPopup(title: "Chat service is temporarily unavailable.", type: .error)
                    self.userLogout()
                }
            }
        }
        else {
            self.userLogout()
        }
    }
    
    func userLogout() {
        
//        if !Network.reachability.isReachable {
//            self.isRetryInternet { (isretry) in
//                if isretry! {
//                    self.userLogout()
//                }
//            }
//            return
//        }
        
//        showLoading()
        
        let param = [
            "deviceId": AppInfo.DeviceId.returnAppInfo()
        ] as [String: Any]
        APIManager.sharedManager.postData(url: APIManager.sharedManager.LOGOUT, parameters: param) { (response: ApiResponse?, error) in
            if ((response?.status) != nil) {
                Utilities.showPopup(title: response?.message ?? "", type: .success)
            } else {
//                self.hideLoading()
                Utilities.showPopup(title: response?.message ?? "", type: .error)
            }
            APIManager.sharedManager.user = nil
            APIManager.sharedManager.authToken = ""
            UserDefaults.standard.removeObject(forKey: UserDefaultType.accessToken)
            UserDefaults.standard.synchronize()
            // By Pranay
            //APIManager.sharedManager.intNotificationCount = 0
            UserDefaults.standard.set(0, forKey: UserDefaultType.notificationCount)
//            self.tusslyTabVC!().notificationCount()
//            self.tusslyTabVC!().chatNotificationCount()
            // .
//            DispatchQueue.main.async {
//                appDelegate.isAutoLogin = false
//                self.view.tusslyTabVC.selectedIndex = 0
//                self.view!.tusslyTabVC.leagueConsoleId = -1
//                self.view!.tusslyTabVC.logoLeadingConstant = 16
//                self.hideLoading()
//                appDelegate.isAutoLogin = false
//                self.view.tusslyTabVC.loadTabsOfHomeScreen(isUserLoggedIn: false)
//            }
        }
    }
}


struct ImagePickerWithCrop: UIViewControllerRepresentable {
    var completion: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
        var completion: (UIImage?) -> Void
        var parentVC: UIViewController?
        
        init(completion: @escaping (UIImage?) -> Void) {
            self.completion = completion
        }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            picker.dismiss(animated: true) {
                if let image = info[.originalImage] as? UIImage {
                    let cropVC = CropViewController(image: image)
                    cropVC.delegate = self
                    picker.present(cropVC, animated: true)
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
            completion(nil)
        }
        
        // MARK: CropViewControllerDelegate
        func cropViewController(_ cropViewController: CropViewController,
                                didCropToImage image: UIImage,
                                withRect cropRect: CGRect,
                                angle: Int) {
            cropViewController.dismiss(animated: true)
            completion(image)
        }
        
        func cropViewController(_ cropViewController: CropViewController,
                                didFinishCancelled cancelled: Bool) {
            cropViewController.dismiss(animated: true)
            completion(nil)
        }
    }
}
