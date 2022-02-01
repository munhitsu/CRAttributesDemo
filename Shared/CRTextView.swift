//
//  CRTextView.swift
//  CRAttributesDemo
//
//  Created by Mateusz Lapsa-Malawski on 31/01/2022.
//

import SwiftUI
import CRAttributes


struct CRTextView: UIViewRepresentable {
    var textStorage: CRTextStorage
//    @Binding var isEditing: Bool
//    @State var testCounter: Int = 0
//    var selection: NSRange?
//    var cursorPosition: Int?
//    var textStorage: CoOpTextStorage? = nil

    func makeUIView(context: Context) -> UITextView {
        print("In attribute: '\(textStorage.string)'")

        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer()
        textContainer.widthTracksTextView = true
        textContainer.heightTracksTextView = false
        layoutManager.addTextContainer(textContainer)

        // TODO: get frame from the context
        let textView = UITextView(frame: .infinite, textContainer: textContainer)
        textView.delegate = context.coordinator

        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.textColor = .label

        textView.isScrollEnabled = true
        textView.isEditable = true
        textView.isUserInteractionEnabled = true
        textView.isSelectable = true
        textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)

//        context.coordinator.setStore(store: textStorage.store)
        context.coordinator.setView(view: textView)

//        textStorage.setCoordinator(context.coordinator)

        return textView
    }

    /*
     will be triggered by new text in the parent view
     */
    func updateUIView(_ textView: UITextView, context: Context) {
        print("updateUIView()")
//        if self.selection != nil {
//            textView.selectedRange = self.selection!
//        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, textStorage: textStorage)
    }

    class Coordinator: NSObject, UITextViewDelegate {

//        var parent: CRTextView
        var view: UITextView?
        var textStorage: NSTextStorage

        init(_ uiTextView: CRTextView, textStorage: NSTextStorage) {
            print("CRTextView.Coordinator.init")
//            parent = uiTextView
            self.textStorage = textStorage
            super.init()
        }

        func setView(view: UITextView) {
            self.view = view
        }

        deinit {
            print("CRTextView.Coordinator.deinit()")
        }

        func updateSelection(_ selection: NSRange) {
            print("updateSelection(\(selection))")
            self.view?.selectedRange = selection
//            self.view?.setNeedsDisplay()
//            let from = self.view!.position(from: self.view!.beginningOfDocument, offset: selection.location)
//            let to = self.view!.position(from: self.view!.beginningOfDocument,
//            offset: selection.location + selection.length)
//
//            self.view!.selectedTextRange = self.view!.textRange(from: from!, to: to!)
//            self.parent.testCounter += 1
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            print("shouldChangeTextIn()")
            return true
        }

        /*
         is executed on every character change
         in response to user-initiated changes to the text
         */
        func textViewDidChange(_ textView: UITextView) {
            print("textViewDidChange()")
        }

        public func textViewDidBeginEditing(_ textView: UITextView) {
//            DispatchQueue.main.async {
//                self.parent.isEditing = true
//            }
//                if self.parent.cursorPosition != nil {
//                    print("Attempting to set position to: \(self.parent.cursorPosition!)")
//                    setUITextViewCursorPosition(textView: textView, cursorPosition: self.parent.cursorPosition!)
//                }
//            }
        }

        public func textViewDidEndEditing(_ textView: UITextView) {
//            DispatchQueue.main.async {
//                try! CRStorageController.shared.localContainer.viewContext.save()
//                self.parent.isEditing = false
//            }
        }

        // I need to track selection in operations so that when remote operation comes selection within view with update
        public func textViewDidChangeSelection(_ textView: UITextView) {
//            let range: NSRange = textView.selectedRange
//            self.textAttribute.updateSelectionFrom(range: range)
            
//            self.parent.selection = range
            // TODO (later) find object that is both reachable from here and from within TextStorage
//            if self.store != nil {
//                NotificationCenter.default.post(name: .textViewDidChangeSelection,
//                                                object: self.store,
//                                                userInfo: ["range": range])
//            }
        }
    }
}

func setUITextViewCursorPosition(textView: UITextView, cursorPosition: Int) {
    if let newPosition = textView.position(from: textView.beginningOfDocument, offset: cursorPosition) {
        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
    }
}


//struct CRTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        CRTextView()
//    }
//}
