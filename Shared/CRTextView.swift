//
//  CRTextView.swift
//  CRAttributesDemo
//
//  Created by Mateusz Lapsa-Malawski on 28/12/2021.
//

import SwiftUI
import CRAttributes

struct CRTextView: View {
    var textStorage: CRTextStorage
    @Binding var isEditing: Bool


    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//struct CRTextView_Previews: PreviewProvider {
//    static var previews: some View {
//        CRTextView()
//    }
//}
