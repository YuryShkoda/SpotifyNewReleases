//
//  SpotifyTracksFetcher.swift
//  SpotifyNewReleases
//
//  Created by Yuri Shkoda on 7/20/17.
//  Copyright © 2017 Yurec. All rights reserved.
//

import Foundation

class SpotifyTracksFetcher {
    
    enum SpotifyTracksFetcherResult {
        case tracks([Track])
        case error(String)
    }
    
    let urlSession = URLSession(configuration: .default)
    
    func fetchTracks(token: String, album: Album, completion: @escaping (SpotifyTracksFetcherResult) -> ()) {
        
        guard var urlComponents = URLComponents(string: SpotifyEndpoint.album + "/\(album.id)/tracks") else {
            completion(.error("Internal Error: Cannot create URL request."))
            return
        }
        
        //TODO: Fetch if more than 50 tracks in album
        urlComponents.query = "limit=50&offset=0"
        guard let url = urlComponents.url else {
            completion(.error("Internal Error: Cannot create URL request."))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) {(data, response, error) in
            if let error = error {
                print("Tracks fetch error: \(error.localizedDescription)")
                completion(.error("Tracks fetch error: \(error.localizedDescription)"))
                return
            }
            guard let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    completion(.error("Tracks fetch error: response code is not 200"))
                    return
            }
            
            let parser = SpotifyTracksParser()
            let result = parser.parse(data: data)
            switch result {
            case .error(let error): completion(.error(error))
            case .tracks(let tracks):
                let tracksWithAlbum = tracks.map { Track(id: $0.id, name: $0.name, album: album) }
                completion(.tracks(tracksWithAlbum))
            }
        }
        
        task.resume()
    }
}
