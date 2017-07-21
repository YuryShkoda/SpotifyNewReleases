//
//  JSONTrackParser.swift
//  SpotifyNewReleases
//
//  Created by Yuri Shkoda on 7/20/17.
//  Copyright © 2017 Yurec. All rights reserved.
//

import Foundation

class JSONTrackParser {
    
    func getTracks(json: String) -> [Int] {
        
        guard let tracks = serialize(json: json) else { return [] }
        
        if let tracksDict = tracks as? [String: Any] {
            return getTracks(dict: tracksDict)
        }
        
        if let tracksArray = tracks as? [[String: Any]] {
            return getTracks(array: tracksArray)
        }
        
        return []
    }
    
    private func getTracks(dict: [String: Any]) -> [Int] {
        
        var tracksIDs = [Int]()
        
        for (key, value) in dict {
            if key == "track" {
                if let track = value as? [String: Any],
                    let id = getId(from: track) {
                    tracksIDs.append(id)
                }
                continue
            }
            if let nestedDict = value as? [String: Any] {
                tracksIDs.append(contentsOf: getTracks(dict: nestedDict))
                continue
            }
            if let nestedArray = value as? [[String: Any]] {
                tracksIDs.append(contentsOf: getTracks(array: nestedArray))
            }
        }
        
        return tracksIDs
    }
    
    private func getTracks(array: [[String: Any]]) -> [Int] {
        
        var tracksIDs = [Int]()
        
        for dict in array {
            tracksIDs.append(contentsOf: getTracks(dict: dict))
        }
        return tracksIDs
    }
    
    private func serialize(json: String) -> Any? {
        
        guard let data = json.data(using: .utf8) else { return nil }
        
        do {
            let dictionary = try JSONSerialization.jsonObject(with: data, options: [])
            return dictionary
        } catch {
            print("Error while parsing json: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func getId(from track: [String: Any]) -> Int? {
        return track["id"] as? Int
    }
}
