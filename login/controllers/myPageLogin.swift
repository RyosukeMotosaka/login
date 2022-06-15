//
//  myPageLogin.swift
//  login
//
//  Created by 本阪　亮輔 on 2022/06/14.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD


class myPageLoginViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var tabTodontHaveAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordtextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBAction func tapToDontHaveAccountButton(_ sender: Any) {
        navigationController?.popViewController(animated:true)
    }
    
    @IBAction func tapToLoginButton(_ sender: Any) {
        HUD.show(.progress, onView: self.view)
        guard let email = emailTextField.text else {return}
        guard let password = passwordtextField.text else {return}
        
        Auth.auth().signIn(withEmail: email, password: password) { (res , err) in
            if let err = err {
                print("loginに失敗しました。(err)")
                return
            }
            print("loginに成功しました。(err)")
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let userRef = Firestore.firestore().collection("users").document(uid)
            
            userRef.getDocument { snapshot, err in
                if let err = err{
                    print("ユーザー情報の取得に失敗しました。(err)")
                    HUD.hide{(_) in
                        HUD.flash(.error,delay: 1)
                    }
                }
                guard let data = snapshot?.data() else { return}
                let user = User.init(dic:data)
                print("ユーザー情報の取得に成功しました" , user.name)
                
                HUD.hide{(_) in
                    HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                        self.presentToHomeController(user: user)
                    }
                }
            }
        }
    }
    
    private func presentToHomeController (user: User){
        
        let storyBoard = UIStoryboard(name: "Home", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(identifier: "homeViewController") as! homeviewController
        homeViewController.user = user //user情報を入れる
        homeViewController.modalPresentationStyle = .fullScreen
        self.present(homeViewController,animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 20
        loginButton.isEnabled = false
        loginButton.backgroundColor = UIColor.rgb(red: 255, green:221, blue: 187)
        
        emailTextField.delegate = self
        passwordtextField.delegate = self
        
    }
}

// Mark: - UITextViewDelegate
extension myPageLoginViewController: UITextViewDelegate{
    
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        //email password usernameが全てが入力された場合、registaボタンが押せる様にする
        let emailEmpty      =   emailTextField.text?.isEmpty ?? true
        let passwordEmpty   =   passwordtextField.text?.isEmpty ?? true
        
        
        if emailEmpty || passwordEmpty {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor.rgb(red: 255, green:221, blue: 187)
        }else{
            loginButton.isEnabled = true
            loginButton.backgroundColor = UIColor.rgb(red: 255, green:141, blue: 0)
            
        }
        //print("textField.text",textField.text)
    }
    
}
