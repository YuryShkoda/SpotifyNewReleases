//
//  Spotify.swift
//  SpotifyNewReleases
//
//  Created by Yuri Shkoda on 7/19/17.
//  Copyright © 2017 Yurec. All rights reserved.
//

import Foundation
import SafariServices

class Spotify {
    
    private let clientID = "582788db3cc74332bfd5053451335baa"
    private let clientSecret = "35b1eaeb565a4369aa05ca82789c6dd9"
    
    static let sessionUpdatedNotification = Notification.Name("SpotifySessionUpdated")
    
    static let shared = Spotify()
    
    // Check if opening url is spotify
    func canHandle(url: URL) -> Bool {
        return SPTAuth.defaultInstance().canHandle(url)
    }
    
    // Call if canHandle succeeded
    func handle(url: URL) {
        let auth = SPTAuth.defaultInstance()!
        auth.handleAuthCallback(withTriggeredAuthURL: url) { (error, session) in
            if let error = error {
                print("Failed to auth. Error: \(error.localizedDescription)")
                return
            }
            auth.session = session
            NotificationCenter.default.post(name: Spotify.sessionUpdatedNotification,
                                            object: nil)
        }
    }
    
    // Logging in
    func login(from viewController: UIViewController) {
        
        let auth = SPTAuth.defaultInstance()!
        
        if SPTAuth.supportsApplicationAuthentication() {
            let url = auth.spotifyAppAuthenticationURL()!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        
        let url = auth.spotifyWebAuthenticationURL()!
        let safariViewController = SFSafariViewController(url: url)
        viewController.present(safariViewController, animated: true, completion: nil)
    }
    
    func sessionIsValid() -> Bool {
        let auth = SPTAuth.defaultInstance()!
        guard let session = auth.session else { return false }
        return session.isValid()
    }
    
    func getToken() -> String? {
        guard sessionIsValid() else { return nil }
        let auth = SPTAuth.defaultInstance()!
        return auth.session.accessToken
    }
}
