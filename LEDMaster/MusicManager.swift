//
//  MusicManager.swift
//  LEDMaster
//
//  Created by Joshua Rutschmann on 04.06.21.
//

import Foundation
import MediaPlayer

class MusicManager: NSObject, ObservableObject {
    var bpm: Int
    var timestep: Int
    @Published var trackName: String
    @Published var time: Int
    let musicPlayer:MPMusicPlayerController

    lazy var timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
    
        let newtime = Int(self.musicPlayer.currentPlaybackTime * ((Double(self.bpm) * Double(self.timestep)) / 60.0))
        if self.time != newtime {
            self.time = newtime
        }
        
    }
    
    @objc private func stateChanged() {
        trackName = musicPlayer.nowPlayingItem?.title ?? "Unknown"
        print(musicPlayer.nowPlayingItem?.beatsPerMinute ?? -1)
        if musicPlayer.playbackState == .playing {
            //self.time = 400
        }
    }

    @objc private func itemChanged() {
        print("New Track")
        trackName = musicPlayer.nowPlayingItem?.title ?? "Unknown"
    }
    
    func play() {
        musicPlayer.play()
    }
    
    func pause() {
        musicPlayer.pause()
    }
    
    func beginning() {
        musicPlayer.skipToBeginning()
        self.time = 0
    }
    
    func next() {
        musicPlayer.skipToNextItem()
        self.time = 0
    }

    func setBPM(bpm:Int) {
        self.bpm = bpm
    }
    
    init(bpm:Int, timestep:Int) {
        self.musicPlayer = MPMusicPlayerApplicationController.systemMusicPlayer
        self.trackName = "Unknown"
        self.time = 0
        self.bpm = bpm
        self.timestep = timestep
        super.init()
        musicPlayer.beginGeneratingPlaybackNotifications()
        NotificationCenter.default.addObserver(self, selector: #selector(self.stateChanged), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.itemChanged), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: nil)
        timer.fire()
    }
    
}
