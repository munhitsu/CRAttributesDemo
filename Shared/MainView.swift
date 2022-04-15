//
//  MainView.swift
//  CRAttributesDemo
//
//  Created by Mateusz Lapsa-Malawski on 28/12/2021.
//

import SwiftUI
import CRAttributes


struct MainView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            NotesListView()
            Text("Detail view content goes here")
                .navigationTitle((Text("Detail")))
        }
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct NotesListView: View {
    @Environment(\.managedObjectContext) private var viewContext

//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
//        animation: .default) var notes: FetchedResults<Note>
    @StateObject var root: Root
    
    init() {
        self._root = StateObject(wrappedValue: Root())
    }
    
    var body: some View {
        List {
            ForEach(root.notes, id: \.operationID) { note in
                NavigationLink(
                    destination: DetailView(note)
                ) {
                    Text("\(note.title)")
//                    Text("\(note.timestamp, formatter: dateFormatter)")
                }
            }
            .onDelete { indices in
                self.root.notes.delete(at: indices)
            }
        }
        .navigationTitle(Text("Notes"))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        root.printDebug()
                    }, label: {
                        Text("Debug")
                    })
                    Button(action: {
                        withAnimation {
                            _ = Note(title: "1")
                        }
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                
            }

        }
    }
    func asyncImportDebug() {
        let newNote = Note(title:"debug import")
        newNote.body.loadFromJsonIndexDebug(limiter: 1000, bundle: Bundle.main)

        
        
        
//        DispatchQueue.global(qos: .userInitiated).async {
//            _ = Note.createFromJsonIndexDebug(in: PersistenceController.shared.containerTaskContext, limiter: 10000, sync: true)
//        }
    }
}




struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
