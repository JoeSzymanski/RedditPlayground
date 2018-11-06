//
//  RedditAPI.swift
//  RedditPlayground
//
//  Created by Joe Szymanski on 11/4/18.
//  Copyright © 2018 RedditPlayground. All rights reserved.
//

import Foundation

/// Class to manage a single Reddit post
struct RedditPost {
    let thumbnail: String
    let title: String
    let author: String
    let createdAt: Date
    let subreddit: String
    let numComments: Int
    let contentUrl: URL?

    init?(withJson json: [String: Any]) {
        var data = json
        if let childData = json["data"] as? [String: Any] {
            data = childData
        }
        thumbnail = data["thumbnail"] as? String ?? ""
        title = data["title"] as? String ?? ""
        author = data["author"] as? String ?? ""
        createdAt = Date(timeIntervalSince1970: data["created"] as? Double ?? 0)
        subreddit = data["subreddit_name_prefixed"] as? String ?? ""
        numComments = data["num_comments"] as? Int ?? 0
        contentUrl = URL(string: data["url"] as? String ?? "")
    }
}

/// Class to manage interaction with the Reddit API
class RedditAPI {
    /// Basic device identifier for the client in this session
    private var deviceId: String
    /// The current Access Token provided by Reddit oAuth
    private var accessToken: String?
    /// Tracking for the "after" identifier to load the next page
    private var afterId: String?
    /// Storage for the array of Reddit posts
    private(set) var posts: [RedditPost] = []

    init() {
        if let redditDeviceId = UserDefaults.standard.string(forKey: "reddit_device_id") {
            deviceId = redditDeviceId
        } else {
            deviceId = NSUUID().uuidString.lowercased()
            UserDefaults.standard.set(deviceId, forKey: "reddit_device_id")
        }
    }

    func getTopPosts(loadMore: Bool = false, completion: @escaping ([RedditPost]) -> Void = { _ in }) {
        getTopPostsRaw(loadMore: loadMore) { [weak self] (json) in
            guard let sSelf = self, let data = json["data"] as? [String: Any] else {
                self?.afterId = nil
                completion([])
                return
            }
            // Track the after identifier to be able to load more data
            sSelf.afterId = data["after"] as? String

            // Convert the JSON data into an array of RedditPost structs
            let newData: [RedditPost]
            if let postData = data["children"] as? [[String: Any]] {
                newData = postData.compactMap { RedditPost(withJson: $0) }
            } else {
                newData = []
            }

            // If we were loading more, append the array to the existing data, otherwise, replace the array with the new data
            if loadMore {
                sSelf.posts += newData
            } else {
                sSelf.posts = newData
            }

            // Make sure to call the completion handler
            completion(sSelf.posts)
        }
    }

    func getTopPostsRaw(loadMore: Bool, completion: @escaping ([String: Any]) -> Void = { _ in }) {
        guard let accessToken = accessToken else {
            getOAuthToken(completion: { self.getTopPostsRaw(loadMore: loadMore, completion: completion) })
            return
        }
        var urlString = "https://oauth.reddit.com/top?raw_json=1&limit=50"
        if loadMore, let afterId = afterId {
            urlString += "&after=\(afterId)"
        }
        guard let URL = URL(string: urlString) else { completion([:]); return }
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        request.setValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        NSLog("Getting Reddit Top posts")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            NSLog("Reddit Top posts API returned with data: \(String(data: data ?? Data(), encoding: .utf8) ?? "")")
            guard let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = jsonObject as? [String: Any] else {
                    completion([:])
                    return
            }
            completion(json)
        }
        task.resume()
    }

    /// Gets a new oAuth token from Reddit for reading from public APIs
    private func getOAuthToken(completion: @escaping () -> Void = {}) {
        guard let URL = URL(string: "https://www.reddit.com/api/v1/access_token") else { return }
        var request = URLRequest(url: URL)
        request.httpMethod = "POST"
        let bodyString = "grant_type=https://oauth.reddit.com/grants/installed_client&device_id=\(deviceId)"
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("Basic \("hpCZ14QWURgJuA:".data(using: .utf8)?.base64EncodedString() ?? "")", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        NSLog("Getting oAuth token")
        let task = URLSession.shared.dataTask(with: request) { [weak self] (data, response, error) in
            NSLog("oAuth token API returned with data: \(String(data: data ?? Data(), encoding: .utf8) ?? "")")
            guard let data = data,
                let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
                let json = jsonObject as? [String: Any] else {
                return
            }
            self?.accessToken = json["access_token"] as? String
            completion()
        }
        task.resume()
    }
}
