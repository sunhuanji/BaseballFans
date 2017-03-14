//
//  ViewController.swift
//  BaseballFans
//
//  Created by Sun Huanji on 2017/3/14.
//  Copyright © 2017年 Sun Huanji. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginView: UIView!
    
    var authService = AuthenticationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Setting the delegates for the Textfields
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Creating Tap Gesture to dismiss Keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(_:)))
        tapGesture.numberOfTapsRequired = 1
        view.addGestureRecognizer(tapGesture)
        
        // Creating Swipe Gesture to dismiss Keyboard
        let swipDown = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard(_:)))
        swipDown.direction = .down
        view.addGestureRecognizer(swipDown)
        
        view.bringSubview(toFront: loginView)
    }

    // Unwind Segue Action
    @IBAction func unwindToLogin(_ storyboard: UIStoryboardSegue){}
    
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func dismissKeyboard(_ gesture: UIGestureRecognizer){
        self.view.endEditing(true)
    }
    
    // Dismissing the Keyboard with the Return Keyboard Button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
   return true
    }
    
    // Moving the View down after the Keyboard appears
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateView(true, moveValue: 80)
    }

    // Moving the View down after the Keyboard disappears
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateView(false, moveValue: 80)
    }
    
    
    // Move the View Up & Down when the Keyboard appears
    func animateView(_ up: Bool, moveValue: CGFloat){
        
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
        
        
    }
 
    // Loging in the User
    @IBAction func loginAction(_ sender: AnyObject) {
        self.view.endEditing(true)
    let email = usernameTextField.text!.lowercased()
    let finalEmail = email.trimmingCharacters(in: CharacterSet.whitespaces)
    let password = passwordTextField.text!
        
        if finalEmail.isEmpty || password.isEmpty || finalEmail.characters.count < 8 {
            //Present an alertView to your user
            
            DispatchQueue.main.async(execute: {
                let alertView =  SCLAlertView()
                _ = alertView.showError("ERROR", subTitle: "Did not fill the information correctly")
            })
            
        }else {
            authService.signIn(finalEmail, password: password)
        }   
    }

}

