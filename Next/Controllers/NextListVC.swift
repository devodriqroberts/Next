//
//  NextListVC.swift
//  Next
//
//  Created by Devodriq Roberts on 7/30/18.
//  Copyright © 2018 Devodriq Roberts. All rights reserved.
//

import UIKit

class NextListVC: UITableViewController {
    
    let itemArray = ["Create app store app", "upload app to app store", "Get development job"]
    //var isSelected = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NextItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row]

        return cell
    }
    
    //MARK:- Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        
        //isSelected = !isSelected
        //tableView.cellForRow(at: indexPath)?.accessoryType = isSelected ? .checkmark : .none
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
 

    

}
