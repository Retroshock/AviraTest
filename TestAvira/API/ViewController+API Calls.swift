//
//  ViewController+API Calls.swift
//  TestAvira
//
//  Created by Adrian Popovici on 15/08/2018.
//  Copyright © 2018 adrian. All rights reserved.
//

import UIKit

private let baseURL = "https://hacker-news.firebaseio.com/v0/"
private let itemReference = "item/"
private let topStoriesReference = "topstories.json"
private let newStoriesReference = "newstories.json"

extension ViewController {
    func getTopStoriesFromAPI(completion: @escaping () -> ()) {
        let url = baseURL + topStoriesReference
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        GetService.shared.get(url: url) { [weak self] response, success in
            guard let `self` = self else { return }
            if success {
                if let response = response {
                    guard let responseArray = response.result.value as? [Int64] else {
                        return
                    }
                    var tempStories: [StoryItem] = []
                    let dispatchGroup = DispatchGroup()
                    for value in responseArray {
                        dispatchGroup.enter()
                        let itemUrl = baseURL + itemReference + String(describing: value) + ".json"
                        GetService.shared.get(url: itemUrl) { [weak self] response, success in
                            guard let `self` = self else { return }
                            if success {
                                if let response = response {
                                    guard let responseJson = response.result.value as? NSDictionary else {
                                        return
                                    }
                                    guard let id = responseJson["id"] as? Int64,
                                        let time = responseJson["time"] as? Int64,
                                        let title = responseJson["title"] as? String else {
                                            self.showError(withMessage: "Could not decode the json")
                                            return
                                    }
                                    let url = responseJson["url"] as? String
                                    // Picture url here

                                    // Creating story
                                    var storyItem = StoryItem()
                                    storyItem.configure(time: time,
                                                        id: id,
                                                        iconUrl: "",
                                                        title: title,
                                                        url: url,
                                                        read: false,
                                                        favorited: false,
                                                        isTop: true)

                                    let databaseObject = self.realm.object(ofType: StoryItem.self, forPrimaryKey: id)
                                    if databaseObject != nil {
                                        storyItem = databaseObject!
                                    } else {
                                        self.addObjectToRealm(object: storyItem)
                                    }
                                    tempStories.append(storyItem)
                                    dispatchGroup.leave()
                                } else {
                                    dispatchGroup.leave()
                                    self.showError(withMessage: "Failed to get the proper response from api")
                                }
                            } else {
                                dispatchGroup.leave()
                                self.showError(withMessage: "Could not contact API")
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        self.topStories = tempStories.map { story in
                            let foundStory = self.topStories.first { $0.id == story.id }
                            if foundStory != nil {
                                return foundStory!
                            } else {
                                return story
                            }
                        }
                        completion()
                    }
                }
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                self.showError(withMessage: "Could not contact API")
            }
        }
    }

    func getNewStoriesFromAPI(completion: @escaping () -> ()) {
        let url = baseURL + newStoriesReference
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        GetService.shared.get(url: url) { [weak self] response, success in
            guard let `self` = self else { return }
            if success {
                if let response = response {
                    guard let responseArray = response.result.value as? [Int64] else {
                        return
                    }
                    var tempStories: [StoryItem] = []
                    let dispatchGroup = DispatchGroup()
                    for value in responseArray {
                        dispatchGroup.enter()
                        let itemUrl = baseURL + itemReference + String(describing: value) + ".json"
                        GetService.shared.get(url: itemUrl) { [weak self] response, success in
                            guard let `self` = self else { return }
                            if success {
                                if let response = response {
                                    guard let responseJson = response.result.value as? NSDictionary else {
                                        dispatchGroup.leave()
                                        return
                                    }
                                    guard let id = responseJson["id"] as? Int64,
                                        let time = responseJson["time"] as? Int64,
                                        let title = responseJson["title"] as? String else {
                                            self.showError(withMessage: "Could not decode the json")
                                            dispatchGroup.leave()
                                            return
                                    }
                                    let url = responseJson["url"] as? String
                                    // Picture url here

                                    // Creating story
                                    var storyItem = StoryItem()
                                    storyItem.configure(time: time,
                                                        id: id,
                                                        iconUrl: "",
                                                        title: title,
                                                        url: url,
                                                        read: false,
                                                        favorited: false,
                                                        isTop: false)

                                    let databaseObject = self.realm.object(ofType: StoryItem.self, forPrimaryKey: id)
                                    if databaseObject != nil {
                                        storyItem = databaseObject!
                                    } else {
                                        self.addObjectToRealm(object: storyItem)
                                    }
                                    tempStories.append(storyItem)

                                    dispatchGroup.leave()
                                } else {
                                    dispatchGroup.leave()
                                    self.showError(withMessage: "Failed to get the proper response from api")
                                }
                            } else {
                                dispatchGroup.leave()
                                self.showError(withMessage: "Could not contact API")
                            }
                        }
                    }
                    dispatchGroup.notify(queue: .main) {
                        self.newStories = tempStories.map { story in
                            let foundStory = self.newStories.first { $0.id == story.id }
                            if foundStory != nil {
                                return foundStory!
                            } else {
                                return story
                            }
                        }
                        completion()
                    }
                }
            } else {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                self.showError(withMessage: "Could not contact API")
            }
        }
    }

    func getFavoriteStories() {
        favoritedStories = topStories.filter { $0.favorited }
        favoritedStories.append(contentsOf: newStories.filter { $0.favorited })
    }

}
