//
//  SpotifyNewReleasesTests.swift
//  SpotifyNewReleasesTests
//
//  Created by Yury on 7/23/17.
//  Copyright © 2017 Yurec. All rights reserved.
//

import XCTest
@testable import SpotifyNewReleases

class SpotifyNewReleasesTests: XCTestCase {
    
    var bundle: Bundle!
    let parser = JSONTrackParser()
    
    override func setUp() {
        super.setUp()
        bundle = Bundle(for: type(of: self))
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testJSONTrackParsing1() {
        
        let tracktest1path = bundle.url(forResource: "jsontracktest1", withExtension: "json")!
        let data = try! Data(contentsOf: tracktest1path)
        let json = String(data: data, encoding: .utf8)!
        
        let ids = parser.getTracks(json: json)
        
        XCTAssert(ids == [1])
    }
    
    func testJSONTrackParsing2() {
        
        let tracktest1path = bundle.url(forResource: "jsontracktest2", withExtension: "json")!
        let data = try! Data(contentsOf: tracktest1path)
        let json = String(data: data, encoding: .utf8)!
        
        var ids = parser.getTracks(json: json)
        print(ids)
        
        for i in (1...5) {
            let idx = ids.index(of: i)
            XCTAssert(idx != nil)
            ids.remove(at: idx!)
        }
        XCTAssert(ids.count == 0)
    }
    
    func testFetchingNewReleases() {
        
        let fetcher = SpotifyAlbumFetcher()
        let token = "BQCU2Wx8ALHfPn40XxQxFqamyLFIozda6DQu4LwQ4Sh5aDuWdsa8NOsOgsuYHO9kn3QydTaBctyLkvCrw1_THSHR3gta2A-YTEACh4FgHBMan_MAmkIdtUStVJSGtrqDCuv_sYw7YXdkQePHN5-Th3pypvlLZfRrEaEPn-Fz3indSjNPffXYET_DFLwOVg74aDFqyFLqAv888oshv9yMQzmYS6OmW70PC7G31UIESxg4ra2YcMSD-kWdyJ0yC17_cI_3sABMHXCzOGjXooI"
        let expectation = self.expectation(description: "Albums fetching")
        fetcher.fetchAlbums(token: token, offset: 0, limit: 20) { (result) in
            switch result {
            case .albums(let albums):
                print(albums)
                expectation.fulfill()
            case .error(let error):
                print(error)
                XCTFail()
            }
        }
        self.wait(for: [expectation], timeout: 10.0)
    }
    
    func testFetchingTracks() {
        
        let fetcher = SpotifyTracksFetcher()
        let token = "BQCU2Wx8ALHfPn40XxQxFqamyLFIozda6DQu4LwQ4Sh5aDuWdsa8NOsOgsuYHO9kn3QydTaBctyLkvCrw1_THSHR3gta2A-YTEACh4FgHBMan_MAmkIdtUStVJSGtrqDCuv_sYw7YXdkQePHN5-Th3pypvlLZfRrEaEPn-Fz3indSjNPffXYET_DFLwOVg74aDFqyFLqAv888oshv9yMQzmYS6OmW70PC7G31UIESxg4ra2YcMSD-kWdyJ0yC17_cI_3sABMHXCzOGjXooI"
        let album = Album(id: "0YneCKu6aJCtBSkP9f8rrK", name: "Perennial", artists: "Vera Blue")
        let expectation = self.expectation(description: "Tracks fetching")
        fetcher.fetchTracks(token: token, album: album){ (result) in
            switch result {
            case .tracks(let tracks):
                print(tracks)
                expectation.fulfill()
            case .error(let error):
                print(error)
                XCTFail()
            }
        }
        self.wait(for: [expectation], timeout: 10.0)
    }
}
