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

    private var _is_pinned: CRAttributeBool
    private var _title: CRAttributeString
    private var _body: CRAttributeMutableString

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
        self._is_pinned = crObject.attribute(name: "is_pinned", attributeType: .boolean) as! CRAttributeBool
        self._title = crObject.attribute(name: "title", attributeType: .string) as! CRAttributeString
        self._body = crObject.attribute(name: "body", attributeType: .mutableString) as! CRAttributeMutableString
    }

    /**
     create new object
     */
    public init() {
        self.crObject = CRObject(objectType: .note, container: nil)
        self._is_pinned = crObject.attribute(name: "is_pinned", attributeType: .boolean) as! CRAttributeBool
        self._title = crObject.attribute(name: "title", attributeType: .string) as! CRAttributeString
        self._body = crObject.attribute(name: "body", attributeType: .mutableString) as! CRAttributeMutableString
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
            _is_pinned.value ?? false
        }
        set {
            _is_pinned.value = newValue
        }
        
    }
//    var created_on: Date
//    var updated_on: Date
    
    var title: String {
        get {
            _title.value ?? ""
        }
        set {
            _title.value = newValue
        }
    }

    var body: CRTextStorage {
        get {
            _body.textStorage
        }
    }
    
    
    /**
     returns a Note that contains all the notes whose container was nil
     this container is later updated on every related db update
     */
    public static func rootNote() -> Note {
        let root = CRObject.getOrCreateVirtualRootObject(objectType: .note)
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
        notesRoot = CRObject.getOrCreateVirtualRootObject(objectType: .note)
        observer.append(notesRoot.objectWillChange.sink {
            [weak self] _ in
            print("Root got notesRoot.objectWillChange. Notifying observers")
            self?.objectWillChange.send()
        })
    }

    /**
     for now an expensive version
     */
    //TODO: optimise when it works
    var notes: [Note] {
        print("notes:")
        let myNotes = notesRoot.containedEntities.map{ Note(from: $0 as! CRObject)}
        let sortedNotes = myNotes.sorted{ $0.title < $1.title }
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
