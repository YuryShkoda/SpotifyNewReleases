//
//  LoginVC.swift
//  SpotifyNewReleases
//
//  Created by Yuri Shkoda on 7/19/17.
//  Copyright © 2017 Yurec. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    @IBAction func loginPressed(_ sender: Any) {
        Spotify.shared.login(from: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        NotificationCenter.default.addObserver(self, selector: #selector(sessionUpdated), name: Spotify.sessionUpdatedNotification, object: nil)
    }
    
    // Should be called on launch
    func setup() {
        let auth = SPTAuth.defaultInstance()!
        auth.clientID = "582788db3cc74332bfd5053451335baa"
        auth.requestedScopes = []
        auth.redirectURL = URL(string: "spotifyNewReleases-072017://")!
        auth.sessionUserDefaultsKey = "SpotifySession"
    }
    
    func sessionUpdated() {
        
        presentedViewController?.dismiss(animated: true, completion: nil)
        
        guard Spotify.shared.sessionIsValid() else {
            print("Invalid session")
            return
        }
        
        performSegue(withIdentifier: "toMainVC", sender: nil)
    }
}
