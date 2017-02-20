//
//  ViewController.swift
//  UIChat
//
//  Created by Florenz Erstling on 14.02.17.
//  Copyright © 2017 Florenz. All rights reserved.
//

import UIKit
import RealmSwift
import MapKit
import GeoQueries
import JSQMessagesViewController

class InstantGroupJSQMessagesViewController: JSQMessagesViewController {
    
    var jsqMessages = [JSQMessage]()
    var notificationToken: NotificationToken!
    var realm: Realm!
    var realmHelper = RealmHelper()
    var results : [GeoData]?
    var groups = [GeoData]()
    var messages = List<Message>()
    var user = User()
    let cookie = LocalCookie()
    let locationManager = LocationManager()
    var currentLocation : CLLocationCoordinate2D?
    let connectGroup = ConnectGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        if (!cookie.check()){
            print("nicht Eingeloggtt")
            goBackToLandingPage()
            
        } else {
            self.locationManager.getCurrentLocation { (result) in
                switch result
                {
                case .Success(let location):
                    self.currentLocation = location
                    self.setupRealm(syncUser: SyncUser.current!)
                    break
                case .Failure(let error):
                    print(error as Any)
                    /* present an error */
                    break
                }
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    func addMessages() {
        jsqMessages.append(JSQMessage(senderId: "1", displayName: "Jo",text:"moin"))
        jsqMessages.append(JSQMessage(senderId: "2", displayName: "Ja",text:"heil"))
        collectionView.reloadData()
    }
    
    
    func setupRealm(syncUser : SyncUser) {
        
        DispatchQueue.main.async {
            
            self.realm = self.realmHelper.iniRealm(syncUser: syncUser)
            self.user = self.realmHelper.getUser(user: self.user)
            func updateList() {
                let radius = 50.00 // 50m
                self.results = try! self.realm.findNearby(type: GeoData.self, origin: self.currentLocation!, radius: radius, sortAscending: true)
                guard let r = self.results else { return }
                self.messages = (r[0].connectList?.message)!
                self.groups = r
                self.handleSearchResults()
                //self.tableView.reloadData()
            }
            updateList()
            // Notify us when Realm changes
            self.notificationToken = self.user.realm?.addNotificationBlock { _ in
                updateList()
            }
        }
        
    }
    deinit {
        notificationToken.stop()
    }
    
    func handleSearchResults() {
        if groups.count == 0 {
            self.connectGroup.createNewGroup(user: self.user, location: self.currentLocation!, realm: self.realm)
        } else {
            self.checkIfUserIsGroupMember()
        }
    }
    
    func checkIfUserIsGroupMember() {
        
        let userId = cookie.getData()
        let group = self.groups[0]
        let userIsMember = connectGroup.checkIfUserIsGroupMember(userId: userId , group: group)
        print(userId)
        print (userIsMember)
        if (!userIsMember) {
            connectGroup.suscribeUserInGroup(user: self.user, group: group, realm: self.realm)
        }
        
    }
    
    
    // JSQMessenger
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let senderId = "1"
        let senderDisplayName = "DonaldTrump"
        print("moin")
        print("\(text)")
        jsqMessages.append(JSQMessage(senderId:senderId, displayName: senderDisplayName,text:text))
        collectionView.reloadData()
        print(messages)
    }
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
        print("Accessory Button")
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return jsqMessages[indexPath.item]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let bubblefactory = JSQMessagesBubbleImageFactory()
        return bubblefactory!.outgoingMessagesBubbleImage(with: .black)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    // table View
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        return cell
    }
    
    // goBack
    
    func goBackToLandingPage(){
        
        
        let v = LandingPageTableViewController()
        self.tabBarController?.tabBar.isHidden = false
        v.tabBarController?.tabBar.isHidden = false
        // hide Navigation Bar
        navigationController?.isNavigationBarHidden = true
        navigationController?.pushViewController(v, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
}


