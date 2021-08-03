//
//  ToDoListTVC.swift
//  HW24_CoreData_ToDo
//
//  Created by Nata on 03.08.2021.
//

import UIKit
import CoreData

class ToDoListTVC: UITableViewController {
    
    var selectedCategory: Category? {
        didSet {
            self.title = selectedCategory?.name
        }
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var itemArray = [Item]()

    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
        cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // deselect
        tableView.deselectRow(at: indexPath, animated: true)
//        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        itemArray[indexPath.row].done.toggle()
        self.saveItems()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func addItemPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)

        alert.addTextField { textField in
            textField.placeholder = "Your task"
        }

        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        let action = UIAlertAction(title: "Add Item", style: .default) { _ in
            if let textField = alert.textFields?.first {
                if textField.text != "", let title = textField.text {
                    let newItem = Item(context: self.context)
                    newItem.title = title
                    newItem.done = false
                    newItem.parentCategory = self.selectedCategory

                    self.itemArray.append(newItem)
                    self.tableView.reloadData()
                    self.saveItems()
                }
            }
        }

        alert.addAction(action)
        alert.addAction(cancel)

        self.present(alert, animated: true)
    }
    
    //MARK: - SAVE AND FETCH ITEMS FROM DB
    
    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest()) {
        if let name = selectedCategory?.name {
            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)

            request.predicate = categoryPredicate

            do {
                itemArray = try context.fetch(request)
            } catch {
                print("Error fetching data from context: \(error)")
            }
            tableView.reloadData()
        }
    }
    
    
    // Универсальная ф-я со входным предикатом
    
//    private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
//        if let name = selectedCategory?.name {
//            let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", name)
//
//            if let additionalPredicate = predicate {
//                request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, additionalPredicate])
//            } else {
//                request.predicate = categoryPredicate
//            }
//
//            do {
//                itemArray = try context.fetch(request)
//            } catch {
//                print("Error fetching data from context: \(error)")
//            }
//            tableView.reloadData()
//        }
//    }
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
