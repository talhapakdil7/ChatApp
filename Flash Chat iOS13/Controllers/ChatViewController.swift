//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class ChatViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages : [Message] = [
       
      
    ]
    
    var data = [String:Any]()
    
    var text = ""
    var sender = ""
    
    
    override func viewDidLoad()   {
        super.viewDidLoad()
        tableView.dataSource = self
        
        navigationItem.hidesBackButton = true
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        
        GetData()
        
    }
    
 
    
    
    func GetData() {
        
  
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener { snapshot, error in
            if let error = error {
                   print("Hata:", error.localizedDescription)
                   return
               }
            
            guard let documents = snapshot?.documents else { return }
               
            self.messages.removeAll()
            
               for doc in documents {
                   self.data = doc.data()
                   self.text = self.data[K.FStore.bodyField] as? String ?? ""
                   self.sender = self.data[K.FStore.senderField] as? String ?? ""
                   self.messages.append(Message(sender: self.sender, message: self.text))
                   
                  
               }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
              
               
            }
        
          
        }
        
     
        
        
        
    }
    
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text {
    
            let sender = Auth.auth().currentUser?.email ?? "Anonymous"
            
            db.collection(K.FStore.collectionName).addDocument(data: [K.FStore.senderField:sender,
                                                                      K.FStore.bodyField:messageBody,
                                                               K.FStore.dateField: Date().timeIntervalSince1970]) { (Error) in
                
                if Error != nil {
                    AlertManager.shared.show(message: Error!.localizedDescription)
                }
                else{
                   
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                       
                    }
                    
                }
                
                
                
            }
            
            
            
        }
        
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        
    }
    
}


//MARK: - Table view

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        cell.label.text = message.message
        
        if message.sender == Auth.auth().currentUser?.email {
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.lightPurple)
            cell.label.textColor = UIColor(named: K.BrandColors.purple)
        }
        else{
            
            cell.rightImageView.isHidden = true
            cell.leftImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColor(named: K.BrandColors.purple)
            cell.label.textColor = UIColor(named: K.BrandColors.lightPurple)
            
        }
        
        
        
        
        return cell
    }
    
}


