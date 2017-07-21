//
//  SpotifyAlbumFetcher.swift
//  SpotifyNewReleases
//
//  Created by Yuri Shkoda on 7/20/17.
//  Copyright © 2017 Yurec. All rights reserved.
//

import Foundation

class SpotifyAlbumFetcher {
    
    enum SpotifyAlbumFetcherResult {
        case albums([Album])
        case error(String)
    }
    
    let urlSession = URLSession(configuration: .default)
    
    func fetchAlbums(token: String, offset: Int, limit: Int = 20, completion: @escaping (SpotifyAlbumFetcherResult) -> ()) {
        
        guard var urlComponents = URLComponents(string: SpotifyEndpoint.newReleases) else {
            completion(.error("Error: Cannot create URL request."))
            return
        }
        
        urlComponents.query = "limit=\(limit)&offset=\(offset)"
        guard let url = urlComponents.url else {
            completion(.error("Error: Cannot create URL request."))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = urlSession.dataTask(with: request) {(data, response, error) in
            if let error = error {
                print("New Releases fetch error: \(error.localizedDescription)")
                completion(.error("New Releases fetch error: \(error.localizedDescription)"))
                return
            }
            guard let data = data,
                let response = response as? HTTPURLResponse,
                response.statusCode == 200 else {
                    completion(.error("New Releases fetch error: response code is not 200"))
                    return
            }
            
            let parser = SpotifyAlbumParser()
            completion(parser.parse(data: data))
        }
        
        task.resume()
    }
}
