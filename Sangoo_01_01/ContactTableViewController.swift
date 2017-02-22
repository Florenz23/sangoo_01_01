//
//  ContactTableViewController.swift
//  Sangoo_01_01
//
//  Created by Florenz Erstling on 29.01.17.
//  Copyright © 2017 Florenz. All rights reserved.
//

import UIKit
import RealmSwift


class ContactTableViewController: UITableViewController {
    
    // MARK: Model
    
    var userRelation = List<GeoData>()
    var user = User()
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    let cookie = LocalCookie()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupRealm()
    }
    
    func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    
    func setupRealm() {
        
        setRealm(user: SyncUser.current!)
        defineUpdateList()
        
    }
    
    func setRealm(user : SyncUser) {
                
        DispatchQueue.main.async {
            // Open Realm
            let configuration = Realm.Configuration(
                syncConfiguration: SyncConfiguration(user: user, realmURL: URL(string: "realm://10.0.1.4:9080/~/sangoo")!)
            )
            self.realm = try! Realm(configuration: configuration)
            
        }
        
    }
    
    func goToDetailContacts(sharedData : List<ConnectData>){
        
        
        let v = DetailContactTableViewController()
        v.sharedData = sharedData
        navigationController?.pushViewController(v, animated: true)
        
    }
    
    func defineUpdateList() {
        
        let userId = cookie.getData()
        DispatchQueue.main.async {
            // Show initial tasks
            func updateData() {
                if self.userRelation.realm == nil, let list = self.realm.objects(User.self).filter("userId == '\(userId)'").first {
                    self.userRelation = list.geoData
                }
                self.tableView.reloadData()
            }
            updateData()
            
            // Notify us when Realm changes
            self.notificationToken = self.realm.addNotificationBlock { _ in
                updateData()
            }
        }
    }
    
    deinit {
        notificationToken.stop()
    }
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return userRelation.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = userRelation[indexPath.row]
        cell.textLabel?.text = item.connectList?.connectUserList[0].userDescription[0].dataValue
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToDetailContacts(sharedData: (userRelation[indexPath.row].connectList?.connectUserList[0].userDataShared)!)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 60
        } else if indexPath.row == 1 {
            return 60
        } else {
            return 60
        }
    }

    
    
    
    
    // MARK: tableView
    
    
   
    
    
    }
