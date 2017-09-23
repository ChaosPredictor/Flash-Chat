//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase
import ChameleonFramework

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    
    
    // Declare instance variables here
    var messageArray : [Message] = [Message]()
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self

        //TODO: Set the tapGesture here:
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))
        messageTableView.addGestureRecognizer(tapGesture)
        
        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName: "MessageCell",  bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        configureTableView()
        retriveMessages()
        
        messageTableView.separatorStyle = .none
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods
    
    
    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        //let messageArray = messageArray.
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody
        cell.senderUsername.text = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named: "egg")
    
        if messageArray[indexPath.row].sender == FIRAuth.auth()?.currentUser?.email as String! {
            cell.avatarImageView.backgroundColor = UIColor.flatMint()
            cell.messageBackground.backgroundColor = UIColor.flatSkyBlue()
        } else {
            cell.avatarImageView.backgroundColor = UIColor.flatRed()
            cell.messageBackground.backgroundColor = UIColor.flatLime()
        }
        
        return cell
    }
    
    
    //TODO: Declare numberOfRowsInSection here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    
    //TODO: Declare tableViewTapped here:
    @objc func tableViewTapped() {
        messageTextfield.endEditing(true)
    }

    
    //TODO: Declare configureTableView here:
    func configureTableView() {
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 120.0
    }
    
    
    ///////////////////////////////////////////
    
    //MARK:- TextField Delegate Methods
    
    

    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5){
            self.heightConstraint.constant = 320
            self.view.layoutIfNeeded()
        }
    }
    
    
    
    //TODO: Declare textFieldDidEndEditing here:
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 1.5){
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }    }

    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve from Firebase
    
    
    
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextfield.endEditing(true)
        //TODO: Send the message to Firebase and save it in our database
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        
        let messagesDB = FIRDatabase.database().reference().child("Messages")
        
        let messageDictionary = ["Sender": FIRAuth.auth()?.currentUser?.email, "messageBody": messageTextfield.text! ]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, ref) in
            if error != nil {
                print(error ?? "Not an error")
            } else {
                print("Message saved succesfully")
            }
            self.messageTextfield.text = ""
            self.messageTextfield.isEnabled = true
            self.sendButton.isEnabled = true
        }
    }
    
    //TODO: Create the retrieveMessages method here:
    func retriveMessages() {
        let messageDB = FIRDatabase.database().reference().child("Messages")
        messageDB.observe(.childAdded, with: {(snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String, String>
            let text = snapshotValue["messageBody"]!
            let sender = snapshotValue["Sender"]!

            let message = Message(sender: sender, messageBody: text)
            self.messageArray.append(message)
            print(text)
            print(sender)
            
            self.configureTableView()
            self.messageTableView.reloadData()
        })
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        do {
            try FIRAuth.auth()?.signOut()
        } catch {
            print("error there was a problem to signing out")
        }
        
        guard(navigationController?.popToRootViewController(animated: true) ) != nil
            else {
                print("No View Controller to pop up")
                return
        }
        
        
        //TODO: Log out the user and send them back to WelcomeViewController
        
        
    }
    


}
