//
//  CameraUtility.swift
//  All Utility
//
//  Created by Cpt n3m0 on 17/09/24.
//

import Foundation
import UIKit
import AVFoundation


// MARK: - Single Image

class CameraUtilitySingleImage: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var viewController: UIViewController!
    private var completion: ((UIImage?) -> Void)?
    
    // Singleton for easy access in multiple projects
    static let shared = CameraUtilitySingleImage()
    
    // Function to show image picker with camera option based on a flag
    func showImagePicker(from viewController: UIViewController, allowsEditing: Bool = false, isSelectImageFromCamera: Bool, completion: @escaping (UIImage?) -> Void) {
        self.viewController = viewController
        self.completion = completion
        
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        // Conditionally add the camera option based on the flag and its availability
        if isSelectImageFromCamera, UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera(allowsEditing: allowsEditing)
            }))
        }
        
        // Always add the photo library option if it's available
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.openPhotoLibrary(allowsEditing: allowsEditing)
            }))
        }
        
        // Add the cancel option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func openCamera(allowsEditing: Bool) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            presentImagePicker(sourceType: .camera, allowsEditing: allowsEditing)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.presentImagePicker(sourceType: .camera, allowsEditing: allowsEditing)
                }
            }
        default:
            showPermissionDeniedAlert()
        }
    }
    
    private func openPhotoLibrary(allowsEditing: Bool) {
        presentImagePicker(sourceType: .photoLibrary, allowsEditing: allowsEditing)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType, allowsEditing: Bool) {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = allowsEditing
            self.viewController.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera Access Denied",
            message: "Please enable camera access in Settings",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        picker.dismiss(animated: true) {
            self.completion?(selectedImage)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.completion?(nil)
        }
    }
}



// MARK: - Multi Image

