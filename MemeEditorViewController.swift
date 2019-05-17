//
//  MemeEditorViewController.swift
//  MemeMe2.4
//
//

import UIKit
import Foundation

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIApplicationDelegate {
    
    
    @IBOutlet weak var toolbarBottom: UIToolbar!
    @IBOutlet weak var toolbarTop: UIToolbar!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var takeAPhoto: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var meme: Meme!
    var memedImage: UIImage!
    var saveBarButton: UIBarButtonItem!
    
    let memeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -1]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        takeAPhoto.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        setValueTextField(topTextField)
        setValueTextField(bottomTextField)
        saveBarButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share))
        let flexibleButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        let cancelBarButton = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.done, target: self, action: #selector(Cancel))
        toolbarTop.setItems([saveBarButton, flexibleButton, cancelBarButton], animated: false)
        saveBarButton.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        topTextField.delegate = self
        bottomTextField.delegate = self
        subscribeToKeyboardNotifications()
        if meme != nil {
            editImage()
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @objc func Cancel() {
        dismiss(animated: true, completion: nil)
    }
    
    
    func setValueTextField (_ textField: UITextField){
        if textField.tag == 0 {
            textField.text = "TOP"
        }
        else {
            textField.text = "BOTTOM"
        }
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
    }
    
    
    func editImage(){
        imagePickerView.image = meme.orginalImage
        saveBarButton.isEnabled = true
    }
    
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder {
            view.frame.origin.y = 0 - getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        getPhoto(photoSourceType: ".photoLibrary")
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        getPhoto(photoSourceType: ".camera")
    }
    
    func getPhoto (photoSourceType: String){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        if photoSourceType == ".photoLibrary" {
            pickerController.sourceType = .photoLibrary
        }
        else{
            pickerController.sourceType = .camera
        }
        present(pickerController, animated: true, completion: nil)
    }
    
    @objc func share(){
        // Create the meme
        let controller = UIActivityViewController(activityItems: [generateMemedImage()], applicationActivities: nil)
        present(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
            if !completed {
                // User canceled
                return
            }
            // User completed activity
            self.save()
        }
        
    }
    func generateMemedImage() -> UIImage {
        
        toolbarTop.isHidden = true
        toolbarBottom.isHidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolbarTop.isHidden = false
        toolbarBottom.isHidden = false
        return memedImage
    }
    
    func save(){
        
        guard let topText = topTextField.text else { fatalError("top is nil") }
        guard let bottomText = bottomTextField.text else { fatalError("bottom is nil") }
        guard let image = imagePickerView.image else { fatalError("image is nil") }
        let meme = Meme (topText: topText, bottomText: bottomText, orginalImage: image, memedImage: generateMemedImage())
        
        appDelegate.memes.append(meme)
        
        dismiss(animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imagePickerView.image = image
            saveBarButton.isEnabled = true
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


