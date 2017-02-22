//
//  UserDataTableViewController.swift
//  Sangoo_01_01
//
//  Created by Florenz Erstling on 29.01.17.
//  Copyright © 2017 Florenz. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsTableViewController: UITableViewController {
    
    var notificationToken: NotificationToken!
    var realm: Realm!
    
    var textField = UISettings()
    
    let cookie = LocalCookie()
    
    var items = List<ConnectData>()
    
    var authData = AuthData()
    var user = User()
    var userData = List<ConnectData>()
    var realmHelper = RealmHelper()
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //iniDummy()
        setupUI()
        setupRealm(syncUser: SyncUser.current!)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!cookie.check()){
            print("nicht Eingeloggtt")
            goBackToLandingPage()
        }
    }
    
        
    func setupUI() {
        
        title = "Einstellungen"
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "demoCell")
        tableView.backgroundColor = UIColor(red: 0.949,green: 0.949,blue: 0.949,alpha: 1)
        tableView.separatorStyle = .none

        
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editUserData))
        
        
    }
    
    
    func setupRealm(syncUser : SyncUser) {
        
        DispatchQueue.main.async {

            self.realm = self.realmHelper.iniRealm(syncUser: syncUser)
            self.userData = self.realmHelper.getUser(user: self.user).userData
            self.tableView.reloadData()

        }

    }
    
    
        func iniDummy() {
//        print("jo")
//        authData.userName = "Hans23"
//        authData.userPassword = "asdfsdf234234"
//        
//        userData.userId = authData.userId
//        userData.userFirstName = "Hans"
//        userData.userLastName = "Peter"
//        userData.userEmail = "hans@gxm.de"
//        userData.userPhone = "23423234234"
    }
    

    
    func editUserData() {
        
        print("Edit")
        goBackToEditSettings()
        
    }
    
    func goBackToLandingPage(){
        
        
        let v = LandingPageTableViewController()
        self.tabBarController?.tabBar.isHidden = false
        v.tabBarController?.tabBar.isHidden = false
        // hide Navigation Bar
        navigationController?.isNavigationBarHidden = true
        navigationController?.pushViewController(v, animated: true)
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    func goBackToEditSettings(){
        
        
        let v = EditSettingsTableViewController()
        navigationController?.pushViewController(v, animated: true)
        
    }
    
    // MARK: - Table view data source

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return userData.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "demoCell", for: indexPath)
        cell.selectionStyle = .none
        
        //disableSelection
        print(indexPath.row)
        if indexPath.row == userData.count && indexPath.row != 0 {
            cell.textLabel?.text = "Ausloggen"
            cell.textLabel?.textColor = UIColor.blue
            
        } else if indexPath.row < userData.count {
            let data = userData[indexPath.row]
            let textField = UISettings()
            textField.setupTextField(description: data.descriptionGerman, text: data.dataValue)
            cell.addSubview(textField.textField)
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == userData.count{
            logout()
        }
    }
    
    func logout() {
        print("Logout")
        cookie.removeCookie()
        goBackToLandingPage()
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

    
    

}
