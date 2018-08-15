//
//  WebKitViewController.swift
//  TestAvira
//
//  Created by Adrian Popovici on 15/08/2018.
//  Copyright © 2018 adrian. All rights reserved.
//

import UIKit
import WebKit

protocol SavingForLaterDelegate: class {
    func didSaveForLater(story: StoryItem)
}

class WebKitViewController: UIViewController {
    
    @IBOutlet weak var webKitView: WKWebView!
    weak var delegate: SavingForLaterDelegate?
    var story: StoryItem?
    var isAlreadySaved: Bool = false

    func configure(withDelegate delegate: SavingForLaterDelegate,
                   story: StoryItem,
                   savedState isAlreadySaved: Bool) {
        self.delegate = delegate
        self.story = story
        self.isAlreadySaved = isAlreadySaved
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let urlString = story?.url else { return }
        guard let url = URL(string: urlString) else { return }
        let urlRequest = URLRequest(url: url)
        webKitView.load(urlRequest)

        let button = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(didPressSaveButton))
        self.navigationItem.rightBarButtonItem = button
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    @objc func didPressSaveButton() {
        if let story = story {
            if story.favorited == false {
                showAlert(withMessage: "Successfully saved!")
            } else {
                showAlert(withMessage: "Successfully removed!")
            }
            delegate?.didSaveForLater(story: story)
        } else {
            showAlert(withMessage: "Cannot save for later. Go back and try again.",
                      andTitle: "Error")
        }
    }

    func showAlert(withMessage message: String, andTitle title: String = "") {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension WebKitViewController: StoryboardIdentifiable {
    static var storyboardId: String = "WebKitViewController"
    static var storyboardName: String = "Main"
}
