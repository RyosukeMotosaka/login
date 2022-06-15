//
//  homeviewController.swift
//  login
//
//  Created by 本阪　亮輔 on 2022/06/13.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth


class homeviewController: UIViewController{

    var user: User?{
        didSet{
            print("user name", user?.name)
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var dataLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    @IBAction func tapToLogout(_ sender: Any) {
        handleLogout()
    }
    private func handleLogout(){
        do{
            try  Auth.auth().signOut()
            presetToSingUPViewController()
        } catch (let err){
            print("ログアウトに失敗しました。")
        }
    }
    
    override func viewDidLoad() {
        
    logoutButton.layer.cornerRadius = 20
        
     super.viewDidLoad()
        if let user = user{
            nameLabel.text = user.name + "さんようこそ"
            emailLabel.text = user.email
            let dateString = dataFormatterCreatedAt(date: user.createdAt.dateValue())
            dataLabel.text = "作成日： " + dateString
            print(dateString)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        confirmLoggedInUser()
    }
    
    private func confirmLoggedInUser (){
        //user Authがnilか判断
        if Auth.auth().currentUser?.uid == nil || user == nil {
            presetToSingUPViewController()
        }
    }
    
    private func presetToSingUPViewController(){
        
        let storyBoard = UIStoryboard(name: "SingUp", bundle: nil)
        let viewController = storyBoard.instantiateViewController(identifier: "ViewController") as! ViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.modalPresentationStyle = .fullScreen
        self.present(navController,animated: true, completion: nil)
    }
    
    private func dataFormatterCreatedAt(date: Date) -> String {
        
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
