//
//  AccountViewController.swift
//  Final Project
//
//  Created by Riya Narayan on 17/4/20.
//  Copyright © 2020 Riya Narayan. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth

class AccountViewController: UIViewController {
    
    @IBOutlet weak var promptMsg: UILabel!
    @IBOutlet var profilePicture: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var usersShows: UILabel!
    @IBOutlet weak var follow: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var signOut: UIBarButtonItem!
    var userId: String!
    var currUserId = Auth.auth().currentUser?.uid
    var userFollowers: String = ""
    var currFollowing: String = ""
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    var userShows = [TVShow]()
    var currShows = [TVShow]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        self.profilePicture.layer.cornerRadius = profilePicture.frame.size.height / 2
        self.profilePicture.clipsToBounds = true
        promptMsg.isHidden = true
        ref = Database.database().reference()
        if (userId == Auth.auth().currentUser?.uid) {
            follow.isHidden = true
            email.isHidden = false
            signOut.isEnabled = true
            signOut.title = "Sign Out"
        } else {
            follow.isHidden = false
            email.isHidden = true
            signOut.isEnabled = false
            signOut.title = ""
        }
        currShows = []
        userShows = []
        refHandle = ref.child("users").observe(DataEventType.value, with: { (snapshot) in
            if let users = snapshot.value as? [String: NSDictionary] {
                for (key, value) in users {
                    if (key == self.currUserId) {
                        self.currFollowing = value["following"] as! String
                        let shows = value["shows"] as? [String: NSDictionary] ?? [:]
                        for (_, value) in shows {
                            let title = value["title"] as! String
                            let description = value["description"] as! String
                            let year = value["year"] as! String
                            let poster = value["poster"] as! String
                            let id = value["id"] as! Int
                            let tvShow = TVShow(title: title, description: description, year: year, poster: poster, id: id)
                            if (!self.currShows.contains(tvShow)) {
                                self.currShows.append(tvShow)
                            }
                            print(value)
                        }
                    }
                    if (key == self.userId) {
                        print(value)
                        let firstName = value["firstName"] as! String
                        let lastName = value["lastName"] as! String
                        // TODO: add profile picture
                        let profilePicture = value["profilePicture"] as? String ?? ""
                        let email = value["email"] as! String
                        if (self.userId != self.currUserId) {
                            self.userFollowers = value["followers"] as! String
                            let users = self.userFollowers.components(separatedBy: ", ")
                            self.follow.setTitle("Follow", for: .normal)
                            self.follow.setTitleColor(UIColor.white, for: .normal)
                            self.follow.backgroundColor = UIColor.systemBlue
                            if (users.contains(self.currUserId!)) {
                                self.follow.setTitle("Unfollow", for: .normal)
                                self.follow.setTitleColor(UIColor.systemBlue, for: .normal)
                                self.follow.backgroundColor = UIColor.systemFill
                            }
                        }
                        let shows = value["shows"] as? [String: NSDictionary] ?? [:]
                        for (_, value) in shows {
                            let title = value["title"] as! String
                            let description = value["description"] as! String
                            let year = value["year"] as! String
                            let poster = value["poster"] as! String
                            let id = value["id"] as! Int
                            let tvShow = TVShow(title: title, description: description, year: year, poster: poster, id: id)
                            if (!self.userShows.contains(tvShow)) {
                                self.userShows.append(tvShow)
                            }
                            print(value)
                        }
                        print(self.userShows)
                        
                        DispatchQueue.main.async {
                            self.name.text = firstName + " " + lastName
                            self.email.text = email
                            if (self.userId == self.currUserId) {
                                self.usersShows.text = "My Movies"
                            } else {
                                self.usersShows.text = firstName + "'s Movies"
                            }
                            self.profilePicture.image = UIImage(named: profilePicture) ?? UIImage(named:"default_profile")
                            if (self.userShows.count > 0) {
                                self.promptMsg.isHidden = true
                            } else {
                                self.promptMsg.isHidden = false
                            }
                            self.collectionView.reloadData()
                        }
                    }
                }
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        collectionView.reloadData()
    }
    
    @IBAction func didSelectDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSelectSignOut(_ sender: UIBarButtonItem) {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print ("Error signing out: %@", signOutError)
        }
        self.performSegue(withIdentifier: "startSegue", sender: nil)
    }
    
    @IBAction func didSelectFollow(_ sender: UIButton) {
        if (sender.titleLabel!.text! == "Follow") {
            sender.setTitle("Unfollow", for: .normal)
            sender.setTitleColor(UIColor.systemBlue, for: .normal)
            sender.backgroundColor = UIColor.systemFill
        } else {
            sender.setTitle("Follow", for: .normal)
            sender.setTitleColor(UIColor.white, for: .normal)
            sender.backgroundColor = UIColor.systemBlue
        }
        changeFollowAccounts(sender.titleLabel!.text!)
    }
    
    func changeFollowAccounts(_ status: String) {
        if (status == "Unfollow") {
            var users = userFollowers.components(separatedBy: ", ")
            let index = users.firstIndex(of: currUserId!) ?? -1
            users.remove(at: index)
            ref.child("users").child(userId).child("followers").setValue(users.joined(separator: ", "))
            
            var accounts = currFollowing.components(separatedBy: ", ")
            let i = accounts.firstIndex(of: userId) ?? -1
            accounts.remove(at: i)
            ref.child("users").child(currUserId!).child("following").setValue(accounts.joined(separator: ", "))

        } else {
            if (userFollowers.isEmpty) {
                userFollowers = "\(currUserId!)"
            } else {
                userFollowers = "\(userFollowers), \(currUserId!)"
            }
            ref.child("users").child(userId).child("followers").setValue(userFollowers)
            
            if (currFollowing.isEmpty) {
                currFollowing = "\(userId!)"
            } else {
                currFollowing = "\(currFollowing), \(userId!)"
            }
            ref.child("users").child(currUserId!).child("following").setValue(currFollowing)
        }
    }
    
    @IBAction func onClickStar(_ sender: UIButton) {
        if (sender.imageView?.image == UIImage(systemName: "star")) {
            sender.setImage(UIImage(systemName: "star.fill"), for: .normal)
            let showName = (view.viewWithTag(sender.tag + 1) as! UILabel).text ?? ""
            let index = userShows.firstIndex(where: { $0.title == showName }) ?? -1
            let show = userShows[index]
            let addShow = [
                "title": show.title,
                "description": show.description,
                "year": show.year,
                "poster": show.poster,
                "id": show.id
            ] as [String : Any]
            self.ref.child("users").child(self.currUserId!).child("shows").child("show\(show.id)").setValue(addShow)
            
            ref?.child("movies").child("\(show.id - 1)").child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                if var usersString = snapshot.value as? String {
                    print(usersString)
                    if (usersString == "") {
                        usersString = "\(self.currUserId!)"
                    } else {
                        usersString = "\(usersString), \(self.currUserId!)"
                    }
                    print(usersString)
                    self.ref.child("movies").child("\(show.id - 1)").child("users").setValue(usersString)
                    
                }
            })
        } else {
            sender.setImage(UIImage(systemName: "star"), for: .normal)
            let showName = (view.viewWithTag(sender.tag + 1) as! UILabel).text ?? ""
            let index = currShows.firstIndex(where: { $0.title == showName }) ?? -1
            var show = currShows[index]
            self.currShows.remove(at: index)
            if (userId == currUserId) {
                let index = userShows.firstIndex(where: { $0.title == showName }) ?? -1
                // TODO: test this - was let show = userShows[index] earlier
                show = userShows[index]
                self.userShows.remove(at: index)
            }
                
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                self.tvShowUnstared(show, index)
                self.collectionView.reloadData()
            })
        }
    }
        
    func tvShowUnstared(_ show: TVShow, _ index: Int) {        ref.child("users").child(currUserId!).child("shows").child("show\(show.id)").removeValue()
          
        ref?.child("movies").child("\(show.id - 1)").child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let usersString = snapshot.value as? String {
                var users = usersString.components(separatedBy: ", ")
                let index = users.firstIndex(of: self.currUserId!) ?? -1
                users.remove(at: index)
                self.ref.child("movies").child("\(show.id - 1)").child("users").setValue(users.joined(separator: ", "))
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSegue" {
            if let nav = segue.destination as? UINavigationController {
                if let sdvc = nav.viewControllers[0] as? ShowDetailsViewController {
                    if let id = sender as? String {
                        sdvc.id = id
                    }
                }
            }
        }
        if segue.identifier == "startSegue" {
            if let startvc = segue.destination as? StartViewController {
                // add delegates and data to send here
            }
        }
    }
}

