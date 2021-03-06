//
//  ContactTableViewController.swift
//  Sangoo_01_01
//
//  Created by Florenz Erstling on 29.01.17.
//  Copyright © 2017 Florenz. All rights reserved.
//

import UIKit
import RealmSwift
import MapKit
import GeoQueries


class SearchGroupTableViewController: UITableViewController {
    
    // MARK: Model
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
        self.setupUI()
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
    }
    
    func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
                self.tableView.reloadData()
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
    
    
    // MARK: tableView
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
    
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
//    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //let item = results?[indexPath.row]
        let item = messages[indexPath.row]
        cell.textLabel?.text = item.messageText
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    // MARK: Functions
    
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
