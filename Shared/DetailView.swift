//
//  ContentView.swift
//  Shared
//
//  Created by Mateusz Lapsa-Malawski on 27/12/2021.
//

import SwiftUI
import CoreData
import CRAttributes


struct DetailView: View {
    @ObservedObject var note: Note

    init(_ newNote: Note) {
        self.note = newNote
    }

    var body: some View {
        VStack {
//            Text("\(note.title)")
            TextField("Title", text: $note.title, prompt: Text("Title")).textFieldStyle(.roundedBorder)
            CRTextView(textStorage: note.body)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
        .navigationBarTitle(Text("Detail"))
    }
}
