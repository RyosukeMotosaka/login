//
//  ViewController.swift
//  login
//
//  Created by 本阪　亮輔 on 2022/06/09.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import PKHUD


class ViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registaButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    
    
    @IBAction func tapToRegistaButton(_ sender: Any) {
        handleAuthFirebase()
    }
    
    @IBAction func tapToAlredyHaveAccountButton(_ sender: Any) {
        pushToMyloginViewController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
        setUoNotificationCenterObServer()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func pushToMyloginViewController (){
        let storyBoard = UIStoryboard(name: "myPageLogin", bundle: nil)
        let homeViewController = storyBoard.instantiateViewController(identifier: "myPageLoginViewController") as! myPageLoginViewController
        //横にスライドする動作
        navigationController?.pushViewController(homeViewController, animated: true)
    }
    
    private func setUpViews (){
        registaButton.layer.cornerRadius = 10
        registaButton.isEnabled = false
        registaButton.backgroundColor = UIColor.rgb(red: 255, green:221, blue: 187)
        
        // textfield入力時にボタンを押下出来る様にする
        emailTextField.delegate    = self
        passwordTextField.delegate = self
        userNameTextField.delegate = self
        
    }
    
    private func setUoNotificationCenterObServer (){
        //keybordの認識の処理
        //異なるviewの通知を受け取れる処理
        //keyboardが表示された場合通知を受け取る
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        //keyboardが隠れた場合通知を受け取る
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    //Firestoreからユーザー情報を取得
    private func handleAuthFirebase (){
        HUD.show(.progress, onView: view)
        guard let email = emailTextField.text else { return}
        guard let password = passwordTextField.text else { return }
        
            Auth.auth().createUser(withEmail: email, password: password) { (res , err) in
                if let err = err {
                    HUD.hide{(_) in
                        HUD.flash(.error,delay: 1)
                    }
                    return
                }
                self.addUserInfotoFirestore(email: email)
            }
        }
    //Firebaseにユーザー情報を保存
    private func addUserInfotoFirestore(email: String){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let name = self.userNameTextField.text else { return }
               
        let docData = [ "email": email , "name": name ,"createdAt" : Timestamp()] as [ String: Any]
        let userRef = Firestore.firestore().collection("users").document(uid)
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
        if let err = err {
                HUD.hide{(_) in
                    HUD.flash(.error,delay: 1)
                }
           }
            self.fetchUserInfoFireStore(userRef:userRef)
        }
    }
    private func fetchUserInfoFireStore (userRef: DocumentReference){
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
                //HUD.flash(.success,delay: 1)
                HUD.flash(.success, onView: self.view, delay: 1) { (_) in
                    self.presentToHomeController(user: user)
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

    //showKeyboardのメソッド
    //registaButtonの高さを求めて差分だけviewを上げる
    @objc func showKeyboard (notification: Notification){
        let keyboardFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as
                             AnyObject).cgRectValue

        //keyboardの高さを求める
        guard let keyboardMinY = keyboardFrame?.minY else { return }
        //registabuttonの高さを求める
        let registaButtonMaxY = registaButton.frame.minY
        //keyboardとregistabuttonの差分だけ位置をずらす
        let distance = registaButtonMaxY - keyboardMinY + 60
        let transForm = CGAffineTransform(translationX: 0, y: -distance)
        
        //keyboardのアニメーション設定
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1,
            initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = transForm
           
        })
    
    }
    //hideKeyboardのメソッド
    @objc func hideKeyboard (){
        //keyboardのアニメーション設定
        //down
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1,
            initialSpringVelocity: 1, options: [], animations: {
            self.view.transform = .identity
        })
    }
    //keybourdを下がる様にする
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// fieldDelegateの処理
extension ViewController: UITextFieldDelegate{
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        //email password usernameが全てが入力された場合、registaボタンが押せる様にする
        let emailEmpty      =   emailTextField.text?.isEmpty ?? true
        let passwordEmpty   =   passwordTextField.text?.isEmpty ?? true
        let userNameEmpty   =   userNameTextField.text?.isEmpty ?? true
        
        if emailEmpty || passwordEmpty || userNameEmpty {
            registaButton.isEnabled = false
            registaButton.backgroundColor = UIColor.rgb(red: 255, green:221, blue: 187)
        }else{
            registaButton.isEnabled = true
            registaButton.backgroundColor = UIColor.rgb(red: 255, green:141, blue: 0)
            
        }
    }
}

