//
//  StorageManager.swift
//  NotesApp
//
//  Created by MAC  on 06.02.2023.
//

import CoreData

class StorageManager {
    
    static let shared = StorageManager()
    
    private let userDefaults = UserDefaults.standard
    private let sampleNoteKey = "sampleNoteKey"
    
    // MARK: - Core Data stack
    private let persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Notes")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    private let viewContext: NSManagedObjectContext
    
    private init() {
        viewContext = persistentContainer.viewContext
    }
    
    // MARK: - Storage Manager functions
    func fetchData(completion: (Result<[Note], Error>) -> Void) {
        let fetchRequest = Note.fetchRequest()
        
        do {
            let notes = try self.viewContext.fetch(fetchRequest)
            completion(.success(notes))
        } catch let error {
            completion(.failure(error))
        }
    }
    
    func create(title: String, text: String, date: Date) {
        let note = Note(context: viewContext)
        note.title = title
        note.text = text
        note.date = date
        saveContext()
    }
    
    func update(note: Note, newTitle: String, newText: String, newDate: Date) {
        note.title = newTitle
        note.text = newText
        note.date = newDate
        saveContext()
    }
    
    func delete(note: Note) {
        viewContext.delete(note)
        saveContext()
    }
    
    func addSampleNote() {
        userDefaults.set(true, forKey: sampleNoteKey)
    }
    
    func checkSampleNoteForAddition() -> Bool {
        userDefaults.value(forKey: sampleNoteKey) as? Bool ?? false
    }

    // MARK: - Core Data Saving support
    func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
