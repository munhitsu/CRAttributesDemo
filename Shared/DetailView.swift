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
            if note.hasTombstone == false { //FIXME: weird it's not noticing that hasTombstone=true
                TextField("Title", text: $note.title, prompt: Text("Title")).textFieldStyle(.roundedBorder)
                CRTextView(textStorage: note.body)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            } else {
                Text("Detail view content goes here")
            }
        }
        .navigationBarTitle(Text("Detail"))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button(action: {
                        debugNote()
                    }, label: {
                        Text("Debug")
                    })
                    Button(action: {
                        debugImport()
                    }, label: {
                        Text("Simulate sync")
                    })
                }
            }
        }
    }
    
    func debugNote() {
        print("attribute value: '\(note.body_attribute.textStorage.string)'")
        print("linked list:     '\(note.body_attribute.operation!.stringFromRGAList().0)'")
        print("tree crawl:      '\(note.body_attribute.operation!.stringFromRGATree().0)'")
    }
    
    func debugImport() {
        Task {
            //        note.body.loadFromJsonIndexDebug(limiter: 1000, bundle: Bundle.main)
                    note.body.replaceCharacters(in: NSRange(location: 0, length: 0), with: "local edit")
            //        let tempLocalContext = CRStorageController.shared.localContainer.newBackgroundContext()
//            let viewContext = CRStorageController.shared.localContainer.viewContext
            //        let body_operation_id = note.body_attribute.operationID!
    //            let body_attribute = CRAttributeMutableString(from:body_operation_id.findOperationOrCreateGhost(in: viewContext))
            let fakePeerID = UUID()
            let body_attribute = note.body_attribute
            let title_attribute = note.title_attribute
            let title_lamport = title_attribute.getLastOperation()!.lamport

            var forest = ProtoOperationsForest()
            forest.version = 0
            forest.peerID = fakePeerID.data

            var stringTree = ProtoOperationsTree()
            stringTree.containerID = ProtoOperationID.with{
                $0.lamport = body_attribute.operationID!.lamport
                $0.peerID = body_attribute.operationID!.peerID.data
            }
            
            stringTree.stringInsertOperationsList.stringInsertOperations.append(ProtoStringInsertOperation.with {
                $0.version = 0
                $0.id.lamport = 1
                $0.id.peerID  = fakePeerID.data
                $0.contribution = Int32(UnicodeScalar("a").value)
                $0.parentID.lamport = body_attribute.operationID!.lamport
                $0.parentID.peerID = body_attribute.operationID!.peerID.data
            })
            stringTree.stringInsertOperationsList.stringInsertOperations.append(ProtoStringInsertOperation.with {
                $0.version = 0
                $0.id.lamport = 2
                $0.id.peerID  = fakePeerID.data
                $0.contribution = Int32(UnicodeScalar("b").value)
                $0.parentID.lamport = 1
                $0.parentID.peerID = fakePeerID.data
            })
            stringTree.stringInsertOperationsList.stringInsertOperations.append(ProtoStringInsertOperation.with {
                $0.version = 0
                $0.id.lamport = 3
                $0.id.peerID  = fakePeerID.data
                $0.contribution = Int32(UnicodeScalar("c").value)
                $0.parentID.lamport = 2
                $0.parentID.peerID = fakePeerID.data
            })
            
            var titleTree = ProtoOperationsTree()
            titleTree.containerID = ProtoOperationID.with{
                $0.lamport = title_attribute.operationID!.lamport
                $0.peerID = title_attribute.operationID!.peerID.data
            }
            titleTree.lwwOperation = ProtoLWWOperation.with {
                $0.version = 0
                $0.id.lamport = title_lamport+1
                $0.id.peerID  = fakePeerID.data
                $0.string = "remote edit"
            }
            
            var disconnectedStringTree = ProtoOperationsTree()
            disconnectedStringTree.containerID = ProtoOperationID.with{
                $0.lamport = body_attribute.operationID!.lamport
                $0.peerID = body_attribute.operationID!.peerID.data
            }
            
            disconnectedStringTree.stringInsertOperationsList.stringInsertOperations.append(ProtoStringInsertOperation.with {
                $0.version = 0
                $0.id.lamport = 7
                $0.id.peerID  = fakePeerID.data
                $0.contribution = Int32(UnicodeScalar("g").value)
                $0.parentID.lamport = 6
                $0.parentID.peerID = fakePeerID.data
            })
            disconnectedStringTree.stringInsertOperationsList.stringInsertOperations.append(ProtoStringInsertOperation.with {
                $0.version = 0
                $0.id.lamport = 8
                $0.id.peerID  = fakePeerID.data
                $0.contribution = Int32(UnicodeScalar("h").value)
                $0.parentID.lamport = 7
                $0.parentID.peerID = fakePeerID.data
            })
            disconnectedStringTree.stringInsertOperationsList.stringInsertOperations.append(ProtoStringInsertOperation.with {
                $0.version = 0
                $0.id.lamport = 9
                $0.id.peerID  = fakePeerID.data
                $0.contribution = Int32(UnicodeScalar("i").value)
                $0.parentID.lamport = 8
                $0.parentID.peerID = fakePeerID.data
            })

            var orphanedStringTree = ProtoOperationsTree()
            orphanedStringTree.containerID = ProtoOperationID.with{
                $0.lamport = 100
                $0.peerID = fakePeerID.data
            }
            
            orphanedStringTree.stringInsertOperationsList.stringInsertOperations.append(ProtoStringInsertOperation.with {
                $0.version = 0
                $0.id.lamport = 101
                $0.id.peerID  = fakePeerID.data
                $0.contribution = Int32(UnicodeScalar("1").value)
                $0.parentID.lamport = 100
                $0.parentID.peerID = fakePeerID.data
            })

            
            forest.trees.append(titleTree)
            forest.trees.append(stringTree)
            forest.trees.append(disconnectedStringTree)
            forest.trees.append(orphanedStringTree)

            let replicationContext = CRStorageController.shared.replicationContainer.newBackgroundContext()
//            let opForest:CDOperationsForest =
            await replicationContext.perform {
                let _ = CDOperationsForest(context: replicationContext, from:forest)
                try! replicationContext.save()
                // let's try accessign replication container on the newBackgroundContext

                // let's try accessign replication container on the existing bgContext
//                CRStorageController.shared.replicationController.processDownstreamForest(forest: opForest.objectID)
//                processDownstreamHistoryAsync()
//                return opForest
            }
//            let rc = CRReplicationController(localContext: CRStorageController.shared.localContainer.viewContext, replicationContext: replicationContext, skipTimer: true, skipRemoteChanges: true)
//            await rc.processDownstreamForest(forest: opForest.objectID)

//            body_attribute.operationID
            
            
//            body_attribute.textStorage.replaceCharacters(in: NSRange(location: 0, length: 0), with: "REMOTE EDIT", saving: false)
//            let rc = CRReplicationController(localContext: tempLocalContext, replicationContext: CRStorageController.shared.replicationContainerBackgroundContext, skipTimer: true, skipRemoteChanges: true)
//            rc.processUpsteamOperationsQueue()
//            tempLocalContext.reset()
            
            
                    
            // DispatchQueue.global(qos: .userInitiated).async {
            
            // import 1K ops locally into local view context
            // create new context (1)
            // and import next 1K ops into context (1)
            // push to sync storage
            // purge context (1)
            // process new trees/forests (can skip detection of new ones on sync storage)
        }
    }
}
