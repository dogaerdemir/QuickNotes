//
//  DetailsViewModel.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 9.09.2023.
//

import Foundation
import CoreData

class DetailsViewModel {
    
    weak var delegate: NoteDelegate?
    
    // CoreData'ya erişim için Context
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // Yeni bir not kaydet
    func saveNewNote(title: String, note: String) {
        let newNote = NSEntityDescription.insertNewObject(forEntityName: "Notes", into: context)
        newNote.setValue(title, forKey: "title")
        newNote.setValue(note, forKey: "note")
        newNote.setValue(UUID(), forKey: "id")
        
        do {
            try context.save()
            
            print("success")
        } catch {
            print("error")
        }
    }
    
    // Mevcut bir notu güncelle
    func updateExistingNote(id: UUID, updatedTitle: String, updatedNote: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if let objectToUpdate = results.first as? NSManagedObject {
                objectToUpdate.setValue(updatedTitle, forKey: "title")
                objectToUpdate.setValue(updatedNote, forKey: "note")
                try context.save()
                
            }
        } catch {
            print("error")
        }
    }
    
    // Belirli bir notun detayını çek
    func fetchNoteDetail(by id: UUID) -> (title: String, note: String)? {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id as CVarArg)
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if let object = results.first as? NSManagedObject,
               let title = object.value(forKey: "title") as? String,
               let note = object.value(forKey: "note") as? String {
                return (title, note)
            }
        } catch {
            print("error")
        }
        
        return nil
    }
}

