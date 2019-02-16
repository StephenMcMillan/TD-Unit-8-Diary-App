//
//  AlertHelper.swift
//  Diary
//
//  Created by Stephen McMillan on 14/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import UIKit

// Makes things a bit easier when creating UIAlertActions
extension UIAlertController {
    
    typealias AlertActionHandler = ((UIAlertAction) -> Void)
    
    // Returns an alert with the contents detailing the error object passed in.
    static func alert(for error: Error, action: AlertActionHandler? = nil) -> UIAlertController {
        return UIAlertController.alert(with: error.localizedDescription, action: action)
    }
    
    // Returns an alert with a message passed in.
    static func alert(with message: String, action: AlertActionHandler? = nil) -> UIAlertController {
        let alert = UIAlertController(title: "Oh No!", message: "Something isn't quite right here. \(message)", preferredStyle: .alert)

        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: action)
        alert.addAction(alertAction)
        
        return alert
    }
    
    static func actionSheet(title: String? = nil) -> UIAlertController {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actionSheet.addAction(cancelAction)
        return actionSheet
    }
    
    func addActions(_ actions: [UIAlertAction]) {
        actions.forEach { addAction($0) }
    }
}

protocol ErrorAlertable {}

extension ErrorAlertable where Self: UIViewController {
    func displayAlert(for error: Error) {
        let alert = UIAlertController.alert(for: error)
        present(alert, animated: true, completion: nil)
    }
}
