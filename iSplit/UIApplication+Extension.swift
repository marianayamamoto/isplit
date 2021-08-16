//
//  UIApplication+Extension.swift
//  iSplit
//
//  Created by Mariana Yamamoto on 8/16/21.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
