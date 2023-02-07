//
//  NotesViewController.swift
//  NotesApp
//
//  Created by MAC  on 02.02.2023.
//

import UIKit

class NotesViewController: UITableViewController {
    
    var notes: [Note] = []
    let cellID = "NotesCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavBar()
        fetchData()
        addSampleNote()
    }

    // MARK: - Private functions
    private func addSampleNote() {
        if !StorageManager.shared.checkSampleNoteForAddition() {
            StorageManager.shared.create(
                title: "Список покупок",
                text: "Молоко, хлеб, йогурт, рис.",
                date: Date()
            )
            StorageManager.shared.addSampleNote()
            fetchData()
        }
    }
    
    private func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let notes):
                self.notes  = notes
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func setupNavBar() {
        title = "Заметки"
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = #colorLiteral(red: 0.2971624829, green: 0.3114496867, blue: 0.307222209, alpha: 1)
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .add,
                    target: self,
                    action: #selector(didTapAddButton)
               )
    }
    
    private func getDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let newDate = dateFormatter.string(from: date)
        return newDate
    }
    
    @objc private func didTapAddButton() {
        let noteVC = NoteViewController()
        noteVC.delegate = self
        navigationController?.pushViewController(noteVC, animated: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = notes[indexPath.row].title
        content.secondaryText = "\(getDate(date: notes[indexPath.row].date!))  \(notes[indexPath.row].text!)"
        content.secondaryTextProperties.numberOfLines = 1
        cell.contentConfiguration = content
        
        return cell
    }
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let noteVC = NoteViewController()
        noteVC.note = notes[indexPath.row]
        noteVC.isNewNote = false
        noteVC.delegate = self
        navigationController?.pushViewController(noteVC, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { _, _, _ in
            let note = self.notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            StorageManager.shared.delete(note: note)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
// MARK: - NoteViewControllerDelegate
extension NotesViewController: NoteViewControllerDelegate {
    func updateNotes() {
        fetchData()
        tableView.reloadData()
    }
}

