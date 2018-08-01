//
//  NextListVC.swift
//  Next
//
//  Created by Devodriq Roberts on 7/30/18.
//  Copyright © 2018 Devodriq Roberts. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework

class NextListVC: SwipeTableVC {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    private var itemArray = [Item]()
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let categoryColor = selectedCategory?.color else {return}
        setNavBarColors(withColor: categoryColor)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        let originalColor = "2B86AA"
        setNavBarColors(withColor: originalColor)
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return itemArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        let item = itemArray[indexPath.row]
        
        cell.accessoryType = item.isDone ? .checkmark : .none
        cell.textLabel?.text = item.title
        
        
        
       
        if let color = UIColor(hexString: (selectedCategory?.color)!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArray.count)) {
            cell.backgroundColor = color
            cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            cell.tintColor = ContrastColorOf(color, returnFlat: true)
            
        }
        

        return cell
    }
    
    //MARK:- Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        itemArray[indexPath.row].isDone = !itemArray[indexPath.row].isDone
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK:- Add new items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add Your Next Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            
            guard let textFieldText = textField.text else {return}
            
            
            let newItem = Item(context: self.context)
            newItem.title = textFieldText
            newItem.isDone = false
            newItem.parentCategory = self.selectedCategory
            
            self.itemArray.append(newItem)
            self.saveItems()
        }
        
        let cancel = UIAlertAction(title: "cancel", style: .cancel) { (cancel) in
            self.dismiss(animated: true , completion: nil)
        }
        
        alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Create New Item"
                textField = alertTextField
            }
        
        
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    private func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        self.tableView.reloadData()
    }
    
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        
        
        if let additionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
        } else {
            request.predicate = categoryPredicate
        }
        
        
        do {
        itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        context.delete(itemArray[indexPath.row])
        itemArray.remove(at: indexPath.row)
        
        do {
            try context.save()
        } catch {
            print("Error deleting item: \(error)")
        }
        tableView.reloadData()
    }
}


//MARK:- Search bar delegate methods
extension NextListVC:  UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        
        let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        loadItems(with: request, predicate: predicate)

    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension NextListVC {
    
    private func setNavBarColors(withColor color: String) {
        self.navigationController?.navigationBar.barTintColor = UIColor(hexString: color)
        title = selectedCategory?.name
        
        self.navigationController?.navigationBar.tintColor = ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)
        
        searchBar.barTintColor = UIColor(hexString: color)
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)]
    }
    
}
