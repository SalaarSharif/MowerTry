//
//  ViewController.swift
//  Try
//
//  Created by Hazem Tariq on 12/7/20.
//

import UIKit
import AWSMobileClient
import AWSAppSync
import CoreLocation

class ViewController: UITableViewController {
    
    var appSyncClient: AWSAppSyncClient?
    var users = [AppUser]()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser", for: indexPath)
        
        let user = users[indexPath.row]
        cell.textLabel?.text = user.userName
        cell.detailTextLabel?.text = "\(user.locLat)\(user.locLng)"
        let cellLoc = CLLocation(latitude: user.locLat, longitude: user.locLng)
        var msg = "Unknown"
        if let uLoc = ViewController.userLoc {
            let dist = uLoc.distance(from: cellLoc)
            msg = "\(dist) meters"
        } 

        cell.detailTextLabel?.text = msg
        
        return cell
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.startLocationUpdates()
        
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { (t) in
            if ViewController.userLoc != nil {
                t.invalidate()
                self.tableView.reloadData()
            }
        }
        appSyncClient = (UIApplication.shared.delegate as! AppDelegate).appSyncClient
        
        AWSMobileClient.sharedInstance().initialize { (userState, error) in
            if let uState = userState {
                if uState == .signedOut {
                   // AWSMobileClient.sharedInstance().signOut()
                    AWSMobileClient.sharedInstance().showSignIn(navigationController: self.navigationController!, { (uState2, error) in
                        print (uState2 ?? "none")
                        print (error?.localizedDescription ?? "no error")
                        if let state = uState2, state == .signedIn {
                            
                            let input = CreateAppUserInput.init(userName: AWSMobileClient.sharedInstance().username ?? "error", locLat: 26.290966, locLng: 50.585083)
                            let mut = CreateAppUserMutation(input: input)
                            self.appSyncClient?.perform(mutation: mut, resultHandler: { (result, error) in
                                print (result)
                                print (error)
                                self.fetchUsers()
                            })
                        }
                    })
                }
             else {
                   self.fetchUsers()
                    //AWSMobileClient.sharedInstance().signOut()
               }
            }
        }
    }
    
    func fetchUsers() {
        let q = ListAppUsersQuery()
        let filterInput = ModelStringInput(ne: AWSMobileClient.sharedInstance().username)
        let filter = ModelAppUserFilterInput(userName: filterInput)
        q.filter = filter
        
        appSyncClient?.fetch(query: q, cachePolicy: .fetchIgnoringCacheData, resultHandler: { (results, error) in
            guard error == nil else { return }
            print (results?.data?.listAppUsers?.items ?? "no users")
            if let items = results?.data?.listAppUsers?.jsonObject["items"] as? [[String:Any]] {
                items.forEach({ (dict) in
                    guard let json = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted) else { return }
                    guard let user = try? JSONDecoder().decode(AppUser.self, from: json) else { return }
                    self.users.append(user)
                    self.tableView.reloadData()
                })
            }
        }
        )
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MowerDetailsViewController {
            if let row = tableView.indexPathForSelectedRow?.row {
                let user = self.users[row]
                vc.appUser = user
            }
        }
    }
    
    
    
}

