//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Julie Alexan on 10/24/26.
//  Copyright © 2026 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {

    var categoriesArray = [Categories]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        let appearance = UINavigationBarAppearance()
        //appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .orange
        appearance.titleTextAttributes = [ .foregroundColor: UIColor.white]
        
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        self.navigationItem.title = "Categories...."
        

        // Do any additional setup after loading the view.
        let request = NSFetchRequest<Categories>(entityName: "Categories")
        loadItems(with: request)
    }
    
    @IBAction func addCategoryItem(_ sender: UIBarButtonItem) {
        var alert = UIAlertController(title: "Add category name", message: "Type the name of a category for your todo's", preferredStyle: .alert)
        var newCategoryTextField = UITextField()
        
        let action = UIAlertAction(title: "Add", style: .default, handler: { action in
            // we should create a new NSManagedObject which is a new Categories
            let newCat = Categories(context: self.context)
            newCat.name = newCategoryTextField.text
            self.categoriesArray.append(newCat)
            
            self.saveItems()
        })
        alert.addTextField { field in
            field.placeholder = "Add a new category"
            newCategoryTextField = field
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
        tableView.reloadData()
    
    }
    
    func saveItems() {
        do { try context.save()
            self.tableView.reloadData()
        }
        catch {
            print("ERROR: Couldn't save to core data: \(error)")
        }
    }

    func loadItems(with request: NSFetchRequest<Categories> = Categories.fetchRequest()) {
        do {
            self.categoriesArray = try context.fetch(request)
        
            print("GOT THIS FROM LOADING (\(self.categoriesArray.count): \(self.categoriesArray)")
            self.tableView.reloadData()
            
        } catch {
            print("ERROR: Couldn't load category items from core data: \(error)")
        }
    }
    

    // MARK: UITableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoriesArray.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "CategoryCell")
        
        cell.textLabel?.text = categoriesArray[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //category = categoriesArray[indexPath.row]
        performSegue(withIdentifier: "todoListSegue", sender: self)
    }
    
    
    // MARK: - Navigation

 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        var cat: Categories
        if let index = tableView.indexPathForSelectedRow {
            cat = self.categoriesArray[index.row]
            let todoVC = segue.destination as! TodoListViewController
            todoVC.category = cat
//            todoVC.performSegue(withIdentifier: segue.identifier ?? "todoListSegue", sender: self)
        }
    }
}
