//
//  AddLeagueViewController.swift
//  espn-ff
//
//  Created by Chris Paine on 10/11/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

class AddLeagueTableViewController: UITableViewController {
    @IBOutlet weak var leagueIdTextField: UITextField!
    @IBOutlet var textFieldToolbar: UIToolbar!
    @IBOutlet weak var saveLeagueButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.awakeFromNib()
        self.leagueIdTextField.inputAccessoryView = textFieldToolbar
        self.saveLeagueButton.isEnabled = false
    }
    
    @IBAction func saveNewLeague() {
        guard let id = leagueIdTextField.text,
            let intId = Int32(id) else {
                saveLeagueButton.isEnabled = false
                present(UIAlertController.createErrorAlert(message: "Check the league ID you entered."), animated: true, completion: nil)
                return
        }
                
        Networking.shared.saveLeague(leagueId: intId) { [weak self] (league, error) in
            guard error == nil else {
                self?.present(UIAlertController.createErrorAlert(message: error?.localizedDescription), animated: true, completion: nil)
                return
            }
            
            self?.present(UIAlertController.createAlert(title: "Success", message: "You saved a new league."), animated: true, completion: nil)
        }
    }
    
    @IBAction func presentWebView(_ sender: Any) {
        present(UINavigationController(rootViewController: WebViewController()), animated: true, completion: nil)
    }
}

extension AddLeagueTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        saveLeagueButton.isEnabled = !updatedText.isEmpty
        return true
    }
}
