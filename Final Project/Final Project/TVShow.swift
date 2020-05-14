//
//  TVShow.swift
//  Final Project
//
//  Created by Riya Narayan on 22/4/20.
//  Copyright © 2020 Riya Narayan. All rights reserved.
//

import Foundation
import UIKit

struct TVShow: Equatable {
    var title: String
    var description: String
    var year: String
    var poster: String // of the url
    var id: Int
    var users: String? // uids separated by commas
    
    static func == (lhs: TVShow, rhs: TVShow) -> Bool {
        if (lhs.title == rhs.title && lhs.description == rhs.description && lhs.year == rhs.year && lhs.poster == rhs.poster) {
            return true
        }
        return false
    }
    
}
