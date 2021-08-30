//
//  ContentView.swift
//  iSplit
//
//  Created by Mariana Yamamoto on 8/12/21.
//

import Combine
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

struct Background<Content: View>: View {
    private var content: Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    var body: some View {
        Color.white
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .overlay(content)
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
    @State private var checkAmount: Double? = 0.0
    @State private var numberOfPeople = "2"
    @State private var tipPercentage = "20"
    @State private var tipPercentageIndex = 2
    @State private var round: RoundOption = .none
    @State private var showPercentageText = false

    let tipPercentages = [0, 10, 20, 30, -1]
    var tipSelection: Double {
        let selected = tipPercentages[tipPercentageIndex]
        if selected == -1 {
            return Double(tipPercentage) ?? 0
        }
        return Double(selected)

    }
    var peopleCount: Double { Double(numberOfPeople) ?? 0 }
    var amountValue: Double { checkAmount ?? 0 }
    var tipValue: Double { (amountValue / 100 * tipSelection) / peopleCount }
    var roundedTipValue: Double { totalPerPerson - orderPerPerson }
    var orderPerPerson: Double { amountValue / peopleCount }
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

    private var percentageFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .percent
        f.maximumFractionDigits = 2
        return f
    }()

    init() {
        let font = UIFont(name: "SavoyeLetPlain", size: 40)
        UINavigationBar.appearance().largeTitleTextAttributes = [.font : font!]

    }

    private func endEditing() {
        UIApplication.shared.endEditing()
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    CurrencyTextField("Amount", value: $checkAmount)
                    TextField("Number of people", text: $numberOfPeople)
                        .keyboardType(.numberPad)
                        .onReceive(Just(numberOfPeople)) { newValue in
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if filtered != newValue {
                                self.numberOfPeople = filtered
                            }
                        }
                }

                Section(header: Text("How much tip do you want to leave?")) {
                    Picker("Tip percentage", selection: $tipPercentageIndex) {
                        ForEach(0 ..< tipPercentages.count) {
                            if self.tipPercentages[$0] == -1 {
                                Text("Other")
                            } else {
                                Text("\(self.tipPercentages[$0])%")
                            }
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onReceive(Just(tipPercentageIndex)) { newValue in
                        self.showPercentageText = tipPercentages[newValue] == -1
                    }

                    if showPercentageText {
                        TextField("Custom tip percentage", text: $tipPercentage)
                            .keyboardType(.numberPad)
                            .onReceive(Just(numberOfPeople)) { newValue in
                                let filtered = newValue.filter { "0123456789".contains($0) }
                                if filtered != newValue {
                                    self.numberOfPeople = filtered
                                }
                            }
                    }
                }

                Section(header: Text("Round final value?")) {
                    Picker(selection: $round, label: Text("Round value:")) {
                        ForEach(RoundOption.allCases, id: \.self) { option in
                            Text(option.title)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Amount per person")) {
                    Text("Value: $\(orderPerPerson, specifier: "%.2f")")
                    Text("Tip: $\(roundedTipValue, specifier: "%.2f")")
                    Text("Total: $\(totalPerPerson, specifier: "%.2f")")
                        .foregroundColor(tipPercentageIndex == 0 ? .red : .blue)
                }
            }.navigationBarTitle("iSplit the Check")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
