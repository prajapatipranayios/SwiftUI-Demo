//
//  ChatMessageVC_Extension.swift
//  Tussly
//
//  Created by Auxano on 22/04/25.
//  Copyright © 2025 Auxano. All rights reserved.
//

import Foundation
import UIKit
import CropViewController
import CometChatSDK
import UniformTypeIdentifiers
import MobileCoreServices


// MARK: - For Attachment
extension ChatMessageVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate {
    
    func openCamera() {
        let imagePickerController =  UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .overFullScreen
        imagePickerController.sourceType = UIImagePickerController.SourceType.camera
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera)) {
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func openGallary() {
        let imagePickerController =  UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.modalPresentationStyle = .overFullScreen
        imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)) {
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            dismiss(animated:true, completion: nil)
            return
        }
        self.dismiss(animated: true) {
            let cropViewController = CropViewController(image: image)
            cropViewController.toolbarPosition = .top
            cropViewController.resetButtonHidden = true
            cropViewController.rotateButtonsHidden = true
            cropViewController.aspectRatioPickerButtonHidden = true
            cropViewController.delegate = self
            let navController = UINavigationController(rootViewController: cropViewController)
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: true) {
            //self.ivLogo.image = image
            //self.uploadImage(type: "AvatarImage", image: image)
            
            if let imageURL = self.getTempImageURL(from: image) {
                print("Temporary URL: \(imageURL)")
                // Send image to CometChat MediaMessage using `imageURL`
                //self.sendCometChatMediaMessage(with: imageURL)
                self.sendMedia(mediaUrl: imageURL, msgType: .image)
            }
        }
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        cropViewController.dismiss(animated: true, completion: nil)
    }
    
    func getTempImageURL(from image: UIImage) -> URL? {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return nil }
        
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "cropped_avatar_\(UUID().uuidString).jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try imageData.write(to: fileURL)
            return fileURL
        } catch {
            print("Failed to write image to temp URL: \(error)")
            return nil
        }
    }
    
    func sendMedia(mediaUrl: URL, msgType: CometChat.MessageType = .image) {
        let mediaMessage = MediaMessage(receiverUid: self.receiverId ?? "",
                                        fileurl: mediaUrl.absoluteString,
                                        messageType: msgType,
                                        receiverType: self.isGroup ? .group : .user);
        
        print("Media Url -- \(mediaUrl.absoluteString)")
        
        self.showLoading()
        
        CometChat.sendMediaMessage(message: mediaMessage, onSuccess: { (message) in
            print("MediaMessage sent successfully. " + message.stringValue())
            
            if self.arrMessages.count < 1 {
                self.removeNoDataLabels()
            }
            
            self.arrMessages.append(message)
            
            DispatchQueue.main.async {
                self.isAttachMedia = true
                self.btnSendMessage.setImage(UIImage(named: "imgAttach"), for: .normal)
                
                self.hideLoading()
                
                self.tvMessageList.reloadData()
                
                self.shouldAutoScroll = true
                self.scrollToBottom()
            }
        }) { (error) in
            print("MediaMessage sending failed with error: " + (error?.errorDescription ?? ""))
            self.hideLoading()
        }
    }
}

