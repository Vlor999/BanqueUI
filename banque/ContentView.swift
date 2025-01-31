import SwiftUI

@Observable
class Compte: ObservableObject {
    var value:Double = 0
    var tabTransaction: [Transaction] = []
    
    func credit(transactionCredit: Transaction) {
        value += transactionCredit.amount
        ajouterTransaction(transaction: transactionCredit)
    }
    
    func debit(transactionDebit: Transaction) {
        value -= transactionDebit.amount
        ajouterTransaction(transaction: transactionDebit)
    }
    
    func ajouterTransaction(transaction: Transaction) {
        if transaction.amount != 0
        {
            tabTransaction.append(transaction)
        }
    }
}

@Observable
class Transaction: Identifiable {
    var date: Date = Date()
    var amount: Double = 0
    var id: UUID = UUID()
    
    func set(date: Date, amount: Double) {
        self.date = date
        self.amount = amount
    }
}

struct AjoutButton: View {
    @Binding var showTransaction: Bool
    var compte: Compte
    @State private var transactionAmount: String = ""
    
    var body: some View {
        let transaction = Transaction()
        let date = transaction.date
        VStack {
            Text("Entrer un montant :")
            
            TextField("Montant", text: $transactionAmount)
                .keyboardType(.numberPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            HStack {
                Button(action: {
                    transaction.set(date: date, amount: Double(transactionAmount) ?? 0)
                    compte.credit(transactionCredit: transaction)
                    showTransaction = false
                }) {
                    Text("Crédit")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    transactionAmount = "-" + transactionAmount
                    transaction.set(date: date, amount: Double(transactionAmount) ?? 0)
                    compte.credit(transactionCredit: transaction)
                    showTransaction = false
                }) {
                    Text("Débit")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            
            Button(action: {
                showTransaction = false
            }) {
                Text("Annuler")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}

struct showTransactionView: View {
    @ObservedObject var compte: Compte

    var body: some View {
        VStack {
            Text("Historique des transactions")
                .font(.headline)
                .padding()
            
            List(compte.tabTransaction) { transaction in
                HStack {
                    Text(transaction.date.formatted(date: .long, time: .shortened))
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(transaction.amount.formatted()) €")
                        .font(.body)
                        .bold()
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 15)
                                .fill(Color(.systemGray6)))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .padding(.vertical, 5)
            }
            .listStyle(.plain)
            .padding(.horizontal, 10)
        }
        .padding()
    }
}


struct ContentView: View {
    @StateObject private var compte = Compte()
    @State private var showTransaction = false
    @State private var showInfo = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "dollarsign.bank.building")
                Text("\(compte.value.formatted())€")
                    .font(.largeTitle)
                    .padding()
                
                Spacer()
                
                if !showTransaction {
                    Button(action: {
                        showTransaction = true
                    }) {
                        Image(systemName: "plus.app.fill")
                        Text("Nouvelle transaction")
                    }
                    .padding()
                    
                    Button(action: {
                        showInfo = !showInfo
                    }) {
                        Image(systemName: "info.circle")
                        Text("Info")
                    }
                    .sheet(isPresented: $showInfo) {
                        showTransactionView(compte: compte)
                    }
                }
                
                if showTransaction {
                    AjoutButton(showTransaction: $showTransaction, compte: compte)
                }
                
                Spacer()
            }
            .padding()
            .animation(.default, value: showTransaction)
        }
    }
}

#Preview {
    ContentView()
}
