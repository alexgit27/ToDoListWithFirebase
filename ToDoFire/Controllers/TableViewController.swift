//
//  TableViewController.swift
//  ToDoFire
//
//  Created by Alexandr on 23.03.2021.
//

import UIKit
import Firebase

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var user: CustomUser!
    var ref: DatabaseReference!
    var tasks = Array<Task>()
    

    @IBOutlet weak var table: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let currentUser = Auth.auth().currentUser else { return }
        user = CustomUser(user: currentUser)
         ref = Database.database().reference(withPath: "users").child(String(user.uid)).child("tasks")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        ref.observe(.value, with: {[weak self] (snapshot) in
            var _tasks = Array<Task>()
            for item in snapshot.children {
                let task = Task(snapshot: item as! DataSnapshot)
                _tasks.append(task)
            }
            self?.tasks = _tasks
            self?.table.reloadData()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        ref.removeAllObservers()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = table.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = tasks[indexPath.row]
        let taskTitle = task.title
        let isCompleted = task.completed
        toggleCompletede(cell, isCompleted: isCompleted)
        cell.textLabel?.text = taskTitle
        cell.backgroundColor = .clear
        return cell
    }
  
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let task = tasks[indexPath.row]
            task.ref?.removeValue()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = table.cellForRow(at: indexPath) else { return }
        let task = tasks[indexPath.row]
        let isCompleted = !task.completed
        task.ref?.updateChildValues(["completed": isCompleted])
        toggleCompletede(cell, isCompleted: isCompleted)
    }
    
    func toggleCompletede(_ cell: UITableViewCell, isCompleted: Bool) {
        cell.accessoryType = isCompleted ? .checkmark : .none
    }
    
    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "New Task", message: "Add new task", preferredStyle: .alert)
        let save = UIAlertAction(title: "Save", style: .default) {[weak self] _ in
            guard let textField = alertController.textFields?[0], textField.text != " " else { return }
            let task = Task(title: textField.text!, userId: (self?.user.uid)!)
//            let task = Task(title: textField.text!, userId: String("4qWPt6wfUPSo6lp4nxqYuhtBXV83"))
            let taskRef = self?.ref.child(task.title.lowercased())
//            let taskRef = self?.ref.child("ittasktitle")
            taskRef?.setValue(task.convertToDictionary())
//            taskRef?.setValue(["title": task.title, "userId": task.userId, "completed": task.completed])
//            taskRef?.setValue(["title": task.title])
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addTextField()
        alertController.addAction(save)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signouTapped(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
        dismiss(animated: true, completion: nil)
    }
}
