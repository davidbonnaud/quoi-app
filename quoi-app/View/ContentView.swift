//
//  ContentView.swift
//  quoi-app
//
//  Created by David Bonnaud on 8/18/21.
//

import SwiftUI
import CoreData

struct ContentView: View {
    // MARK: - PROPERTIES
    
    @State var entry: String = ""
    
    @State var meaning: String = ""
    
    @State var flipped = false
    
    @GestureState private var dragState = DragState.inactive
    
    private var dragAreaThreshold: CGFloat = 65.0
    
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
    
    //MARK: - BODY
    
    var body: some View {
        
        if (homeView) {
            VStack {
                //MARK: - Header
                
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
                    .opacity(dragState.isDragging ? 0.0 : 1.0)
                    .animation(.default)
                
                Spacer()
                
                //MARK: - Cards
                ZStack {
                    ForEach(items) {item in
                        Image("photo-paris-france-1")
                            .resizable()
                            .cornerRadius(24)
                            .scaledToFit()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .overlay(
                                VStack(alignment: .center, spacing: 12) {
                                    Text(self.flipped ? (item.entry ?? "") : (item.meaning ?? ""))
                                        .foregroundColor(.white)
                                        .font(.largeTitle)
                                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                                        .shadow(radius: 1)
                                        .rotation3DEffect(self.flipped ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(-10), z: CGFloat(0)))
                                        .animation(.default)
                                        
                                }
                            )
                            .rotation3DEffect(self.flipped ? Angle(degrees: 180): Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(10), z: CGFloat(0)))
                            .animation(.default)
                            .onTapGesture {
                                self.flipped.toggle()
                            }
                            .gesture(LongPressGesture(minimumDuration: 0.01).sequenced(before: DragGesture()).updating(self.$dragState, body: { (value, state, transaction) in switch value {
                            case .first(true):
                                state = .pressing
                            case .second(true, let drag):
                                state = .dragging(translation: drag?.translation ?? .zero)
                            default:
                                break
                            }}))
                            .overlay(
                                ZStack {
                                    // next
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 128))
                                        .shadow(color: Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)), radius: 12, x: 0, y: 0)
                                        .opacity(self.dragState.translation.width > self.dragAreaThreshold ? 1.0 : 0.0)
                                    
                                    
                                    // mastered
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.purple)
                                        .font(.system(size: 128))
                                        .shadow(color: Color(UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)), radius: 12, x: 0, y: 0)
                                        .opacity(self.dragState.translation.width < -self.dragAreaThreshold ? 1.0 : 0.0)
                                }
                            )
                            .offset(x: self.dragState.translation.width, y: self.dragState.translation.height)
                            .scaleEffect(self.dragState.isDragging ? 0.85 : 1.0)
                            .rotationEffect(Angle(degrees: Double(self.dragState.translation.width / 12)))
                            .animation(.interpolatingSpring(stiffness: 120, damping: 120))
                            .padding()
                        //: image
                    }
                }
                
                    
                
                Spacer()
                
                //MARK: - All entries button
                
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
                .opacity(dragState.isDragging ? 0.0 : 1.0)
                .animation(.default)
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
                        TextField("Meaning", text: $meaning)
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
                                
                                Text(item.meaning ?? "")
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
    
    //MARK: - DRAGSTATE
    
    enum DragState {
        case inactive
        case pressing
        case dragging(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive, .pressing:
                return .zero
            case .dragging(let translation):
                return translation
            }
        }
        
        var isDragging: Bool {
            switch self {
            case .dragging:
                return true
            case .pressing, .inactive:
                return false
            }
        }
        
        var isPressing: Bool {
            switch self {
            case .pressing, .dragging:
                return true
            case .inactive:
                return false
            }
        }
    }
    
        //MARK: - FUNCTION
        
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.entry = entry
            newItem.meaning = meaning
            newItem.mastered = false
            newItem.id = UUID()
            
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            entry = ""
            meaning = ""
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

//MARK: - PREVIEW

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
