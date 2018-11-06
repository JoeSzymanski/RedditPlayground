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
        guard let redditCell = cell as? RedditTableViewCell else { return cell }
        if indexPath.row < redditAPI.posts.count {
            let post = redditAPI.posts[indexPath.row]
            redditCell.title.text = post.title
            redditCell.author.text = "Posted by \(post.author), \(post.createdAt.timeAgoString())"
            redditCell.numComments.text = "\(post.numComments) comments"
        } else {
            redditCell.title.text = "\(indexPath)"
        }
        return redditCell
    }
}

extension Date {
    func timeAgoString() -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: Date())
        if let years = components.year {
            if years > 1 {
                return "\(years) years ago"
            } else {
                return "1 year ago"
            }
        } else if let months = components.month {
            if months > 1 {
                return "\(months) months ago"
            } else {
                return "1 month ago"
            }
        } else if let days = components.day {
            if days > 1 {
                return "\(days) days ago"
            } else {
                return "1 day ago"
            }
        } else if let hours = components.hour {
            if hours > 1 {
                return "\(hours) hours ago"
            } else {
                return "1 hour ago"
            }
        } else if let minutes = components.minute {
            if minutes > 1 {
                return "\(minutes) minutes ago"
            } else {
                return "1 minute ago"
            }
        } else if let seconds = components.second {
            if seconds > 1 {
                return "\(seconds) seconds ago"
            } else {
                return "just now ago"
            }
        }
        return ""
    }
}
