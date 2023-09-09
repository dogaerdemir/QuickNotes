//
//  MainViewModel.swift
//  QuickNotes
//
//  Created by Doğa Erdemir on 9.09.2023.
//

import Foundation
import UIKit
import CoreData

class MainViewModel {
    
    func fetchNotes() -> [Note] {
        var notes: [Note] = []
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "title") as? String, let noteContent = result.value(forKey: "note") as? String, let id = result.value(forKey: "id") as? UUID {
                        let note = Note(title: title, content: noteContent, id: id)
                        notes.append(note)
                    }
                }
            }
        } catch {
            print("Error fetching notes")
        }
        
        return notes
    }
    
    func deleteNote(with id: UUID) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Notes")
        let idString = id.uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? UUID, id == id {
                        context.delete(result)
                        do {
                            try context.save()
                            return true
                        } catch {
                            return false
                        }
                    }
                }
            }
        } catch {
            print("error")
            return false
        }
        return false
    }
}
