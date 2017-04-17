//
//  Album.swift
//  Music
//
//  Created by Aparna Revu on 3/4/17.
//  Copyright © 2017 Aparna Revu. All rights reserved.
//

import Foundation
import UIKit

class Album {
    var name: String?
    var artist: String?
    var albumName: String?
    var previewUrl: String?
    
    init(name: String?, artist: String?, albumName: String? , previewUrl: String?) {
        self.name = name
        self.artist = artist
        self.previewUrl = previewUrl
        self.albumName = albumName
    }

}
