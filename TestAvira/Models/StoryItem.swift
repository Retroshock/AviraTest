//
//  File.swift
//  TestAvira
//
//  Created by Adrian Popovici on 15/08/2018.
//  Copyright © 2018 adrian. All rights reserved.
//

import Foundation
import RealmSwift

class StoryItem: Object {
    @objc dynamic var time: Int64 = 0
    @objc dynamic var id: Int64 = 0
    @objc dynamic var iconUrl: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var url: String?
    @objc dynamic var read: Bool = false
    @objc dynamic var favorited: Bool = false
    @objc dynamic var isTop: Bool = false

    func configure(time: Int64,
                   id: Int64,
                   iconUrl: String,
                   title: String,
                   url: String?,
                   read: Bool,
                   favorited: Bool,
                   isTop: Bool) {
        self.time = time
        self.id = id
        self.iconUrl = iconUrl
        self.title = title
        self.url = url
        self.read = read
        self.favorited = favorited
        self.isTop = isTop
    }

    override static func primaryKey() -> String? {
        return "id"
    }
}
