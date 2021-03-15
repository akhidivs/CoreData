//
//  ViewController.swift
//  CoreDataBasics
//
//  Created by Akhilesh Mishra on 15/03/21.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    private var models: [ToDoListItem] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        
        title = "CoreData To Do List"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    
    @IBAction func addName(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Item", message: "Enter new item", preferredStyle: .alert)

        let saveAction = UIAlertAction(title: "Submit", style: .default) {
            [unowned self] action in

            guard let textField = alertController.textFields?.first, let nameToSave = textField.text else {
                return
            }

            self.createItem(name: nameToSave)
            self.tableView.reloadData()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
        }

        alertController.addTextField { (textField) in
        }

        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
        
    }
    
    
    //MARK: CoreData CRUD Operations
    
    func getAllItems() {
        do {
            models = try context.fetch(ToDoListItem.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch let error as NSError {
            print("Could not fetch. \(error.localizedDescription)")
        }
    }
    
    func createItem(name: String) {
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch let error as NSError {
            print("Could not create. \(error.localizedDescription)")
        }
    }
    
    func deleteItem(item: ToDoListItem) {
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch let error as NSError {
            print("Could not delete. \(error.localizedDescription)")
        }
    }
    
    func updateItem(item: ToDoListItem, newName: String) {
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        } catch let error as NSError {
            print("Could not create. \(error.localizedDescription)")
        }
    }
}

//MARK: TableView DataSource Methods

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.name
        return cell
    }
}

//MARK: TableView Delegate Methods

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.models[indexPath.row]
        
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)

        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            let alertController = UIAlertController(title: "Edit Item", message: "Edit your item", preferredStyle: .alert)

            let saveAction = UIAlertAction(title: "Save", style: .default) {
                _ in

                guard let textField = alertController.textFields?.first, let nameToSave = textField.text else {
                    return
                }
                
                self?.updateItem(item: item, newName: nameToSave)
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            }

            alertController.addTextField(configurationHandler: nil)
            alertController.textFields?.first?.text = item.name

            alertController.addAction(saveAction)
            alertController.addAction(cancelAction)

            self?.present(alertController, animated: true, completion: nil)
        }))
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.deleteItem(item: item)
        }))

        present(sheet, animated: true, completion: nil)
    }
}

