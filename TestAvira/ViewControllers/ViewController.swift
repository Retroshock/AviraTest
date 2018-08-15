//
//  ViewController.swift
//  TestAvira
//
//  Created by Adrian Popovici on 15/08/2018.
//  Copyright © 2018 adrian. All rights reserved.
//

import Alamofire
import RealmSwift
import SafariServices
import SVProgressHUD
import UIKit

enum ViewControllerState {
    case newStories
    case savedForLater
}

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var state: ViewControllerState = .newStories
    var topStories: [StoryItem] = []
    var favoriteSections: [StoryItem] = []
    var newStories: [StoryItem] = []
    var favoritedStories: [StoryItem] = []
//    var mainDispatchGroup = DispatchGroup()

    let refreshControl = UIRefreshControl()
    let realm = try! Realm()
    
    override func viewDidLoad() {
        getStoriesFromRealm()
        refreshTableView()
        getFavoriteStories()
        setupRefreshControl()
    }

    func setupRefreshControl() {
        tableView.addSubview(refreshControl)
        refreshControl.tintColor = UIColor(red: 1.0, green: 0, blue: 0, alpha:1.0)
        refreshControl.addTarget(self, action: #selector(refreshTableView), for: .valueChanged)
    }

    @objc func refreshTableView() {
        getTopStoriesFromAPI { [weak self] in
            self?.getNewStoriesFromAPI {
                DispatchQueue.main.async { [weak self] in
                    self?.refreshControl.endRefreshing()
                    self?.tableView.reloadData()
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                }
            }
        }
    }

    @IBAction func didChangeTab(_ sender: UISegmentedControl) {
        if state == .newStories {
            state = .savedForLater
            tableView.reloadData()
        } else {
            state = .newStories
            tableView.reloadData()
        }
    }

    private func getStoriesFromRealm() {
        let realmTopValues = realm.objects(StoryItem.self).filter { $0.isTop == true }
        let realmNewValues = realm.objects(StoryItem.self).filter { $0.isTop == false }
        topStories = Array(realmTopValues)
        newStories = Array(realmNewValues)
        tableView.reloadData()
    }

    func addObjectToRealm(object: Object) {
        do {
            try realm.write {
                realm.add(object, update: true)
            }
        } catch let error {
            showError(withMessage: error.localizedDescription)
        }
    }

    func showError(withMessage message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if state == .newStories {
            if section == 0 {
                return topStories.count
            } else {
                return newStories.count
            }
        } else {
            return favoritedStories.count
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UITableViewHeaderFooterView()
        if state == .newStories {
            if section == 0 {
                headerView.textLabel?.text = "Top stories"
            } else {
                headerView.textLabel?.text = "New stories"
            }
        } else {
            headerView.textLabel?.text = "Saved for later stories"
        }
        return headerView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if state == .newStories {
            return 2
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StoryCell") as? StoryCell else {
            return UITableViewCell()
        }
        if state == .newStories {
            if indexPath.section == 0 {
                let storyCellViewModel = StoryCellViewModel(withStoryItem: topStories[indexPath.row])
                cell.configure(withViewModel: storyCellViewModel, andDelegate: self)
                return cell
            } else {
                let storyCellViewModel = StoryCellViewModel(withStoryItem: newStories[indexPath.row])
                cell.configure(withViewModel: storyCellViewModel, andDelegate: self)
                return cell
            }
        } else {
            let storyCellViewModel = StoryCellViewModel(withStoryItem: favoritedStories[indexPath.row])
            cell.configure(withViewModel: storyCellViewModel, andDelegate: self)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let story: StoryItem
        if indexPath.section == 0 && state == .newStories {
            story = topStories[indexPath.row]
        } else if indexPath.section == 0 {
            story = favoritedStories[indexPath.row]
        } else {
            story = newStories[indexPath.row]
        }
        if story.url != nil {
            
            let webViewController: WebKitViewController = instantiateViewController()
            webViewController.configure(withDelegate: self,
                                        story: story,
                                        savedState: favoritedStories.contains(story))
            navigationController?.show(webViewController, sender: self)
        }
    }
}

extension ViewController: ReadStatusUpdating {

    private func updateStoryReadValue(ofStory story: StoryItem, withViewModel viewModel: StoryCellViewModel) -> StoryItem {
        if story.id == viewModel.id {
            if viewModel.status == .read {
                story.read = true
            } else {
                story.read = false
            }
        }
        return story
    }

    func didUpdateReadStatus(ofViewModel viewModel: StoryCellViewModel) {
        do {
            try realm.write {
                topStories = topStories.map {
                    updateStoryReadValue(ofStory: $0, withViewModel: viewModel)
                }
                newStories = newStories.map {
                    updateStoryReadValue(ofStory: $0, withViewModel: viewModel)
                }
            }
        } catch let error {
            showError(withMessage: error.localizedDescription)
        }
        tableView.reloadData()
    }
}

extension ViewController: SavingForLaterDelegate {
    func didSaveForLater(story: StoryItem) {
        do {
            try realm.write {
                story.favorited = !story.favorited
            }
            topStories = topStories.map { topStory in
                if topStory.id == story.id {
                    return story
                }
                return topStory
            }
            newStories = newStories.map { newStory in
                if newStory.id == story.id {
                    return story
                }
                return newStory
            }
            getFavoriteStories()
        } catch let error {
            showError(withMessage: error.localizedDescription)
        }
    }
}
