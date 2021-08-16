//
//  ContentView.swift
//  iSplit
//
//  Created by Mariana Yamamoto on 8/12/21.
//

import SwiftUI

enum RoundOption: CaseIterable {
    case up
    case down
    case none

    var title: String {
        switch self {
        case .up: return "Round Up"
        case .down: return "Round Down"
        case .none: return "Don't round"
        }
    }
}

struct CheckBoxView: View {
    var text: String
    @Binding var checked: Bool

    var body: some View {
        HStack {
            Image(systemName: checked ? "checkmark.square.fill" : "square")
                .foregroundColor(checked ? Color(UIColor.systemBlue) : Color.secondary)
                Text(text)
            }
        .onTapGesture {
            self.checked.toggle()
        }
    }
}

struct ContentView: View {
    @State private var checkAmount = ""
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 2
    @State private var round: RoundOption = .none

    let tipPercentages = [10, 15, 20, 25, 0]
    var peopleCount: Double { Double(numberOfPeople + 2) }
    var tipSelection: Double { Double(tipPercentages[tipPercentage]) }
    var orderAmount: Double { Double(checkAmount) ?? 0 }
    var tipValue: Double { (orderAmount / 100 * tipSelection) / peopleCount }
    var roundedTipValue: Double { totalPerPerson - orderPerPerson }
    var orderPerPerson: Double { orderAmount / peopleCount }
    var totalPerPerson: Double {
        let amountPerPerson = orderPerPerson + tipValue
        switch round {
        case .up:
            return amountPerPerson.rounded(.up)
        case .down:
            return amountPerPerson.rounded(.down)
        case .none:
            return amountPerPerson
        }
    }

    init() {
        let font = UIFont(name: "Georgia-Bold", size: 30)
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : font!]
    }
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Amount", text: $checkAmount)
                        .keyboardType(.decimalPad)
                    Picker("Number of people", selection: $numberOfPeople) {
                        ForEach(2 ..< 100) {
                            Text("\($0) people")
                        }
                    }
                }

                Section(header: Text("How much tip do you want to leave?")) {
                    Picker("Tip percentage", selection: $tipPercentage) {
                        ForEach(0 ..< tipPercentages.count) {
                            Text("\(self.tipPercentages[$0])%")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Picker(selection: $round, label: Text("Round value:")) {
                        ForEach(RoundOption.allCases, id: \.self) { option in
                            Text(option.title)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section {
                    Text("Value: $\(orderPerPerson, specifier: "%.2f")")
                    Text("Tip: $\(roundedTipValue, specifier: "%.2f")")
                    Text("Total: $\(totalPerPerson, specifier: "%.2f")")
                }
            }
            .navigationBarTitle("iSplit the Check")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
