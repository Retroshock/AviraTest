//
//  StoryCellViewModel.swift
//  TestAvira
//
//  Created by Adrian Popovici on 15/08/2018.
//  Copyright © 2018 adrian. All rights reserved.
//

import UIKit

struct StoryCellViewModel {
    var id: Int64
    var iconUrl: String
    var title: String
    var time: String
    var status: StoryReadState

    init(withStoryItem storyItem: StoryItem) {
        self.id = storyItem.id
        self.iconUrl = storyItem.iconUrl
        self.title = storyItem.title
        self.time = String(describing: storyItem.time)
        if storyItem.read {
            self.status = .read
        } else {
            self.status = .unread
        }
    }
}
