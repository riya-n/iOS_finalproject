//
//  ShowDetailsViewController.swift
//  Final Project
//
//  Created by Riya Narayan on 17/4/20.
//  Copyright © 2020 Riya Narayan. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseAuth
import SDWebImage

class ShowDetailsViewController: UIViewController {
    
    @IBOutlet weak var posterView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var yearView: UILabel!
    @IBOutlet weak var descView: UITextView!
    @IBOutlet weak var starButton: UIButton!
    var id: String!
    let currUserId = Auth.auth().currentUser?.uid
    var ref: DatabaseReference!
    var refHandle: DatabaseHandle!
    var currTVShow: TVShow!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        ref = Database.database().reference()
        print("in show detail")
        let intId = Int(id) ?? -1
        refHandle = ref.child("movies").child("\(intId - 1)").observe(DataEventType.value, with: { (snapshot) in
            if let value = snapshot.value as? NSDictionary {
                let title = value["title"] as! String
                let year = value["year"] as! String
                let description = value["plot"] as! String
                let poster = value["posterUrl"] as! String
                let users = value["users"] as? String ?? ""
                let accounts = users.components(separatedBy: ", ")
                self.currTVShow = TVShow(title: title, description: description, year: year, poster: poster, id: Int(self.id) ?? -1, users: users)
                self.starButton.setBackgroundImage(UIImage(systemName: "star"), for: .normal)
                if (accounts.contains(self.currUserId!)) {
                    self.starButton.setBackgroundImage(UIImage(systemName: "star.fill"), for: .normal)
                }
                DispatchQueue.main.async {
                    self.titleView.text = title
                    self.yearView.text = year
                    self.descView.text = description
                }
                self.posterView.sd_setImage(with: URL(string: poster), placeholderImage: UIImage(named: "placeholder.png"))
            }
        })
    }
    
    @IBAction func didSelectDone(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSelectStar(_ sender: UIButton) {
        if (self.starButton.currentBackgroundImage == UIImage(systemName: "star")) {
            self.starButton.setBackgroundImage(UIImage(systemName: "star.fill"), for: .normal)
            let addShow = [
                "title": currTVShow.title,
                "description": currTVShow.description,
                "year": currTVShow.year,
                "poster": currTVShow.poster,
                "id": currTVShow.id
            ] as [String : Any]
            self.ref.child("users").child(self.currUserId!).child("shows").child("show\(currTVShow.id)").setValue(addShow)
            
            var newUsers = ""
            if (currTVShow.users == "") {
                newUsers = "\(self.currUserId!)"
            } else {
                newUsers = "\(currTVShow.users!), \(self.currUserId!)"
            }
            print(newUsers)
            self.ref.child("movies").child("\(currTVShow.id - 1)").child("users").setValue(newUsers)
            
        } else {
            self.starButton.setBackgroundImage(UIImage(systemName: "star"), for: .normal)
            ref.child("users").child(currUserId!).child("shows").child("show\(currTVShow.id)").removeValue()
            
            var users = currTVShow.users?.components(separatedBy: ", ") ?? []
            let index = users.firstIndex(of: currUserId!) ?? -1
            users.remove(at: index)
            ref.child("movies").child("\(currTVShow.id - 1)").child("users").setValue(users.joined(separator: ", "))
            
            
        }
    }
}
