//
//  ContactTableViewController.swift
//  Sangoo_01_01
//
//  Created by Florenz Erstling on 29.01.17.
//  Copyright © 2017 Florenz. All rights reserved.
//

import UIKit
import RealmSwift


class ConnectTableViewController: UITableViewController {
    
    // MARK: Model
    
    var notificationToken: NotificationToken!
    var realm: Realm!
    var realmHelper = RealmHelper()
    var connectLists = List<ConnectList>()
    var user = User()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        quickTest()
        setupUI()
        setupRealm(syncUser: SyncUser.current!)
    }
    override func viewDidAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    func setupUI() {
        self.tabBarController?.tabBar.isHidden = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createGroup))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchGroup))
    }
    
    
    
    
    func setupRealm(syncUser : SyncUser) {
        
        DispatchQueue.main.async {
            
            self.realm = self.realmHelper.iniRealm(syncUser: syncUser)
            //self.connectLists = self.realmHelper.getUser(user: self.user).geoData
            self.tableView.reloadData()
            
        }
        
    }
    
    func quickTest () {
        
        let v = InstantGroupJSQMessagesViewController()
        navigationController?.pushViewController(v, animated: false)
        
    }
    
    func searchGroup() {
        print("search")
        goToSearchGroupTableViewController()
    }
    
    func goToSearchGroupTableViewController() {
        let v = SearchGroupTableViewController()
        navigationController?.pushViewController(v, animated: true)
    }

    func createGroup() {
        
        print("create")
        goToCreateTableViewController()
    }
    
    func goToCreateTableViewController() {
        
        let v = CreateGroupTableViewController()
        navigationController?.pushViewController(v,animated:true)
        
    }
    
    
    // MARK: tableView
    
    
    override func tableView(_ tableView: UITableView?, numberOfRowsInSection section: Int) -> Int {
        return connectLists.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        //let item = connectLists[indexPath.row]
        //cell.textLabel?.text = item.connectList.connectDescription[0].dataValue
        cell.textLabel?.text = "moin"
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let messages = connectLists[indexPath.row]
        goToGroupView(realm: realm, messages: messages)
    }
    
    func goToGroupView(realm : Realm, messages : ConnectList?) {
        
        let v = GroupViewTableViewController()
        v.receivedRealm = realm
        v.receivedGroup = messages
        navigationController?.pushViewController(v, animated: true)
        
    }
    
    // MARK: Functions
}