extension AccountViewController: UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userShows.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionViewCell
        cell.starIcon.tag = indexPath.row * 3
        cell.showTitle.tag = indexPath.row * 3 + 1
        cell.showPoster.tag = indexPath.row * 3 + 2
        if (userId == currUserId) {
            cell.starIcon.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else if (currShows.contains(userShows[indexPath.item])) {
            cell.starIcon.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            cell.starIcon.setImage(UIImage(systemName: "star"), for: .normal)
        }
        cell.showTitle.text = userShows[indexPath.item].title
        cell.showPoster.sd_setImage(with: URL(string: self.userShows[indexPath.item].poster), placeholderImage: UIImage(named: "placeholder.png"))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showSegue", sender: userShows[indexPath.row].id)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  50
        let width = self.collectionView.frame.size.width - padding
        return CGSize(width: width/2, height: 300)
    }
    
//        func imagePickerController(_ picker: UIImagePickerController,
//        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//            print("first here")
//            if let selectedImage = info[.originalImage] as? UIImage {
//                self.profilePicture.image = selectedImage
//                print("in here")
//                print(selectedImage)
//                // TODO: extra
//    //            print(selectedImage.accessibilityIdentifier)
//    //            ref.child("users").child(user!.uid).child("profilePicture").setValue(selectedImage.accessibilityIdentifier ?? "")
//            }
//            dismiss(animated: true, completion: nil)
//        }
//
//    //    @IBAction func gestureRecognizer() {
//    //        if (user == Auth.auth().currentUser) {
//    //            self.presentImagePicker()
//    //        }
//    //    }
//
//        func presentImagePicker() {
//            let picker = UIImagePickerController()
//            picker.delegate = self
//            picker.sourceType = .photoLibrary
//            present(picker, animated: true, completion: nil)
//        }
}
