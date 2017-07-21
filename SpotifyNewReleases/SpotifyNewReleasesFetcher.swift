//
//  NewReleasesFetcher.swift
//  SpotifyNewReleases
//
//  Created by Yuri Shkoda on 7/20/17.
//  Copyright © 2017 Yurec. All rights reserved.
//

import Foundation

enum SpotifyNewReleasesOrder {
    
    case newest
    case artistName
    case albumName
}

enum SpotifyNewReleasesFetcherError {
    
    case unableToGetToken
    case fetchingError
    case other(String)
}

protocol SpotifyNewReleasesFetcherDelegate: class {
    
    func fetcherDownloadedNewItems(fetcher: SpotifyNewReleasesFetcher)
    func fetcherFailedGettingItems(fetcher: SpotifyNewReleasesFetcher,
                                   error: SpotifyNewReleasesFetcherError)
}

class SpotifyNewReleasesFetcher {
    
    weak var delegate: SpotifyNewReleasesFetcherDelegate?
    
    private var mainCache = [Track]()
    private var orderedCache = [Track]()
    
    private var currentOrder = SpotifyNewReleasesOrder.newest
    
    private var lastFetchedAlbumIndex = 0
    private var fetching = false
    
    private let albumFetcher = SpotifyAlbumFetcher()
    private let tracksFetcher = SpotifyTracksFetcher()
    
    // Call to load first tracks.
    func loadTracks() {
        guard mainCache.count == 0 else { return }
        fetchNew()
    }
    
    func getTracksCount() -> Int {
        return mainCache.count
    }
    
    // idx Should always be less than count
    func getTrack(idx: Int, ordering: SpotifyNewReleasesOrder) -> Track? {
        
        guard idx < mainCache.count else { return nil }
        if currentOrder != ordering {
            generateOrderedCache(order: ordering)
        }
        
        // start loading new items if only 7 letft to show
        if orderedCache.count - idx < 7 && ordering == .newest {
            fetchNew()
        }
        
        return orderedCache[idx]
    }
    
    private func generateOrderedCache(order: SpotifyNewReleasesOrder) {
        
        let sortingClosure: (Track, Track) -> Bool
        switch order {
        case .newest:
            orderedCache = mainCache
            currentOrder = .newest
            return
        case .artistName:
            sortingClosure = { track1, track2 in
                return track1.album.artists < track2.album.artists
            }
        case .albumName:
            sortingClosure = { track1, track2 in
                return track1.album.name < track2.album.name
            }
        }
        orderedCache = mainCache.sorted(by: sortingClosure)
        currentOrder = order
    }
    
    private func fetchNew() {
        
        guard let token = Spotify.shared.getToken() else {
            delegate?.fetcherFailedGettingItems(fetcher: self, error: .unableToGetToken)
            return
        }
        if fetching { return }
        fetching = true
        let limit = 50
        albumFetcher.fetchAlbums(token: token, offset: lastFetchedAlbumIndex, limit: limit) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .albums(let albums):
                strongSelf.lastFetchedAlbumIndex += limit
                strongSelf.fetchTracks(albums: albums)
                break
            case .error(let error):
                DispatchQueue.main.async {
                    strongSelf.delegate?.fetcherFailedGettingItems(fetcher: strongSelf,
                                                                   error: .other(error))
                }
                strongSelf.fetching = false
            }
        }
    }
    
    private func fetchTracks(albums: [Album]) {
        
        guard let token = Spotify.shared.getToken() else {
            delegate?.fetcherFailedGettingItems(fetcher: self, error: .unableToGetToken)
            fetching = false
            return
        }
        for album in albums {
            tracksFetcher.fetchTracks(token: token, album: album, completion: { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result {
                case .tracks(let tracks):
                    strongSelf.mainCache.append(contentsOf: tracks)
                    strongSelf.generateOrderedCache(order: strongSelf.currentOrder)
                    DispatchQueue.main.async {
                        strongSelf.delegate?.fetcherDownloadedNewItems(fetcher: strongSelf)
                    }
                case .error(let error):
                    DispatchQueue.main.async {
                        strongSelf.delegate?.fetcherFailedGettingItems(fetcher: strongSelf,
                                                                       error: .other(error))
                    }
                }
                strongSelf.fetching = false
            })
        }
    }
}