class CameraUtilityMultiImage: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private var viewController: UIViewController!
    private var completion: (([UIImage]?, [URL]?) -> Void)?
    private var selectedImages: [(image: UIImage, url: URL?)] = [] // Tuple to store selected images and their URLs
    private var maxImageCount: Int? // Optional limit (nil means no limit)
    
    // Singleton for easy access
    static let shared = CameraUtilityMultiImage()
    
    // Function to show image picker with camera option based on a flag
    func showImagePicker(from viewController: UIViewController, allowsEditing: Bool = false, isSelectImageFromCamera: Bool = false, isSelectImageFromPhotoLibrary: Bool = true, maxImageCount: Int? = nil, completion: @escaping ([UIImage]?, [URL]?) -> Void) {
        self.viewController = viewController
        self.completion = completion
        self.maxImageCount = maxImageCount // Set maxImageCount (or nil if no limit)
        
        let alert = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)
        
        // Conditionally add the camera option based on the flag and its availability
        if isSelectImageFromCamera, UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                self.openCamera(allowsEditing: allowsEditing)
            }))
        }
        
        // Always add the photo library option if it's available
        if isSelectImageFromPhotoLibrary, UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                self.openPhotoLibrary(allowsEditing: allowsEditing)
            }))
        }
        
        // Add the cancel option
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        viewController.present(alert, animated: true, completion: nil)
    }
    
    private func openCamera(allowsEditing: Bool) {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            presentImagePicker(sourceType: .camera, allowsEditing: allowsEditing)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.presentImagePicker(sourceType: .camera, allowsEditing: allowsEditing)
                }
            }
        default:
            showPermissionDeniedAlert()
        }
    }
    
    private func openPhotoLibrary(allowsEditing: Bool) {
        // If there is a maxImageCount and it has been reached, show the limit alert
        if let maxCount = maxImageCount, selectedImages.count >= maxCount {
            showMaxLimitReachedAlert()
        } else {
            presentImagePicker(sourceType: .photoLibrary, allowsEditing: allowsEditing)
        }
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType, allowsEditing: Bool) {
        DispatchQueue.main.async {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = allowsEditing
            self.viewController.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "Camera Access Denied",
            message: "Please enable camera access in Settings",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    private func showMaxLimitReachedAlert() {
        let alert = UIAlertController(
            title: "Limit Reached",
            message: "You can only select up to \(maxImageCount ?? 0) images.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    private func showDuplicateImageAlert() {
        let alert = UIAlertController(
            title: "Duplicate Image",
            message: "You've already selected this image. Please select a different image.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Image Deletion Handling
    
    func deleteSelectedImage(at index: Int) {
        if index < selectedImages.count {
            selectedImages.remove(at: index)
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage?
        var selectedImageURL: URL?
        
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        // Get the image URL if it comes from the photo library
        if picker.sourceType == .photoLibrary {
            if let imageURL = info[.imageURL] as? URL {
                selectedImageURL = imageURL
            }
        }
        
        // If the image comes from the camera, save it to a temporary directory and generate a URL
        if picker.sourceType == .camera {
            if let newImage = selectedImage {
                selectedImageURL = saveImageToTemporaryDirectory(image: newImage)
            }
        }
        
        picker.dismiss(animated: true) {
            if let newImage = selectedImage {
                // Check for duplicate images
                if self.selectedImages.contains(where: { $0.image.pngData() == newImage.pngData() }) {
                    // Show duplicate image alert
                    self.showDuplicateImageAlert()
                } else if let maxCount = self.maxImageCount, self.selectedImages.count >= maxCount {
                    // If max count is set and reached, show limit alert
                    self.showMaxLimitReachedAlert()
                } else {
                    // Add the image and its URL to the selected array if no max count limit reached
                    self.selectedImages.append((image: newImage, url: selectedImageURL))
                    
                    // Extract image array and URL array from selectedImages
                    let images = self.selectedImages.map { $0.image }
                    let urls = self.selectedImages.compactMap { $0.url }
                    
                    self.completion?(images, urls)
                }
            } else {
                self.completion?(nil, nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            self.completion?(nil, nil)
        }
    }
    
    // Helper method to save the captured image to a temporary directory and return its URL
    private func saveImageToTemporaryDirectory(image: UIImage) -> URL? {
        let tempDirectory = FileManager.default.temporaryDirectory
        let imageName = UUID().uuidString + ".png"
        let imageURL = tempDirectory.appendingPathComponent(imageName)
        
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            do {
                try imageData.write(to: imageURL)
                return imageURL
            } catch {
                print("Error saving image: \(error)")
            }
        }
        return nil
    }
}






// MARK: - To Use It

/*class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        let isSelectImageFromCamera = false
        
        CameraUtilitySingleImage.shared.showImagePicker(from: self) { image in
            if let capturedImage = image {
                // Do something with the captured image
                print("Image captured: \(capturedImage)")
            } else {
                print("No image captured.")
            }
        }
        
        // Case 1: No limit on image selection
        CameraUtilityMultiImage.shared.showImagePicker(from: self, allowsEditing: false, isSelectImageFromCamera: isSelectImageFromCamera, maxImageCount: nil) { images, urls in
            if let selectedImages = images, let selectedURLs = urls {
                // Do something with the selected images and their URLs
                print("Selected images: \(selectedImages.count)")
                print("Selected URLs: \(selectedURLs)")
            } else {
                print("No images selected.")
            }
        }
        
        // Case 2: Limit to 5 images
        CameraUtilityMultiImage.shared.showImagePicker(from: self, allowsEditing: false, isSelectImageFromCamera: isSelectImageFromCamera, maxImageCount: 5) { images, urls in
            if let selectedImages = images, let selectedURLs = urls {
                // Do something with the selected images and their URLs
                print("Selected images: \(selectedImages.count)")
                print("Selected URLs: \(selectedURLs)")
            } else {
                print("No images selected.")
            }
        }
    }
    
    @IBAction func deleteImageButtonTapped(_ sender: UIButton) {
        let indexToDelete = 2 // For example, deleting the image at index 2
        CameraUtility.shared.deleteSelectedImage(at: indexToDelete)
        print("Image at index \(indexToDelete) deleted.")
    }
}
/// */
