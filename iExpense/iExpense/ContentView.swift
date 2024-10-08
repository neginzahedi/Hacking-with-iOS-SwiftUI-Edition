//
//  ContentView.swift
//  iExpense
//
//  Created by Negin Zahedi on 2024-10-08.
//

import SwiftUI

struct ExpenseItemView: View {
    var item: ExpenseItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                
                Text(item.type)
            }
            
            Spacer()
            
            Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
        }
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()
    
    @State private var showingAddExpense = false
    
    
    var body: some View {
        NavigationStack{
            List{
                Section("Personal"){
                    ForEach(expenses.items.filter{$0.type == "Personal"}){ item in
                        ExpenseItemView(item: item)
                    }
                    .onDelete { indexSet in
                        removeItem(at: indexSet, from: expenses.items.filter{$0.type == "Personal"})
                    }
                }
                
                Section("Business"){
                    ForEach(expenses.items.filter{$0.type == "Business"}){ item in
                        ExpenseItemView(item: item)
                    }
                    .onDelete { indexSet in
                        removeItem(at: indexSet, from: expenses.items.filter{$0.type == "Business"})
                    }
                }
            }
            .navigationTitle("iExpense")
            .toolbar {
                Button("Add Expense", systemImage: "plus"){
                    showingAddExpense = true
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: expenses)
            }
        }
        
    }
    
    func removeItem(at offsets: IndexSet, from filteredArray: [ExpenseItem]){
        for offset in offsets {
            if let index = expenses.items.firstIndex(where: { $0.id == filteredArray[offset].id }) {
                expenses.items.remove(at: index)
            }
        }
    }
}

#Preview {
    ContentView()
}

struct ExpenseItem: Identifiable, Codable {
    var id: UUID = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem](){
        didSet {
            if let encoded = try? JSONEncoder().encode(items){
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    
    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items"){
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems){
                items = decodedItems
                return
            }
        }
        
        items = []
    }
}
