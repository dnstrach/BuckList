//
//  FileManager-DocumentsDirectory.swift
//  Bucketlist
//
//  Created by Dominique Strachan on 1/2/24.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
