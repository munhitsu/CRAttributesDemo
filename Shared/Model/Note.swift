//
//  Persistence.swift
//  Shared
//
//  Created by Mateusz Lapsa-Malawski on 27/12/2021.
//

import CoreData
import CRAttributes
import Combine

#if targetEnvironment(macCatalyst)
import AppKit
#endif
#if os(iOS)
import UIKit
#endif


extension CRObjectType {
    static let note = CRObjectType(rawValue: 2)
    static let folder = CRObjectType(rawValue: 3)
}


@MainActor public class Note: ObservableObject {
    var crObject: CRObject
    
    var is_pinned_attribute: CRAttributeBool
    var title_attribute: CRAttributeString
    var body_attribute: CRAttributeMutableString

    var operationID: CROperationID {
        crObject.operationID!
    }
    
    var hasTombstone: Bool? {
        crObject.hasTombstone
    }
    
    /**
     fetch from an existing CRObject
     */
    init(from crObject: CRObject) {
        self.crObject = crObject
        self.is_pinned_attribute = crObject.attribute(name: "is_pinned", attributeType: .boolean) as! CRAttributeBool
        self.title_attribute = crObject.attribute(name: "title", attributeType: .string) as! CRAttributeString
        self.body_attribute = crObject.attribute(name: "body", attributeType: .mutableString) as! CRAttributeMutableString
    }

    /**
     create new object
     */
    public init() {
        self.crObject = CRObject(objectType: .note, container: nil)
        self.is_pinned_attribute = crObject.attribute(name: "is_pinned", attributeType: .boolean) as! CRAttributeBool
        self.title_attribute = crObject.attribute(name: "title", attributeType: .string) as! CRAttributeString
        self.body_attribute = crObject.attribute(name: "body", attributeType: .mutableString) as! CRAttributeMutableString
    }
    
    public convenience init(title: String) {
        self.init()
        self.title = title
    }
    
    func markAsDeleted() {
        crObject.markAsDeleted()
    }
    

    var is_pinned: Bool {
        get {
            is_pinned_attribute.value ?? false
        }
        set {
            is_pinned_attribute.value = newValue
        }
        
    }
//    var created_on: Date
//    var updated_on: Date
    
    var title: String {
        get {
            title_attribute.value ?? ""
        }
        set {
            title_attribute.value = newValue
        }
    }

    var body: CRTextStorage {
        get {
            body_attribute.textStorage
        }
    }
    
    /**
     returns a Note that contains all the notes whose container was nil
     this container is later updated on every related db update
     */
    public static func rootNote() -> Note {
        let context = CRStorageController.shared.localContainer.viewContext

        let root = CRObject.getOrCreateVirtualRootObject(context: context, objectType: .note)
        return Note(from: root)
        //TODO: cache in a singleton
    }
}


//@MainActor class Folder: ObservableObject {
//    static func rootFolder() -> CRObject {
//        return CRObject.virtualRootObject(objectType: .folder)
//    }
//}


//source: https://github.com/onmyway133/blog/issues/694
// https://stackoverflow.com/questions/58996403/observedobject-inside-observableobject-not-refreshing-view
@MainActor class Root: ObservableObject {
    var notesRoot:CRObject
    
    private var observer: [AnyCancellable] = []
    
    init() {
        let context = CRStorageController.shared.localContainer.viewContext
        notesRoot = CRObject.getOrCreateVirtualRootObject(context: context, objectType: .note)
        observer.append(notesRoot.objectWillChange.sink {
            [weak self] _ in
//            print("Root got notesRoot.objectWillChange. Notifying observers")
            self?.objectWillChange.send()
        })
    }

    /**
     for now an expensive version
     */
    //TODO: optimise when it works
    var notes: [Note] {
        let myNotes = notesRoot.containedEntities.map{ Note(from: $0 as! CRObject)}
        let sortedNotes = myNotes.sorted{ $0.operationID > $1.operationID }
        print("notes:")
        for note in sortedNotes {
            print("'\(note.title)'", terminator: " ")
        }
        print()
        return sortedNotes
    }
    
    func printDebug() {
        print("Root debug:", terminator: " ")
        let myNotes = notesRoot.containedEntities.map{ Note(from: $0 as! CRObject)}
        let sortedNotes = myNotes.sorted{ $0.operationID < $1.operationID }
        for note in sortedNotes {
            print("\(note.operationID.lamport):'\(note.title)'", terminator: " ")
        }
        print("")
        print("Last lamport \(lastLamport)")
    }
}

extension Collection where Element == Note, Index == Int {
    @MainActor func delete(at indices: IndexSet) {
        for indice in indices {
            let note: Note = self[indice]
            note.markAsDeleted()
        }
    }
}
