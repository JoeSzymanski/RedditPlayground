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

    /// Access to the table view
    @IBOutlet weak var tableView: UITableView!
    
    /// Reddit posts to display in the table
    var posts: [Int] = [0,0,0,0,0]

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        redditAPI.getTopPosts()
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RedditCell", for: indexPath)
        cell.textLabel?.text = "\(indexPath)"
        return cell
    }
}
