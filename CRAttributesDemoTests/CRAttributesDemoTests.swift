//
//  CRAttributesDemoTests.swift
//  CRAttributesDemoTests
//
//  Created by Mateusz Lapsa-Malawski on 22/01/2022.
//

import XCTest
@testable import CRAttributesDemo

class CRAttributesDemoTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    @MainActor func testRoot() throws {
        let _ = [Note(title: "A"), Note(title: "B"), Note(title: "C")]

        let rootNote = Note.rootNote()
        let entities = rootNote.containedEntities
    }



}
