//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

class TodoListViewController: UITableViewController {
    let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
    
    var category: Categories? {
        didSet{
            
            let request: NSFetchRequest<TodoItemModel> = TodoItemModel.fetchRequest()
            request.predicate = NSPredicate(format: "parentCategory.name MATCHES %@", category!.name!)

            loadItems(with: request)
        }
    }
    var todoList = [TodoItemModelPlist]()
    var todoListCoreData = [TodoItemModel]()
    var tempResultsArray = [TodoItemModel]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

   
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let appearance = UINavigationBarAppearance()
        //appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .orange
        appearance.titleTextAttributes = [ .foregroundColor: UIColor.white]
        
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        //        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        //        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.navigationItem.title = "Todo List"
        
        let arr = [
            ("Buy Milk", true),
            ("Call mom", false),
            ("Water the Plants", true)
        ]
        
        
        
        print(dataFilePath!)
        if (USE_CORE_DATA) {
            //NOTE: the UIApplication.shared is a pointer to our currently running app (this one)
            //  it's .delegate, when we downcast it, is our actual AppDelegate
            // Since persistent container was defined as a lazy var, then it gets assigned now when we start to use it here. (delayed assignment to save on memory space)
            
          //  loadItems()
//            let newItem = TodoItemModel(context: context)
//            newItem.item = "Enter your todos"
//            newItem.isDone = false
//            todoListCoreData = [newItem]
            
        } else {
            todoList = arr.map {
                TodoItemModelPlist(item: $0.0, isDone: $0.1)
            }
            readFromPlist()
            
        }
        
        tableView.rowHeight = 80
        /*
         if let items = userDefaults.array(forKey: "UserTodoList") as? [TodoItemModel] {
         self.todoList = items
         }
         */
    }
    
    
    //MARK - TableView Delegates
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (USE_CORE_DATA) {
            return todoListCoreData.count
        }
        return todoList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! SwipeTableViewCell
           cell.delegate = self
        
        if (USE_CORE_DATA) {
            cell.textLabel?.text = todoListCoreData[indexPath.row].item

            let item = todoListCoreData[indexPath.row]
            cell.accessoryType = (item.isDone) ? .checkmark : .none
            
        } else {
            cell.textLabel?.text = todoList[indexPath.row].item

            let item = todoList[indexPath.row]
            cell.accessoryType = (item.isDone) ? .checkmark : .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = TodoDetailsViewController()
        
        if (USE_CORE_DATA) {
            let item = todoListCoreData[indexPath.row]
            item.isDone = !item.isDone
           vc.subtitleLabel.text =  todoListCoreData[indexPath.row].item
//            Deleting from Core Data entity is easy
//            context.delete(item)
//            todoListCoreData.remove(at: indexPath.row)
            
            saveItems()
            
        } else {
            let item = todoList[indexPath.row]
            item.isDone = !item.isDone
            writeToPlist()
            vc.subtitleLabel.text =  todoList[indexPath.row].item
            
        }
        
        tableView.reloadData()
        
 

//        vc.modalPresentationStyle = .pageSheet
//        present(vc, animated: true)
//        
    }
    
    
    func writeToPlist() {
        let encoder = PropertyListEncoder()
        do {
            let data = try encoder.encode(todoList)
            try data.write(to: dataFilePath!)
        } catch {
            print("Error writing to or encoding todoList array: \(error)")
        }
    }
    
    func readFromPlist() {
        do {
            if let data = try? Data(contentsOf: dataFilePath!) {
                let decoder = PropertyListDecoder()
                todoList = try decoder.decode([TodoItemModelPlist].self, from: data)  //".self" gives it the actual data type of this object
            }
        } catch {
            print("Error reading from or DE-coding todoList array: \(error)")
        }
        print("Got this from decoder: \(todoList)")
    }
    
    
    //MARK - Add Todo List Item Action
    
    @IBAction func addTodoListItem(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add New Todo Item", message: "", preferredStyle: UIAlertController.Style.alert)
        var newTextField = UITextField()
        
        let addAction = UIAlertAction(title: "Add Item", style: .default) { (action) in
            print(newTextField.text as Any)
            if (newTextField.text?.isEmpty == false) {
                
                
                if (USE_CORE_DATA) {
                    let newItem = TodoItemModel(context: self.context)
                    newItem.item = newTextField.text!
                    newItem.isDone = false
                    newItem.parentCategory = self.category
                    
                    self.todoListCoreData.append(newItem)
                    
                    self.saveItems()
                   
                    
                } else {
                    self.todoList.append(TodoItemModelPlist(item: newTextField.text!, isDone:false))
                    
                    self.writeToPlist()
                }
                self.tableView.reloadData()
            }
        }
        
        alert.addTextField { (addNewItemTextField) in
            addNewItemTextField.placeholder = "Enter a new thing to do here"
            newTextField = addNewItemTextField
        }
        
        alert.addAction(addAction)
        present(alert, animated: true) {
            print("adding action to alert COMPLETE")
        }
    }
    
    func saveItems() {
        do { try context.save()
            self.tableView.reloadData()
        }
        catch {
            print("ERROR: Couldn't save to core data: \(error)")
        }
    }

    func loadItems(with request: NSFetchRequest<TodoItemModel> = TodoItemModel.fetchRequest()) {
        do {

            self.todoListCoreData = try context.fetch(request)
            print("GOT THIS FROM LOADING (\(self.todoListCoreData.count): \(self.todoListCoreData)")
            self.tableView.reloadData()
            
        } catch {
            print("ERROR: Couldn't load items from core data: \(error)")
        }
    }
   
}

// MARK - UISearch Bar Delegate
extension TodoListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request: NSFetchRequest<TodoItemModel> = NSFetchRequest<TodoItemModel>(entityName: "TodoItemModel")
        request.predicate = NSPredicate(format: "item CONTAINS[cd] %@", searchText)
        request.sortDescriptors = [NSSortDescriptor(key: "item", ascending: true)]
        
        if (searchText.count == 0) {
            request.predicate = NSPredicate(format: "parentCategory.name MATCHES %@", category!.name!)
            loadItems(with: request)
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
            return
        }
        loadItems(with: request)

    }
}

extension TodoListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .left else { return nil }

        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            print("Will delete this!")
        }

        // customize the action appearance
        deleteAction.image = UIImage(named: "delete")

        return [deleteAction]
    }
}
