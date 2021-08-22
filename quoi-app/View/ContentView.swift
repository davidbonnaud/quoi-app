//
//  ContentView.swift
//  quoi-app
//
//  Created by David Bonnaud on 8/18/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // PROPERTY
    
    @State var entry: String = ""
    
    private var isButtonDisabled: Bool {
        entry.isEmpty
    }
    
    @State var homeView = true
    
    // FETCHING DATA
    
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    // BODY
    
    var body: some View {
        
        if (homeView) {
            VStack {
                // Header
                
                Text("Quoi")
                    .font(.system(size: 30, design: .monospaced))
                    .fontWeight(.heavy)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .foregroundColor(.purple)
                    .accentColor(.purple)
                    .background(
                        RoundedRectangle(cornerRadius: 15).stroke(Color.purple, lineWidth: 2)
                    )
                    
                    
                
                Spacer()
                
                // Cards
                
                Image("photo-paris-france-1")
                    .resizable()
                    .cornerRadius(24)
                    .scaledToFit()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .overlay(
                        VStack(alignment: .center, spacing: 12) {
                            Text("Test")
                                .foregroundColor(.white)
                        }
                    )
                
                Spacer()
                
                // All entries button
                
                Button(action: {
                    homeView = false
                }, label: {
                    Text("All Entries")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.heavy)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .accentColor(.purple)
                        .background(
                            Capsule().stroke(Color.purple, lineWidth: 2)
                        )
                })
            }
        } else {
            NavigationView {
                VStack {
                    VStack(spacing: 16) {
                        TextField("New Entry", text: $entry)
                            .padding()
                            .background(
                                Color(UIColor.systemGray6)
                            )
                            .cornerRadius(10)
                        Button(action: {
                            addItem()
                        }, label: {
                            Spacer()
                            Text("SAVE")
                            Spacer()
                        })
                        .disabled(isButtonDisabled)
                        .padding()
                        .font(.headline)
                        .foregroundColor(.white)
                        .background(isButtonDisabled ? Color.gray : Color.purple)
                        .cornerRadius(10)
                    } //: VSTACK
                    .padding()
                    
                    List {
                        ForEach(items) { item in
                            VStack(alignment: .leading) {
                                Text(item.entry ?? "")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Text(item.mastered ? "Mastered": "Not Mastered")
                                    .font(.caption)
                                
                                Text("Item added at \(item.timestamp!, formatter: itemFormatter)")
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            } //: LIST ITEM
                        }
                        .onDelete(perform: deleteItems)
                    } //: LIST
                } //: VSTACK
                .navigationBarTitle("Entries", displayMode: .large)
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    #endif

                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: backToCardView) {
                        Label("Back", systemImage: "arrowshape.turn.up.left")
                        }
                    }
                } //: TOOLBAR
            } //: NAVIGATION
        }
    }
        // FUNCTION
        
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.entry = entry
            newItem.mastered = false
            newItem.id = UUID()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            entry = ""
            hideKeyboard()
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func backToCardView() {
        homeView = true
    }
}

// PREVIEW

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
