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
    @StateObject var root = Root()
    
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
                            asyncImportDebug()
                        }
                    }, label: {
                        Text("Import")
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
//        DispatchQueue.global(qos: .userInitiated).async {
//            _ = Note.createFromJsonIndexDebug(in: PersistenceController.shared.containerTaskContext, limiter: 10000, sync: true)
//        }
    }
}


struct DetailView: View {
    @ObservedObject var note: Note
    @State var isEditing: Bool = false

    init(_ newNote: Note) {
        self.note = newNote
    }

    var body: some View {
        VStack {
//            Text("\(note.title)")
            TextField("Title", text: $note.title, prompt: Text("Title")).textFieldStyle(.roundedBorder)
            CRTextView(textStorage: note.body, isEditing: $isEditing)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .navigationBarTitle(Text("Detail"))
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
