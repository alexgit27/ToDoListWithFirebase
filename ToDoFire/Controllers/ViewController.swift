//
//  ViewController.swift
//  ToDoFire
//
//  Created by Alexandr on 23.03.2021.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    var ref: DatabaseReference!
    
    @IBOutlet weak var warnLabel: UILabel!
    @IBOutlet weak var loginTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference(withPath: "users")
        
        warnLabel.alpha = 0
        
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(kbDidHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        Auth.auth().addStateDidChangeListener {[weak self] auth, user in
            if user != nil {
                self?.performSegue(withIdentifier: "showVC", sender: self) }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loginTF.text = ""
        passwordTF.text = ""
    }
    
    @objc func kbDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let kbFrameSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height + kbFrameSize.height)
        (self.view as! UIScrollView).scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: kbFrameSize.height, right: 0)
    }
    
    @objc func kbDidHide() {
        (self.view as! UIScrollView).contentSize = CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height)
    }
    
    func displayWarning(text: String) {
        warnLabel.text = text
        
        UIView.animate(withDuration: 3, delay: 0, options: .curveEaseInOut,animations: { [weak self] in
            self?.warnLabel.alpha = 1
        }) { [weak self] complete in
            self?.warnLabel.alpha = 0
        }
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        guard let email = loginTF.text, let password = passwordTF.text, email != " ", password != " " else {
            displayWarning(text: "Info is incorrect")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] (user, error) in
            if error != nil {
                self?.displayWarning(text: "Error occured")
                return
            }
            if user != nil {
                self?.performSegue(withIdentifier: "showVC", sender: self)
                return
            }
            self?.displayWarning(text: "No such user!")
        }
        print(#function)
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        guard let email = loginTF.text, let password = passwordTF.text, email != " ", password != " " else {
            displayWarning(text: "Info is incorrect")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) {[weak self] (user, error) in
            guard error == nil, user != nil else {
                print(error!.localizedDescription)
                return
            }
            let userRef = self?.ref.child((user?.user.uid)!)
            userRef?.setValue(["email": user?.user.email])
//            if error == nil {
//                if user != nil {
////                    self?.performSegue(withIdentifier: "showVC", sender: self)
//                } else {
//                    print("user is not created")
//                }
//            } else {
//                self?.displayWarning(text: "Info is incorrect")
//                print(error?.localizedDescription)
//            }
        }
    }
    
}

