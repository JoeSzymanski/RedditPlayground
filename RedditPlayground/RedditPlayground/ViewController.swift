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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
        redditAPI.getTopPosts(loadMore: false) { [weak self] (_) in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return redditAPI.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RedditCell", for: indexPath)
        if indexPath.row < redditAPI.posts.count {
            let post = redditAPI.posts[indexPath.row]
            cell.textLabel?.text = post.title
        } else {
            cell.textLabel?.text = "\(indexPath)"
        }
        return cell
    }
}