extension ChatMessageVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.arrMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = self.arrMessages[indexPath.row]
        
        if message.readAt <= 0 {
            CometChat.markAsRead(baseMessage: message)
        }
        
        let strMsgDate = self.getMessageDate(with: message)
        var strPreviousMsgDate = ""
        if indexPath.row > 0 {
            strPreviousMsgDate = self.getMessageDate(with: (self.arrMessages[indexPath.row - 1]))
        }
        
        var isShowDateLabel: Bool = true
        if strMsgDate == strPreviousMsgDate {
            isShowDateLabel = false
        }
        
        if let action = message as? ActionMessage {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ActionMessageBubbleTVCell", for: indexPath) as! ActionMessageBubbleTVCell
            
            cell.viewDateSection.isHidden = !isShowDateLabel
            cell.constraintTopViewMsgToSuper.priority = isShowDateLabel ? .defaultLow : .required
            cell.lblDateSection.text = strMsgDate
            cell.selectionStyle = .none
            cell.lblMsg.text = action.message ?? ""
            cell.isUserInteractionEnabled = false
            
            //print(action.action?.rawValue)
            
            return cell
        }
        else if message.senderUid == senderId {
            if let textMessage = message as? TextMessage {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SenderMessageBubbleTVCell", for: indexPath) as! SenderMessageBubbleTVCell
                self.configureSenderTextCell(cell, with: message)
                cell.viewDateSection.isHidden = !isShowDateLabel
                cell.constraintTopViewMsgToSuper.priority = isShowDateLabel ? .defaultLow : .required
                cell.lblDateSection.text = strMsgDate
                cell.selectionStyle = .none
                
                if textMessage.deletedAt > 0 {
                    cell.lblMsg.attributedText = Utilities.attributedTextWithImage(text: "This message was deleted.", image: UIImage(named: "banWhite") ?? UIImage(), imageSize: CGSize(width: 16, height: 16))
                    cell.constraintBottomViewMsgToSuper.priority = .required
                    cell.btnReply.isHidden = true
                }
                else {
                    cell.constraintBottomViewMsgToSuper.priority = (message.replyCount > 0) ? .defaultLow : .required
                    cell.btnReply.isHidden = (message.replyCount > 0) ? false : true
                    
                    if message.replyCount > 0 {
                        let reply = (message.replyCount == 1) ? "1 Reply" : "\(message.replyCount) Replies"
                        let title = Utilities.attributedTextWithImage(
                            text: reply,
                            image: UIImage(named: "replyRtoL") ?? UIImage(),
                            imageSize: CGSize(width: 16, height: 16),
                            imagePosition: .right,
                            imageColor: Colors.theme.returnColor(),
                            textStyle: .bold)
                        cell.btnReply.tag = indexPath.row
                        cell.btnReply.setAttributedTitle(title, for: .normal)
                        cell.btnReply.addTarget(self, action: #selector(didTapReplyButton(_:)), for: .touchUpInside)
                    }
                }
                return cell
            }
            else if let mediaMessage = message as? MediaMessage {
                if mediaMessage.messageType == .image {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SenderImageMessageBubbleTVCell", for: indexPath) as! SenderImageMessageBubbleTVCell
                    self.configureSenderImageCell(cell, with: message)
                    cell.viewDateSection.isHidden = !isShowDateLabel
                    cell.constraintTopViewMsgToSuper.priority = isShowDateLabel ? .defaultLow : .required
                    cell.lblDateSection.text = strMsgDate
                    cell.selectionStyle = .none
                    
                    cell.lblMsg.isHidden = true
                    cell.ivImage.isHidden = false
                    cell.constraintBottomIvImageToLblTime.priority = .required
                    cell.constraintTrailIvImageToSuper.priority = .required
                    if mediaMessage.deletedAt > 0 {
                        cell.constraintBottomIvImageToLblTime.priority = .defaultLow
                        cell.constraintTrailIvImageToSuper.priority = .defaultLow
                        cell.lblMsg.isHidden = false
                        cell.ivImage.isHidden = true
                        cell.lblMsg.attributedText = Utilities.attributedTextWithImage(text: "This message was deleted.", image: UIImage(named: "banWhite") ?? UIImage(), imageSize: CGSize(width: 16, height: 16))
                        
                        cell.ivImage.isUserInteractionEnabled = false
                        
                        cell.constraintBottomViewMsgToSuper.priority = .required
                        cell.btnReply.isHidden = true
                    }
                    else {
                        /// To display reply count
                        cell.constraintBottomViewMsgToSuper.priority = (message.replyCount > 0) ? .defaultLow : .required
                        cell.btnReply.isHidden = (message.replyCount > 0) ? false : true
                        
                        if message.replyCount > 0 {
                            let reply = (message.replyCount == 1) ? "1 Reply" : "\(message.replyCount) Replies"
                            let title = Utilities.attributedTextWithImage(
                                text: reply,
                                image: UIImage(named: "replyRtoL") ?? UIImage(),
                                imageSize: CGSize(width: 16, height: 16),
                                imagePosition: .right,
                                imageColor: Colors.theme.returnColor(),
                                textStyle: .bold)
                            cell.btnReply.tag = indexPath.row
                            cell.btnReply.setAttributedTitle(title, for: .normal)
                            cell.btnReply.addTarget(self, action: #selector(didTapReplyButton(_:)), for: .touchUpInside)
                        }
                        
                        /// Tap to open image
                        cell.ivImage.tag = indexPath.row
                        cell.ivImage.isUserInteractionEnabled = true
                        cell.ivImage.gestureRecognizers?.forEach { cell.ivImage.removeGestureRecognizer($0) } // avoid duplicate
                        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
                        cell.ivImage.addGestureRecognizer(tap)
                    }
                    return cell
                }
                else if mediaMessage.messageType == .file {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SenderDocumentMessageBubbleTVCell", for: indexPath) as! SenderDocumentMessageBubbleTVCell
                    self.configureSenderDocumentCell(cell, with: message)
                    cell.viewDateSection.isHidden = !isShowDateLabel
                    cell.constraintTopViewMsgToSuper.priority = isShowDateLabel ? .defaultLow : .required
                    cell.lblDateSection.text = strMsgDate
                    cell.selectionStyle = .none
                    cell.ivImage.isHidden = false
                    
                    if mediaMessage.deletedAt > 0 {
                        //cell.lblMsg.text = "This message was deleted"
                        print("This message was deleted")
                        cell.ivImage.isHidden = true
                        cell.lblDocumentName.attributedText = Utilities.attributedTextWithImage(
                            text: "This message was deleted.",
                            image: UIImage(named: "banWhite") ?? UIImage(),
                            imageSize: CGSize(width: 16, height: 16),
                            textStyle: .regular)
                        
                        cell.contentView.isUserInteractionEnabled = false
                        
                        cell.constraintBottomViewMsgToSuper.priority = .required
                        cell.btnReply.isHidden = true
                    }
                    else {
                        /// To display reply count
                        cell.constraintBottomViewMsgToSuper.priority = (message.replyCount > 0) ? .defaultLow : .required
                        cell.btnReply.isHidden = (message.replyCount > 0) ? false : true
                        
                        if message.replyCount > 0 {
                            let reply = (message.replyCount == 1) ? "1 Reply" : "\(message.replyCount) Replies"
                            let title = Utilities.attributedTextWithImage(
                                text: reply,
                                image: UIImage(named: "replyRtoL") ?? UIImage(),
                                imageSize: CGSize(width: 16, height: 16),
                                imagePosition: .right,
                                imageColor: Colors.theme.returnColor(),
                                textStyle: .bold)
                            cell.btnReply.tag = indexPath.row
                            cell.btnReply.setAttributedTitle(title, for: .normal)
                            cell.btnReply.addTarget(self, action: #selector(didTapReplyButton(_:)), for: .touchUpInside)
                        }
                        
                        /// Tap to open document
                        cell.contentView.tag = indexPath.row
                        cell.contentView.isUserInteractionEnabled = true
                        cell.contentView.gestureRecognizers?.forEach { cell.contentView.removeGestureRecognizer($0) }
                        let tap = UITapGestureRecognizer(target: self, action: #selector(handleFileTap(_:)))
                        cell.contentView.addGestureRecognizer(tap)
                    }
                    return cell
                }
            }
        }
        else {  //  Receiver cell
            if let textMessage = message as? TextMessage {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverMessageBubbleTVCell", for: indexPath) as! ReceiverMessageBubbleTVCell
                self.configureReceiverTextCell(cell, with: message)
                cell.viewDateSection.isHidden = !isShowDateLabel
                //cell.constraintTopViewMsgToSuper.priority = isShowDateLabel ? .defaultLow : .required
                if !self.isGroup {
                    cell.constraintTopViewMsgToSuper.priority = isShowDateLabel ? .defaultLow : .required
                }
                else {
                    cell.constraintTopViewMsgToViewDateSection.priority = .defaultLow
                    cell.constraintTopLblUserNameToViewDateSection.priority = isShowDateLabel ? .required : .defaultLow
                    cell.constraintTopLblUserNameToSuper.priority = isShowDateLabel ? .defaultLow : .required
                }
                cell.lblDateSection.text = strMsgDate
                cell.selectionStyle = .none
                
                if textMessage.deletedAt > 0 {
                    //cell.lblMsg.text = "This message was deleted"
                    cell.lblMsg.attributedText = Utilities.attributedTextWithImage(text: "This message was deleted.", image: UIImage(named: "banWhite") ?? UIImage(), imageSize: CGSize(width: 16, height: 16))
                    
                    cell.constraintBottomViewMsgToSuper.priority = .required
                    cell.btnReply.isHidden = true
                }
                else {
                    /// To display reply count
                    cell.constraintBottomViewMsgToSuper.priority = (message.replyCount > 0) ? .defaultLow : .required
                    cell.btnReply.isHidden = (message.replyCount > 0) ? false : true
                    
                    if message.replyCount > 0 {
                        let reply = (message.replyCount == 1) ? "1 Reply" : "\(message.replyCount) Replies"
                        let title = Utilities.attributedTextWithImage(
                            text: reply,
                            image: UIImage(named: "replyLtoR") ?? UIImage(),
                            imageSize: CGSize(width: 16, height: 16),
                            imagePosition: .left,
                            imageColor: Colors.theme.returnColor(),
                            textStyle: .bold)
                        cell.btnReply.tag = indexPath.row
                        cell.btnReply.setAttributedTitle(title, for: .normal)
                        cell.btnReply.addTarget(self, action: #selector(didTapReplyButton(_:)), for: .touchUpInside)
                    }
                }
                return cell
            }
            else if let mediaMessage = message as? MediaMessage {
                if mediaMessage.messageType == .image {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverImageMessageBubbleTVCell", for: indexPath) as! ReceiverImageMessageBubbleTVCell
                    self.configureReceiverImageCell(cell, with: message)
                    cell.viewDateSection.isHidden = !isShowDateLabel
                    
                    if !self.isGroup {
                        cell.constraintTopViewMsgToSuper.priority = isShowDateLabel ? .defaultLow : .required
                    }
                    else {
                        cell.constraintTopViewMsgToViewDateSection.priority = .defaultLow
                        cell.constraintTopLblUserNameToViewDateSection.priority = isShowDateLabel ? .required : .defaultLow
                        cell.constraintTopLblUserNameToSuper.priority = isShowDateLabel ? .defaultLow : .required
                    }
                    cell.lblDateSection.text = strMsgDate
                    cell.selectionStyle = .none
                    
                    cell.lblMsg.isHidden = true
                    cell.ivImage.isHidden = false
                    cell.constraintBottomIvImageToLblTime.priority = .required
                    cell.constraintTrailIvImageToSuper.priority = .required
                    if mediaMessage.deletedAt > 0 {
                        cell.constraintBottomIvImageToLblTime.priority = .defaultLow
                        cell.constraintTrailIvImageToSuper.priority = .defaultLow
                        cell.lblMsg.isHidden = false
                        cell.ivImage.isHidden = true
                        cell.lblMsg.attributedText = Utilities.attributedTextWithImage(text: "This message was deleted.", image: UIImage(named: "banWhite") ?? UIImage(), imageSize: CGSize(width: 16, height: 16))
                        
                        cell.ivImage.isUserInteractionEnabled = false
                        
                        cell.constraintBottomViewMsgToSuper.priority = .required
                        cell.btnReply.isHidden = true
                    }
                    else {
                        /// To display reply count
                        cell.constraintBottomViewMsgToSuper.priority = (message.replyCount > 0) ? .defaultLow : .required
                        cell.btnReply.isHidden = (message.replyCount > 0) ? false : true
                        
                        if message.replyCount > 0 {
                            let reply = (message.replyCount == 1) ? "1 Reply" : "\(message.replyCount) Replies"
                            let title = Utilities.attributedTextWithImage(
                                text: reply,
                                image: UIImage(named: "replyLtoR") ?? UIImage(),
                                imageSize: CGSize(width: 16, height: 16),
                                imagePosition: .left,
                                imageColor: Colors.theme.returnColor(),
                                textStyle: .bold)
                            cell.btnReply.tag = indexPath.row
                            cell.btnReply.setAttributedTitle(title, for: .normal)
                            cell.btnReply.addTarget(self, action: #selector(didTapReplyButton(_:)), for: .touchUpInside)
                        }
                        
                        /// Tap to open document(image and other ...)
                        cell.ivImage.tag = indexPath.row
                        cell.ivImage.isUserInteractionEnabled = true
                        cell.ivImage.gestureRecognizers?.forEach { cell.ivImage.removeGestureRecognizer($0) } // avoid duplicate
                        let tap = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
                        cell.ivImage.addGestureRecognizer(tap)
                    }
                    return cell
                }
                else if mediaMessage.messageType == .file {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverDocumentMessageBubbleTVCell", for: indexPath) as! ReceiverDocumentMessageBubbleTVCell
                    self.configureReceiverDocuumentCell(cell, with: message)
                    cell.viewDateSection.isHidden = !isShowDateLabel
                    
                    if !self.isGroup {
                        cell.constraintTopViewMsgToSuper.priority = isShowDateLabel ? .defaultLow : .required
                    }
                    else {
                        cell.constraintTopViewMsgToViewDateSection.priority = .defaultLow
                        cell.constraintTopLblUserNameToViewDateSection.priority = isShowDateLabel ? .required : .defaultLow
                        cell.constraintTopLblUserNameToSuper.priority = isShowDateLabel ? .defaultLow : .required
                    }
                    cell.lblDateSection.text = strMsgDate
                    cell.selectionStyle = .none
                    
                    cell.ivImage.isHidden = false
                    if mediaMessage.deletedAt > 0 {
                        cell.ivImage.isHidden = true
                        cell.lblDocumentName.attributedText = Utilities.attributedTextWithImage(text: "This message was deleted.", image: UIImage(named: "banWhite") ?? UIImage(), imageSize: CGSize(width: 16, height: 16))
                        cell.contentView.isUserInteractionEnabled = false
                        
                        cell.constraintBottomViewMsgToSuper.priority = .required
                        cell.btnReply.isHidden = true
                    }
                    else {
                        /// To display reply count
                        cell.constraintBottomViewMsgToSuper.priority = (message.replyCount > 0) ? .defaultLow : .required
                        cell.btnReply.isHidden = (message.replyCount > 0) ? false : true
                        
                        if message.replyCount > 0 {
                            let reply = (message.replyCount == 1) ? "1 Reply" : "\(message.replyCount) Replies"
                            let title = Utilities.attributedTextWithImage(
                                text: reply,
                                image: UIImage(named: "replyLtoR") ?? UIImage(),
                                imageSize: CGSize(width: 16, height: 16),
                                imagePosition: .left,
                                imageColor: Colors.theme.returnColor(),
                                textStyle: .bold)
                            cell.btnReply.tag = indexPath.row
                            cell.btnReply.setAttributedTitle(title, for: .normal)
                            cell.btnReply.addTarget(self, action: #selector(didTapReplyButton(_:)), for: .touchUpInside)
                        }
                        
                        /// Tap to open document(image and other ...)
                        cell.contentView.tag = indexPath.row
                        cell.contentView.isUserInteractionEnabled = true
                        cell.contentView.gestureRecognizers?.forEach { cell.contentView.removeGestureRecognizer($0) }
                        let tap = UITapGestureRecognizer(target: self, action: #selector(handleFileTap(_:)))
                        cell.contentView.addGestureRecognizer(tap)
                    }
                    return cell
                }
            }
        }
        return UITableViewCell()
    }
    
    private func getMessageDate(with message: BaseMessage) -> String {
        var strDate = ""
        if let lastMessage = message as? TextMessage {
            strDate = Utilities.formatTimestamp("\(lastMessage.sentAt)", style: .relativeDay)
        }
        else if let mediaMessage = message as? MediaMessage {
            strDate = Utilities.formatTimestamp("\(mediaMessage.sentAt)", style: .relativeDay)
        }
        else if let actionMessage = message as? ActionMessage {
            strDate = Utilities.formatTimestamp("\(actionMessage.sentAt)", style: .relativeDay)
        }
        else if let customMessage = message as? CustomMessage {
            strDate = Utilities.formatTimestamp("\(customMessage.sentAt)", style: .relativeDay)
        }
        else {
            //cell.textLabel?.text = message.description ?? ""
        }
        // Handle other message types for sender cell
        return strDate
    }
    
    private func configureSenderTextCell(_ cell: SenderMessageBubbleTVCell, with message: BaseMessage) {
        
        if let lastMessage = message as? TextMessage {
            //cell.textLabel?.text = lastMessage.text
            cell.lblMsg.text = lastMessage.text
            cell.lblTime.text = Utilities.convertTimestamptoTimeString(timestamp: "\(lastMessage.sentAt)")
            //cell.ivMsgStatus.image = UIImage(named: "MsgSend")
            //cell.ivMsgStatus.image = UIImage(named: "MsgDeliverd")
            cell.ivMsgStatus.isHidden = false
            
            cell.lblEdited.isHidden = true
            cell.constraintTopLblTimeToViewMsg.priority = .required
            if lastMessage.editedAt > 0 {
                cell.lblEdited.isHidden = false
                cell.lblEdited.text = "Edited"
                cell.constraintTopLblTimeToViewMsg.priority = .defaultLow
            }
            
            //lastMessage.status
            if lastMessage.readAt > 0 {
                cell.ivMsgStatus.image = UIImage(named: "MsgDeliverd")
                cell.ivMsgStatus.tintColor = .green
            }
            else if lastMessage.deliveredAt > 0 {
                cell.ivMsgStatus.image = UIImage(named: "MsgSend")
                cell.ivMsgStatus.image = UIImage(named: "MsgDeliverd")
                cell.ivMsgStatus.tintColor = .white
            }
            else if lastMessage.sentAt > 0 {
                cell.ivMsgStatus.image = UIImage(named: "MsgSend")
                cell.ivMsgStatus.tintColor = .white
            }
            else {
                cell.ivMsgStatus.isHidden = true
            }
        }
    }
    
    private func configureSenderImageCell(_ cell: SenderImageMessageBubbleTVCell, with message: BaseMessage) {
        
        if let mediaMessage = message as? MediaMessage, mediaMessage.messageType == .image {
            
            if let mediaURLString = mediaMessage.attachment?.fileUrl,
               let mediaURL = URL(string: mediaURLString) {
                //cell.ivImage.setImage(imageUrl: mediaURLString)
                //cell.ivImage.sd_setImage(with: mediaURL, placeholderImage: UIImage(named: "Default"), options: [.scaleDownLargeImages])
                cell.ivImage.sd_setImage(with: mediaURL, placeholderImage: nil, options: [.scaleDownLargeImages]) { image, error, imageCache, url in
                    
                    DispatchQueue.main.async {
                        self.tvMessageList.layoutIfNeeded()
                        self.scrollToBottom()
                    }
                    
                    //self.tvMessageList.beginUpdates()
                    //self.tvMessageList.endUpdates()
                    //self.scrollToBottom()
                }   //  */
            }
            cell.lblTime.text = Utilities.convertTimestamptoTimeString(timestamp: "\(mediaMessage.sentAt)")
            cell.ivMsgStatus.isHidden = false
            
            if mediaMessage.readAt > 0 {
                cell.ivMsgStatus.image = UIImage(named: "MsgDeliverd")
                cell.ivMsgStatus.tintColor = .green
            }
            else if mediaMessage.deliveredAt > 0 {
                cell.ivMsgStatus.image = UIImage(named: "MsgSend")
                cell.ivMsgStatus.image = UIImage(named: "MsgDeliverd")
                cell.ivMsgStatus.tintColor = .white
            }
            else if mediaMessage.sentAt > 0 {
                cell.ivMsgStatus.image = UIImage(named: "MsgSend")
                cell.ivMsgStatus.tintColor = .white
            }
            else {
                cell.ivMsgStatus.isHidden = true
            }
        }
    }
    
    private func configureSenderDocumentCell(_ cell: SenderDocumentMessageBubbleTVCell, with message: BaseMessage) {
        
        if let mediaMessage = message as? MediaMessage, mediaMessage.messageType == .file {
            
            if let mediaURLString = mediaMessage.attachment?.fileUrl,
               let mediaURL = URL(string: mediaURLString) {
                cell.ivImage.tintColor = .white
                //cell.lblDocumentName.attributedText = Utilities.attributedTextWithImage(text: mediaMessage.attachment?.fileName ?? "", image: UIImage(named: "documentWhite") ?? UIImage(), imageSize: CGSize(width: 16, height: 16))
                cell.lblDocumentName.attributedText = Utilities.attributedTextWithImage(
                    text: mediaMessage.attachment?.fileName ?? "",
                    image: UIImage(named: "documentWhite") ?? UIImage(),
                    imageSize: CGSize(width: 16, height: 16),
                    imagePosition: .left,
                    imageColor: .white,
                    textStyle: .bold)
            }
            cell.lblTime.text = Utilities.convertTimestamptoTimeString(timestamp: "\(mediaMessage.sentAt)")
            
            cell.ivMsgStatus.isHidden = false
            
            if mediaMessage.readAt > 0 {
                cell.ivMsgStatus.image = UIImage(named: "MsgDeliverd")
                cell.ivMsgStatus.tintColor = .green
            }
            else if mediaMessage.deliveredAt > 0 {
                cell.ivMsgStatus.image = UIImage(named: "MsgSend")
                cell.ivMsgStatus.image = UIImage(named: "MsgDeliverd")
                cell.ivMsgStatus.tintColor = .white
            }
            else if mediaMessage.sentAt > 0 {
                cell.ivMsgStatus.image = UIImage(named: "MsgSend")
                cell.ivMsgStatus.tintColor = .white
            }
            else {
                cell.ivMsgStatus.isHidden = true
            }
        }
    }
    
    private func configureReceiverTextCell(_ cell: ReceiverMessageBubbleTVCell, with message: BaseMessage) {
        
        if let lastMessage = message as? TextMessage {
            //cell.textLabel?.text = lastMessage.text
            cell.lblMsg.text = lastMessage.text
            cell.lblTime.text = Utilities.convertTimestamptoTimeString(timestamp: "\(lastMessage.sentAt)")
            cell.lblUserName.text = lastMessage.sender!.name ?? ""
            cell.ivUserAvatar.setImage(imageUrl: lastMessage.sender!.avatar ?? "")
            
            /// Default settings for one to one chat
            // Default 1000(required) for one to one chat
            // Change to 250(low) for group chat
            cell.ivUserAvatar.isHidden = true
            cell.lblUserName.isHidden = true
            
            cell.constraintTopLblUserNameToSuper.priority = .defaultLow
            cell.constraintTopViewMsgToViewDateSection.priority = .required
            cell.constraintTopViewMsgToSuper.priority = .required
            cell.constraintLeadingViewMsgToSuper.priority = .required
            cell.constraintLeadingIvUserAvatarToSuper.priority = .defaultLow
            
            if self.isGroup {
                cell.ivUserAvatar.isHidden = false
                cell.lblUserName.isHidden = false
                cell.constraintTopLblUserNameToSuper.priority = .required
                cell.constraintTopViewMsgToViewDateSection.priority = .defaultLow
                cell.constraintTopViewMsgToSuper.priority = .defaultLow
                cell.constraintLeadingViewMsgToSuper.priority = .defaultLow
                cell.constraintLeadingIvUserAvatarToSuper.priority = .required
            }
            
            cell.lblEdited.isHidden = true
            cell.constraintTopLblTimeToViewMsg.priority = .required
            if lastMessage.editedAt > 0 {
                cell.lblEdited.isHidden = false
                cell.lblEdited.text = "Edited"
                cell.constraintTopLblTimeToViewMsg.priority = .defaultLow
            }
        }
    }
    
    private func configureReceiverImageCell(_ cell: ReceiverImageMessageBubbleTVCell, with message: BaseMessage) {
        
        if let mediaMessage = message as? MediaMessage, mediaMessage.messageType == .image {
            //cell.textLabel?.text = lastMessage.text
            //cell.lblMsg.text = lastMessage.text
            if let mediaURLString = mediaMessage.attachment?.fileUrl,
               let mediaURL = URL(string: mediaURLString) {
                //cell.ivImage.setImage(imageUrl: mediaURLString)
                //cell.ivImage.sd_setImage(with: mediaURL, placeholderImage: UIImage(named: "Default"), options: [.scaleDownLargeImages])
                cell.ivImage.sd_setImage(with: mediaURL, placeholderImage: nil, options: [.scaleDownLargeImages]) { image, error, imageCache, url in
                    
                    DispatchQueue.main.async {
                        self.tvMessageList.layoutIfNeeded()
                        self.scrollToBottom()
                    }
                    
                    //self.tvMessageList.beginUpdates()
                    //self.tvMessageList.endUpdates()
                    //self.scrollToBottom()
                }   //  */
            }
            cell.lblTime.text = Utilities.convertTimestamptoTimeString(timestamp: "\(mediaMessage.sentAt)")
            cell.lblUserName.text = mediaMessage.sender!.name ?? ""
            cell.ivUserAvatar.setImage(imageUrl: mediaMessage.sender!.avatar ?? "")
            
            /// Default settings for one to one chat
            cell.ivUserAvatar.isHidden = true
            cell.lblUserName.isHidden = true
            
            cell.constraintTopLblUserNameToSuper.priority = .defaultLow
            cell.constraintTopViewMsgToViewDateSection.priority = .required
            cell.constraintTopViewMsgToSuper.priority = .required
            cell.constraintLeadingViewMsgToSuper.priority = .required
            
            if self.isGroup {
                cell.ivUserAvatar.isHidden = false
                cell.lblUserName.isHidden = false
                cell.constraintTopLblUserNameToSuper.priority = .required
                cell.constraintTopViewMsgToViewDateSection.priority = .defaultLow
                cell.constraintTopViewMsgToSuper.priority = .defaultLow
                cell.constraintLeadingViewMsgToSuper.priority = .defaultLow
            }
        }
    }
    
    private func configureReceiverDocuumentCell(_ cell: ReceiverDocumentMessageBubbleTVCell, with message: BaseMessage) {
        
        if let mediaMessage = message as? MediaMessage, mediaMessage.messageType == .file {
            
            if let mediaURLString = mediaMessage.attachment?.fileUrl,
               let mediaURL = URL(string: mediaURLString) {
                cell.ivImage.tintColor = .white
                cell.lblDocumentName.attributedText = Utilities.attributedTextWithImage(
                    text: mediaMessage.attachment?.fileName ?? "",
                    image: UIImage(named: "documentWhite") ?? UIImage(),
                    imageSize: CGSize(width: 16, height: 16),
                    imagePosition: .left,
                    imageColor: .white,
                    textStyle: .bold
                )
                
            }
            cell.lblTime.text = Utilities.convertTimestamptoTimeString(timestamp: "\(mediaMessage.sentAt)")
            cell.lblUserName.text = mediaMessage.sender!.name ?? ""
            cell.ivUserAvatar.setImage(imageUrl: mediaMessage.sender!.avatar ?? "")
            
            /// Default settings for one to one chat
            // Default 1000(required) for one to one chat
            // Change to 250(low) for group chat
            cell.ivUserAvatar.isHidden = true
            cell.lblUserName.isHidden = true
            
            cell.constraintTopLblUserNameToSuper.priority = .defaultLow
            cell.constraintTopViewMsgToViewDateSection.priority = .required
            cell.constraintTopViewMsgToSuper.priority = .required
            cell.constraintLeadingViewMsgToSuper.priority = .required
            cell.constraintLeadingIvUserAvatarToSuper.priority = .defaultLow
            
            if self.isGroup {
                cell.ivUserAvatar.isHidden = false
                cell.lblUserName.isHidden = false
                cell.constraintTopLblUserNameToSuper.priority = .required
                cell.constraintTopViewMsgToViewDateSection.priority = .defaultLow
                cell.constraintTopViewMsgToSuper.priority = .defaultLow
                cell.constraintLeadingViewMsgToSuper.priority = .defaultLow
                cell.constraintLeadingIvUserAvatarToSuper.priority = .required
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
        //return 50
    }
    
    func setUpStickyDate() {
        DispatchQueue.main.async {
            //lblStickyDate.backgroundColor = .systemGray6
            self.lblStickyDate = UILabel()
            self.lblStickyDate!.backgroundColor = .white
            self.lblStickyDate!.roundCornersWithShadow(cornerRadius: 9.0,
                                                 shadowColor: .clear,
                                                 shadowOffset: .zero,
                                                 shadowOpacity: 0,
                                                 shadowRadius: 0,
                                                 borderWidth: 1.0,
                                                 borderColor: UIColor(hexString: "#C8C8C8", alpha: 1.0))
            self.lblStickyDate!.textColor = .darkGray
            self.lblStickyDate!.font = UIFont.boldSystemFont(ofSize: 13)
            self.lblStickyDate!.textAlignment = .center
            self.lblStickyDate!.layer.cornerRadius = 8
            self.lblStickyDate!.clipsToBounds = true
            self.lblStickyDate!.alpha = 0 // initially hidden
            
            self.lblStickyDate!.translatesAutoresizingMaskIntoConstraints = false
            self.view.addSubview(self.lblStickyDate!)
            
            NSLayoutConstraint.activate([
                self.lblStickyDate!.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 53),
                self.lblStickyDate!.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                self.lblStickyDate!.heightAnchor.constraint(equalToConstant: 28),
                self.lblStickyDate!.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
            ])
        }
    }
    
    func showNoMessagesLabel() {
        DispatchQueue.main.async {
            let noMessagesLabel = UILabel()
            if self.isChatEnabled {
                noMessagesLabel.text = "No past conversations available."
            }
            else {
                self.removeMatchFinishLabel()
                noMessagesLabel.text = "Match Finished."
            }
            noMessagesLabel.textAlignment = .center
            noMessagesLabel.textColor = .lightGray
            noMessagesLabel.numberOfLines = 0
            //noMessagesLabel.font = UIFont.boldSystemFont(ofSize: 16)
            noMessagesLabel.font = UIFont.systemFont(ofSize: 16)
            noMessagesLabel.translatesAutoresizingMaskIntoConstraints = false
            
            self.view.addSubview(noMessagesLabel)
            
            NSLayoutConstraint.activate([
                noMessagesLabel.centerXAnchor.constraint(equalTo: self.tvMessageList.centerXAnchor),
                noMessagesLabel.centerYAnchor.constraint(equalTo: self.tvMessageList.centerYAnchor)
            ])
        }
    }
    
    func matchFinishedLabel() {
        DispatchQueue.main.async {
            let lblMatchFinish = UILabel()
            lblMatchFinish.translatesAutoresizingMaskIntoConstraints = false
            lblMatchFinish.text = "Match Finished."
            lblMatchFinish.textAlignment = .center
            lblMatchFinish.textColor = .black
            lblMatchFinish.backgroundColor = .clear
            lblMatchFinish.numberOfLines = 0
            lblMatchFinish.font = UIFont.systemFont(ofSize: 16, weight: .bold)
            lblMatchFinish.tag = 998

            // Add to view
            self.viewComposer.addSubview(lblMatchFinish)

            // Constraints to fill the entire view
            NSLayoutConstraint.activate([
                lblMatchFinish.leadingAnchor.constraint(equalTo: self.viewComposer.leadingAnchor),
                lblMatchFinish.trailingAnchor.constraint(equalTo: self.viewComposer.trailingAnchor),
                lblMatchFinish.topAnchor.constraint(equalTo: self.viewComposer.topAnchor),
                lblMatchFinish.bottomAnchor.constraint(equalTo: self.viewComposer.bottomAnchor)
            ])
        }
    }
    
    func removeNoDataLabels() {
        DispatchQueue.main.async {
            for subview in self.view.subviews {
                //if let label = subview as? UILabel, label.text?.contains("No") == true {
                if let label = subview as? UILabel, (label.text?.contains("No") == true) {
                    label.removeFromSuperview()
                }
            }
        }
    }
    
    func removeMatchFinishLabel() {
        DispatchQueue.main.async {
            for subview in self.viewComposer.subviews {
                //if let label = subview as? UILabel, label.text?.contains("No") == true {
                if let label = subview as? UILabel, (label.tag == 998) {
                    label.removeFromSuperview()
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Check if user scrolled to top
        if scrollView.contentOffset.y <= 0 {
            print("🔁 Scrolled to top - load older messages")
            
            if isFetchingOlderMessages {
                //loadOlderMessages()
                print("Load previous message...")
                self.fetchPreviousMessage()
            }
        }
        
        guard let indexPaths = self.tvMessageList.indexPathsForVisibleRows,
              let firstIndexPath = indexPaths.first else { return }
        
        let message = self.arrMessages[firstIndexPath.row]
        let dateStr = self.getMessageDate(with: message)
        self.lblStickyDate!.text = dateStr
        
        // Animate label appearance
        UIView.animate(withDuration: 0.25) {
            self.lblStickyDate!.alpha = 1
        }
        
        // Optionally hide after delay
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(hideStickyDate), object: nil)
        self.perform(#selector(hideStickyDate), with: nil, afterDelay: 2.5)
        
        self.shouldAutoScroll = tvMessageList.isAtBottom
    }
    
    @objc private func hideStickyDate() {
        UIView.animate(withDuration: 0.25) {
            self.lblStickyDate!.alpha = 0
        }
    }
    
    func scrollToBottom() {
        if !self.arrMessages.isEmpty {
            //let indexPath = IndexPath(row: self.arrMessages.count - 1, section: 0)
            //DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            //    self.tvMessageList.scrollToRow(at: indexPath, at: .bottom, animated: true)
            //}
            if self.shouldAutoScroll {
                self.shouldAutoScroll  = false
                DispatchQueue.main.async {
                    let lastSection = self.tvMessageList.numberOfSections - 1
                    guard lastSection >= 0 else { return }
                    let lastRow = self.tvMessageList.numberOfRows(inSection: lastSection) - 1
                    guard lastRow >= 0 else { return }
                    
                    let indexPath = IndexPath(row: lastRow, section: lastSection)
                    self.tvMessageList.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            }
        }
    }
    
    /// Handle long press for UITableView
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let point = gestureRecognizer.location(in: self.tvMessageList)
            
            if let indexPath = self.tvMessageList.indexPathForRow(at: point) {
                let message = self.arrMessages[indexPath.row] // assuming `messages` is your data array
                //print("Long pressed on message: \((message as? TextMessage)?.text ?? "")")
                self.selectedCellIndex = indexPath
                self.objLongPressedMessage = message
                // Do something: Show action sheet, custom menu, etc.
                if let msg = message as? TextMessage {
                    if self.senderId == msg.senderUid {
                        if msg.deletedAt <= 0 {
                            self.showMessageOption(msgType: .text, isReceiver: false)
                        }
                    }
                    else {
                        if msg.deletedAt <= 0 {
                            self.showMessageOption(msgType: .text, isReceiver: true)
                        }
                    }
                }
                else if let msg = message as? MediaMessage {
                    if self.senderId == msg.senderUid {
                        if msg.deletedAt <= 0 {
                            self.showMessageOption(msgType: .image, isReceiver: false)
                        }
                    }
                    else {
                        if msg.deletedAt <= 0 {
                            self.showMessageOption(msgType: .file, isReceiver: true)
                        }
                    }
                }
            }
        }
    }
    
    @objc func showMessageOption(msgType: CometChat.MessageType, isReceiver: Bool) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if ((msgType == .text) || (msgType == .image) || (msgType == .file)) {
            alert.addAction(UIAlertAction(title: "Reply", style: .default, handler: { _ in
                // Handle reply
                
                let threadReplyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThreadReplyVC") as! ThreadReplyVC
                threadReplyVC.replyMessage = self.objLongPressedMessage! // Pass the message or thread ID
                threadReplyVC.senderId = APIManager.sharedManager.strChatUserId
                //threadReplyVC.receiverId = (self.objLongPressedMessage!).receiverUid
                threadReplyVC.receiverId = self.receiverId
                threadReplyVC.isGroup = self.isGroup
                threadReplyVC.isChatEnabled = self.isChatEnabled
                threadReplyVC.shouldAutoScroll = true
                threadReplyVC.tusslyTabVC = self.tusslyTabVC
                /*threadReplyVC.chatMessageVC = {
                    return self
                }   //  */
                self.isFromThreadReply = true
                self.isReplyPress = true
                self.navigationController?.pushViewController(threadReplyVC, animated: true)
            }))
        }
        if ((msgType == .text) && !isReceiver) {
            alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
                // Handle edit
                self.viewEdit.isHidden = false
                self.constraintTopTxtMessageToSuper.priority = .defaultLow
                self.isEditMessage = true
                self.txtMessage.text = (self.objLongPressedMessage! as! TextMessage).text
                self.lblEditMessage.text = (self.objLongPressedMessage! as! TextMessage).text
                
                self.txtMessage.becomeFirstResponder()
                self.txtMessage.selectedTextRange = self.txtMessage.textRange(from: self.txtMessage.endOfDocument, to: self.txtMessage.endOfDocument)
                
                self.isAttachMedia = false
                self.btnSendMessage.setImage(UIImage(named: "send"), for: .normal)
            }))
        }
        if (msgType == .text || msgType == .image || msgType == .file) && (!isReceiver) {
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                // Handle delete
                self.deleteMessage(self.objLongPressedMessage!, at: self.selectedCellIndex ?? IndexPath(row: 0, section: 0))
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    func editMessage(_ editedMessage: TextMessage, at indexPath: IndexPath) {
        CometChat.edit(message: editedMessage, onSuccess: { (baseMessage) in
            //print("Message edited successfully. \(baseMessage)")
            print("Message edited successfully.")
            
            if let (index,msg) = self.arrMessages.enumerated().first(where: {
                if let textMsg = $0.element as? TextMessage {
                    return textMsg.id == editedMessage.id
                }
                return false
            }) {
                print("Edit by me - Found TextMessage at index: \(index)")
                print("TextMessage: \(editedMessage.text)")
                editedMessage.editedAt = 1000
                self.arrMessages[index] = editedMessage
                DispatchQueue.main.async {
                    self.viewEdit.isHidden = true
                    self.isEditMessage = false
                    self.constraintTopTxtMessageToSuper.priority = .required
                    
                    self.txtMessage.text = ""
                    self.isAttachMedia = true
                    self.btnSendMessage.setImage(UIImage(named: "imgAttach"), for: .normal)
                    
                    self.tvMessageList.reloadData()
                    self.btnSendMessage.isEnabled = true
                }
            } else {
                DispatchQueue.main.async {
                    self.btnSendMessage.isEnabled = true
                    print("TextMessage not found")
                }
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.btnSendMessage.isEnabled = true
                print("Message edit failed with error: \(error.errorDescription)")
            }
        }
    }
    
    func deleteMessage(_ message: BaseMessage, at indexPath: IndexPath) {
        
        CometChat.delete(messageId: message.id, onSuccess: { (baseMessage) in
           print("message deleted successfully. \(baseMessage)")
            DispatchQueue.main.async {
                //self.arrMessages.remove(at: indexPath.row)
                let message = self.arrMessages[indexPath.row]
                if let msg = message as? TextMessage {
                    msg.deletedAt = 100
                    self.arrMessages[indexPath.row] = msg
                }
                else if let msg = message as? MediaMessage {
                    msg.deletedAt = 100
                    self.arrMessages[indexPath.row] = msg
                }
                self.tvMessageList.reloadData()
            }
        }) { (error) in
           print("delete message failed with error: \(error.errorDescription)")
        }
    }
    
    @objc func handleImageTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedImageView = gesture.view as? UIImageView else { return }
        let index = tappedImageView.tag
        
        guard index < arrMessages.count,
              let mediaMessage = arrMessages[index] as? MediaMessage,
              let urlString = mediaMessage.attachment?.fileUrl,
              let imageURL = URL(string: urlString) else { return }
        
        let previewVC = ImagePreviewViewController()
        //previewVC.modalPresentationStyle = .fullScreen
        previewVC.imageURL = imageURL
        self.isBackPress = true
        //self.present(previewVC, animated: true)
        self.navigationController?.pushViewController(previewVC, animated: false)
    }
    
    @objc func handleFileTap(_ gesture: UITapGestureRecognizer) {
        guard let tappedView = gesture.view as? UIView else { return }
        let index = tappedView.tag
        
        guard index < arrMessages.count,
              let mediaMessage = arrMessages[index] as? MediaMessage,
              mediaMessage.messageType == .file,
              let urlString = mediaMessage.attachment?.fileUrl,
              let fileURL = URL(string: urlString) else { return }
        self.isBackPress = true
        UIApplication.shared.open(fileURL, options: [:], completionHandler: nil)
    }
    
    @objc func didTapReplyButton(_ sender: UIButton) {
        let index = sender.tag
        let message = self.arrMessages[index] // make sure this is your data source
        self.objLongPressedMessage = self.arrMessages[index]
        let threadReplyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ThreadReplyVC") as! ThreadReplyVC
        threadReplyVC.replyMessage = message // Pass the message or thread ID
        threadReplyVC.senderId = APIManager.sharedManager.strChatUserId
        //threadReplyVC.receiverId = message.receiverUid
        threadReplyVC.receiverId = self.receiverId
        threadReplyVC.isGroup = self.isGroup
        threadReplyVC.isChatEnabled = self.isChatEnabled
        threadReplyVC.shouldAutoScroll = true
        threadReplyVC.tusslyTabVC = self.tusslyTabVC
        /*threadReplyVC.chatMessageVC = {
            return self
        }   //  */
        self.isFromThreadReply = true
        self.isReplyPress = true
        self.navigationController?.pushViewController(threadReplyVC, animated: true)
    }
}


/// For Upload Document
extension ChatMessageVC: UIDocumentPickerDelegate {
    
    func openDocumentPicker() {
        let supportedTypes: [String] = [
            String(kUTTypePDF),                                      // PDF
            "com.microsoft.word.doc",                                // .doc
            "org.openxmlformats.wordprocessingml.document",          // .docx
            "com.microsoft.excel.xls",                               // .xls
            "org.openxmlformats.spreadsheetml.sheet",                // .xlsx
            "com.pkware.zip-archive"                                 // .zip
        ]

        let documentPicker = UIDocumentPickerViewController(documentTypes: supportedTypes, in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let fileURL = urls.first else { return }
        
        do {
            let fileData = try Data(contentsOf: fileURL)
            let fileName = fileURL.lastPathComponent
            let fileMimeType = getMimeType(for: fileURL)
            
            sendDocument(
                to: self.receiverId ?? "",
                receiverType: self.isGroup ? .group : .user,
                fileName: fileName,
                fileUrl: fileURL.absoluteString,
                mimeType: fileMimeType
            )
            
        } catch {
            print("Error loading file: \(error)")
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled")
    }
    
    func getMimeType(for url: URL) -> String {
        let pathExtension = url.pathExtension.lowercased()
        switch pathExtension {
        case "pdf": return "application/pdf"
        case "doc": return "application/msword"
        case "docx": return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
        case "xls": return "application/vnd.ms-excel"
        case "xlsx": return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        case "zip": return "application/zip"
        default: return "application/octet-stream"
        }
    }
    
    func sendDocument(to receiverId: String, receiverType: CometChat.ReceiverType, fileName: String, fileUrl: String, mimeType: String) {
        
        // Create CometChat MediaMessage
        
        let mediaMessage = MediaMessage(receiverUid: receiverId, fileurl: fileUrl, messageType: .file, receiverType: self.isGroup ? .group : .user)
        
        self.showLoading()
        
        CometChat.sendMediaMessage(message: mediaMessage, onSuccess: { message in
            print("✅ Document sent: \(message)")
            self.loadNewMessage(message: message)
            self.hideLoading()
        }, onError: { error in
            print("❌ Error sending document: \(error?.errorDescription ?? "Unknown error")")
            self.hideLoading()
        })
    }
}

extension UITableView {
    var isAtBottom: Bool {
        return contentOffset.y >= (contentSize.height - frame.size.height - 1)
    }
}

// MARK: Webservices
extension ChatMessageVC {
    
    func addAdminToGroup() {
        if !Network.reachability.isReachable {
            self.isRetryInternet { (isretry) in
                if isretry! {
                    self.addAdminToGroup()
                }
            }
            return
        }
        
        self.showLoading()
        
        let param = [
            "chatId": self.receiverId,
            "organizerId":  self.strOrganizerId
        ] as [String : Any]
        
        APIManager.sharedManager.postData(url: APIManager.sharedManager.ADD_ADMIN_TO_GROUP, parameters: param) { (response: ApiResponse?, error) in
            self.hideLoading()
            if response?.status == 1 {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .success)
                    self.isAddAdminTap = false
                }
            }
            else {
                DispatchQueue.main.async {
                    Utilities.showPopup(title: response?.message ?? "", type: .error)
                    self.isAddAdminTap = false
                }
            }
        }
    }
}
