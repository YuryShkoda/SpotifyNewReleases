//
//  SpotifyAlbumParser.swift
//  SpotifyNewReleases
//
//  Created by Yuri Shkoda on 7/20/17.
//  Copyright © 2017 Yurec. All rights reserved.
//

import Foundation

class SpotifyAlbumParser {
    
    typealias SpotifyAlbumParserResult = SpotifyAlbumFetcher.SpotifyAlbumFetcherResult
    
    func parse(data: Data) -> SpotifyAlbumParserResult {
        
        guard let dict = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else {
            return .error("Failed to serialize data.")
        }
        guard let albumsDict = dict["albums"] as? [String: Any] else {
            return .error("Unknown data format.")
        }
        
        guard let items = albumsDict["items"] as? [[String: Any]] else {
            return .error("Unknown data format.")
        }
        
        return .albums(items.flatMap { parse(item: $0) })
    }
    
    private func parse(item: [String: Any]) -> Album? {
        
        guard let id = item["id"] as? String,
            let name = item["name"] as? String,
            let artists = item["artists"] as? [[String: Any]] else {
                return nil
        }
        
        let artistsNames = artists.flatMap({ (artist) in
            return artist["name"] as? String
        })
        
        let artistsJoined = artistsNames.joined(separator: ", ")
        
        return Album(id: id, name: name, artists: artistsJoined)
    }
}
