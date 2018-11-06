//
//  RedditTableViewCell.swift
//  RedditPlayground
//
//  Created by Joe Szymanski on 11/5/18.
//  Copyright © 2018 RedditPlayground. All rights reserved.
//

import UIKit

class RedditTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var author: UILabel!
    @IBOutlet weak var numComments: UILabel!
}
