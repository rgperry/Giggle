//
//  AppSettings.swift
//  Giggle
//
//  Created by Matthew Drutis on 11/10/24.
//
import SwiftData

@Model
class AppSettings {
    var num_results: Int
    var num_folders: Int

    init(num_results: Int, num_folders: Int) {
        self.num_results = num_results
        self.num_folders = num_folders
    }
}
