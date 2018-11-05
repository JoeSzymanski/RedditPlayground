//
//  RedditAPI.swift
//  RedditPlayground
//
//  Created by Joe Szymanski on 11/4/18.
//  Copyright © 2018 RedditPlayground. All rights reserved.
//

import Foundation

class RedditAPI {
    /// Basic device identifier for the client in this session
    var deviceId: String
    /// The current Access Token provided by Reddit oAuth
    var accessToken: String?

    init() {
        if let redditDeviceId = UserDefaults.standard.string(forKey: "reddit_device_id") {
            deviceId = redditDeviceId
        } else {
            deviceId = NSUUID().uuidString.lowercased()
            UserDefaults.standard.set(deviceId, forKey: "reddit_device_id")
        }
    }

    func getTopPosts(completion: @escaping (_ httpSuccessData: Data?, _ error: Error?) -> Void) {
    }

    /// Gets a new oAuth token from Reddit for reading from public APIs
    func getOAuthToken() {
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
            guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                return
            }
            self?.accessToken = json?["access_token"] as? String
        }
        task.resume()
    }
}
