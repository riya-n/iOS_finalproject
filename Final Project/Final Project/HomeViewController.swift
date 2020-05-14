//
//  ViewController.swift
//  Final Project
//
//  Created by Riya Narayan on 13/4/20.
//  Copyright © 2020 Riya Narayan. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import Firebase
import SDWebImage

class HomeViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var promptMsg: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var shows = [TVShow]()
    let currUserId = Auth.auth().currentUser?.uid
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        ref = Database.database().reference()
        configureRefreshControl ()

//        getAllData()
        getFollowingData()
        promptMsg.isHidden = true
    }
    
    func configureRefreshControl () {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(handleRefreshControl), for: .valueChanged)
    }

    @objc func handleRefreshControl() {
//        getAllData()
        getFollowingData()
        DispatchQueue.main.async {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
    }
    
    // get all the tv shows
    func getAllData() {
        shows = []
        refHandle = ref.child("movies").observe(DataEventType.value, with: { (snapshot) in
            if let value = snapshot.value as? [NSDictionary] {
                for tvshow in value {
                    let title = tvshow["title"] as! String
                    let description = tvshow["plot"] as! String
                    let year = tvshow["year"] as! String
                    let poster = tvshow["posterUrl"] as! String
                    let id = tvshow["id"] as! Int
                    let users = tvshow["users"] as? String ?? ""
                    let newShow = TVShow(title: title, description: description, year: year, poster: poster, id: id, users: users)
                    var accounts = users.components(separatedBy: ", ")
                    var found = false
                    for user in accounts {
                        if (user == self.currUserId) {
                            found = true
                        }
                    }
                    if (!found && !self.shows.contains(newShow)) {
                        self.shows.append(newShow)
                    }
                }
            }
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        })
    }
    
    // get tv shows favorited by the people you are following
    func getFollowingData() {
        shows = []
        refHandle = ref.observe(DataEventType.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let users = value["users"] as? [String: NSDictionary] ?? [:]
                var following = ""
                var myShows = [Int]()
                for (key, value) in users {
                    if (key == self.currUserId) {
                        following = value["following"] as! String
                        let currShows = value["shows"] as? [String: NSDictionary] ?? [:]
                        for (_, value) in currShows {
                            let id = value["id"] as! Int
                            if (!myShows.contains(id)) {
                                myShows.append(id)
                            }
                        }
                    }
                }
                let followingArr = following.components(separatedBy: ", ")
                var showIds = [Int]() // ids of the shows
                for (key, value) in users {
                    if (followingArr.contains(key)) {
                        let userShows = value["shows"] as? [String: NSDictionary] ?? [:]
                        for (_, value) in userShows {
                            let id = value["id"] as! Int
                            if (!showIds.contains(id) && !myShows.contains(id)) {
                                showIds.append(id)
                            }
                        }
                    }
                }
                let tvshows = value["movies"] as? [NSDictionary] ?? []
                for value in tvshows {
                    let id = value["id"] as! Int
                    if (showIds.contains(id)) {
                        let tvshow = TVShow(title: value["title"] as! String, description: value["plot"] as! String, year: value["year"] as! String, poster: value["posterUrl"] as! String, id: value["id"] as! Int, users: value["users"] as? String ?? "")
                        if (!self.shows.contains(tvshow)) {
                            self.shows.append(tvshow)
                        }
                    }
                }
            }
            DispatchQueue.main.async {
                if (self.shows.count > 0) {
                    self.promptMsg.isHidden = true
                } else {
                    self.promptMsg.isHidden = false
                }
                self.collectionView.reloadData()
            }
        })
    }

    override func viewDidAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    @IBAction func didSelectAccountIcon(_ sender: UIButton) {
        self.performSegue(withIdentifier: "accountSegue", sender: currUserId)
    }
    
    @IBAction func onClickStar(_ sender: UIButton) {
        // star fills and the cell gets removed and added to the users favorite shows
        sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
        let showName = (view.viewWithTag(sender.tag + 1) as! UILabel).text ?? ""
        let index = shows.firstIndex(where: { $0.title == showName }) ?? -1
        print(shows)
        let show = shows[index]
        self.shows.remove(at: index)

        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            
            self.collectionView.reloadData()
            self.tvShowStared(show)
        })
    }
    
    func tvShowStared(_ show: TVShow) {
        let addShow = [
            "title": show.title,
            "description": show.description,
            "year": show.year,
            "poster": show.poster,
            "id": show.id
        ] as [String : Any]
        self.ref.child("users").child(self.currUserId!).child("shows").child("show\(show.id)").setValue(addShow)
        
        var newUsers = ""
        if (show.users == "") {
            newUsers = "\(self.currUserId!)"
        } else {
            newUsers = "\(show.users!), \(self.currUserId!)"
        }
        self.ref.child("movies").child("\(show.id - 1)").child("users").setValue(newUsers)
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
                    if let id = sender as? Int {
                        sdvc.id = "\(id)"
                    }
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return shows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionViewCell
        cell.starIcon.tag = indexPath.row * 3
        cell.showTitle.tag = indexPath.row * 3 + 1
        cell.showPoster.tag = indexPath.row * 3 + 2
        cell.starIcon.setImage(UIImage(systemName: "star"), for: .normal)
        cell.showTitle.text = shows[indexPath.item].title
        cell.showPoster.sd_setImage(with: URL(string: self.shows[indexPath.item].poster), placeholderImage: UIImage(named: "placeholder.png"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showSegue", sender: shows[indexPath.row].id)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  50
        let width = self.collectionView.frame.width - padding
        return CGSize(width: width/2, height: 300)
    }

}

