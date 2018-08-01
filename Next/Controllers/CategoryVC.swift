//
//  CategoryVC.swift
//  Next
//
//  Created by Devodriq Roberts on 7/30/18.
//  Copyright © 2018 Devodriq Roberts. All rights reserved.
//

import UIKit
import CoreData
import ChameleonFramework


class CategoryVC: SwipeTableVC {

    private var categoryArray = [Category]()
   
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
        tableView.separatorStyle = .none
        
    }

   

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray[indexPath.row].name ?? "No Categories Added Yet"

        
        
        if let color = categoryArray[indexPath.row].color {
            cell.backgroundColor = UIColor(hexString: color )
            cell.textLabel?.textColor = ContrastColorOf(UIColor(hexString: color)!, returnFlat: true)
        }
        
        
        return cell
    }
    
    //MARK:- Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! NextListVC
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = self.categoryArray[indexPath.row]
        }
    }
    
    //MARK:- Data Manipulation
    private func saveCategory() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
        tableView.reloadData()
    }
    
    private func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        
        do {
            categoryArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context: \(error)")
        }
        tableView.reloadData()
    }
    
    private func saveColor() {
        do {
            try context.save()
        } catch {
            print("Error saving random color: \(error)")
        }
    }
    
    //MARK:- Delete Data From Swipe
    override func updateModel(at indexPath: IndexPath) {
        
        super.updateModel(at: indexPath
        )
        self.context.delete(self.categoryArray[indexPath.row])
        self.categoryArray.remove(at: indexPath.row)
        
        do {
            try self.context.save()
        } catch {
            print("Error deleting item from context: \(error)")
        }
        tableView.reloadData()
    }
    

    
    //MARK:- Add new categories
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add A New Category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            guard let textFieldText = textField.text else {return}
            
            let newCategory = Category(context: self.context)
            newCategory.name = textFieldText
            newCategory.color = RandomFlatColor().hexValue()
            
            self.categoryArray.append(newCategory)
            self.saveCategory()
        }
        let cancel = UIAlertAction(title: "cancel", style: .cancel) { (cancel) in
            self.dismiss(animated: true , completion: nil)
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}
    


//MARK:- Search bar delegate methods
extension CategoryVC:  UISearchBarDelegate {
    
    func categorySearchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        request.predicate = NSPredicate(format: "name CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        loadCategories(with: request)
        
    }
    
    func categorySearchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadCategories()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}



