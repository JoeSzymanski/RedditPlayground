//
//  ViewController.swift
//  RedditPlayground
//
//  Created by Joe Szymanski on 11/4/18.
//  Copyright © 2018 RedditPlayground. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    /// Reddit API management class instance
    let redditAPI = RedditAPI()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redditAPI.getTopPosts()
    }
}

