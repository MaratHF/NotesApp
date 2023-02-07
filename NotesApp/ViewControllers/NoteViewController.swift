//
//  NoteViewController.swift
//  NotesApp
//
//  Created by MAC  on 02.02.2023.
//

import UIKit

protocol NoteViewControllerDelegate {
    func updateNotes()
}

class NoteViewController: UIViewController {
    
    var delegate: NoteViewControllerDelegate!
    var isNewNote = true
    var note: Note?
    
    private var titleField = UITextField()
    private var noteTextView = UITextView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavBar()
        setupSubview()
        setConstraints()
        defineNoteText()
        registerForKeyboardNotification()
        noteTextView.delegate = self
        titleField.delegate = self
    }
    
    private func setupNavBar() {
        title = "Новая заметка"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Готово",
            style: .done,
            target: self,
            action: #selector(didTapSaveButton)
        )
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func defineNoteText() {
        if !isNewNote {
            title = "Редактирование заметки"
            if let note = note {
                titleField.text = note.title
                noteTextView.text = note.text
            }
        }
    }
    
    private func setupSubview() {
        titleField.placeholder = "Заголовок"
        titleField.textColor = .label
        titleField.font = UIFont.systemFont(ofSize: 22, weight:.medium)
        view.addSubview(titleField)
        
        noteTextView.text = "Введите текст"
        noteTextView.font = UIFont.systemFont(ofSize: 20)
        noteTextView.clipsToBounds = true
        noteTextView.textColor = isNewNote ? .placeholderText : .label
        view.addSubview(noteTextView)
    }
    
    private func setConstraints() {
        titleField.translatesAutoresizingMaskIntoConstraints = false
        noteTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            noteTextView.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 15),
            noteTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            noteTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            noteTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    private func presentAlert() {
        let alert = UIAlertController(
            title: "Заполните все поля",
            message: "Необходимо заполнить заголовок и текст заметки.",
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "ОK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @objc private func didTapSaveButton() {
        if !noteTextView.text.isEmpty && noteTextView.text != "Введите текст" && !titleField.text!.isEmpty {
            if isNewNote {
                StorageManager.shared.create(
                    title: titleField.text!,
                    text: noteTextView.text,
                    date: Date()
                )
            } else {
                StorageManager.shared.update(
                    note: note!,
                    newTitle: titleField.text!,
                    newText: noteTextView.text,
                    newDate: Date()
                )
            }
            delegate.updateNotes()
        } else {
            presentAlert()
        }
        navigationItem.rightBarButtonItem?.isEnabled = false
        titleField.resignFirstResponder()
        noteTextView.resignFirstResponder()
    }
    // MARK: - Keyboard
    
    private func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShowNotification),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHideNotification),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc func keyboardWillShowNotification(_ notification:NSNotification) {
        let userInfo = notification.userInfo!
        var keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = noteTextView.convert(keyboardFrame, from:nil)
        noteTextView.contentInset.bottom = keyboardFrame.size.height
        noteTextView.verticalScrollIndicatorInsets.bottom = keyboardFrame.size.height
        
    }
    
    @objc func keyboardWillHideNotification(_ notification:NSNotification) {
        let contentInsets = UIEdgeInsets.zero
        noteTextView.contentInset = contentInsets
        noteTextView.verticalScrollIndicatorInsets = contentInsets
    }
    
}
// MARK: - UITextViewDelegate
extension NoteViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == noteTextView && noteTextView.text == "Введите текст" {
            textView.text = ""
            noteTextView.textColor = .label
        }
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView == noteTextView && noteTextView.text.isEmpty {
            textView.text = "Введите текст"
            noteTextView.textColor = .placeholderText
        }
    }
}
// MARK: - UITextFieldDelegate
extension NoteViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
}
