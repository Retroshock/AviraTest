//
//  StoryboardIdentifiable.swift
//  TestAvira
//
//  Created by Adrian Popovici on 15/08/2018.
//  Copyright © 2018 adrian. All rights reserved.
//

import UIKit

protocol StoryboardIdentifiable {
    static var storyboardName: String { get }
    static var storyboardId: String { get }
}

/**
 Top-level generic function used to get an instance of an UIViewController
 that implements the StoryboardIdentifiable protocol

 - Returns: An instance of the inferred type. May return nil in
 a production environment. It's your responsability to guard against it.
 - Note: Return type is inferred by assigning the function result
 to an explicitly typed variable

 **Example:**

 class ExampleViewController: UIViewController, StoryboardIdentifiable {
 static var storyboardName: String = "exampleStoryboard"
 static var storyboardId: String = "exampleViewController"
 }

 let example: ExampleViewController = instantiateViewController()
 */
func instantiateViewController<T>() -> T where T: UIViewController, T: StoryboardIdentifiable {

    guard Bundle.main.path(forResource: T.storyboardName, ofType: "storyboardc") != nil else {
        preconditionFailure("Storyboard \(T.storyboardName) is not present in bundle")
    }
    let storyboard = UIStoryboard(name: T.storyboardName, bundle: nil)

    guard
        let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any],
        (availableIdentifiers.keys.contains { $0 == T.storyboardId })
        else {
            preconditionFailure("StoryboardId \(T.storyboardId) is not present in Storyboard \(T.storyboardName)")
    }
    guard let viewController = storyboard.instantiateViewController(withIdentifier: T.storyboardId) as? T else {
        preconditionFailure(
            """
            Mismatch between viewcontroller type and expected type.
            Check storyboard Class type and Storyboard Id of intended ViewController
            """)
    }

    return viewController
}
