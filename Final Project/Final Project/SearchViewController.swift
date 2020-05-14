//
//  SearchViewController.swift
//  Final Project
//
//  Created by Riya Narayan on 17/4/20.
//  Copyright © 2020 Riya Narayan. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

struct Item: Equatable {
    let id: String
    let title: String
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id && lhs.title == rhs.title
    }
}

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    var searchShows = true // false means searchAccounts
    var searchResults = [Item]()
    var showsArr = [Item]()
    var accountsArr = [Item]()
    var accountsUID = [String]() //parallel to accountsArr
    let user = Auth.auth().currentUser
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        ref = Database.database().reference()
        accountsArr = []
        showsArr = []
        refHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let users = value["users"] as? [String: NSDictionary] ?? [:]
                for (key, value) in users {
                    let uid = key
                    if (uid != self.user?.uid) {
                        let first = value["firstName"] as! String
                        let last = value["lastName"] as! String
                        let newUser = Item(id: uid, title: "\(first) \(last)")
                        if (!self.accountsArr.contains(newUser)) {
                            self.accountsArr.append(newUser)
                        }
                    }
                }
                let tvshows = value["movies"] as? [NSDictionary] ?? []
                for value in tvshows {
                    let title = value["title"] as! String
                    let id = value["id"] as! Int
                    let newShow = Item(id: "\(id)", title: title)
                    if (!self.showsArr.contains(newShow)) {
                        self.showsArr.append(newShow)
                    }
                }
            }
            DispatchQueue.main.async {
                self.searchResults = self.searchShows ? self.showsArr : self.accountsArr
                self.tableView.reloadData()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        segmentControl.selectedSegmentIndex = 0
        searchShows = true
        searchResults = showsArr
        searchBar.text = ""
        tableView.reloadData()
    }
    
    @IBAction func onSelectSwitchView(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
            case 0: searchShows = true
            case 1: searchShows = false
            default: searchShows = true
        }
        searchResults = searchShows ? showsArr : accountsArr
        searchBar.text = ""
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "accountSegue" {
            if let nav = segue.destination as? UINavigationController {
                if let accvc = nav.viewControllers[0] as? AccountViewController {
                    if let id = sender as? String {
                        accvc.userId = id
                    }
                }
            }
        }
        if segue.identifier == "showSegue" {
            if let nav = segue.destination as? UINavigationController {
                if let sdvc = nav.viewControllers[0] as? ShowDetailsViewController {
                    if let id = sender as? String {
                        sdvc.id = id
                    }
                }
            }
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResults = searchShows ? showsArr.filter({$0.title.prefix(searchText.count) == searchText}) : accountsArr.filter({$0.title.prefix(searchText.count) == searchText})
        tableView.reloadData()
        print(searchResults)
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell") as! TableViewCell
        cell.userName.text = searchResults[indexPath.row].title
        cell.userProfile.layer.cornerRadius = cell.userProfile.frame.size.height / 2
        cell.userProfile.clipsToBounds = true
        // TODO: user profiles
        cell.userProfile.image = searchShows ? UIImage(systemName: "tv.fill") : UIImage(named: "default_profile")
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (searchShows) {
            performSegue(withIdentifier: "showSegue", sender: searchResults[indexPath.row].id)
        } else {
            performSegue(withIdentifier: "accountSegue", sender: searchResults[indexPath.row].id)
        }
    }
}
