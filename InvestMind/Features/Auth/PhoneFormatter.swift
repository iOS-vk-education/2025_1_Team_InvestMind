//
//  PhoneFormatter.swift
//  InvestMind
//
//  Created by Булат Хусаинов on 21.11.2025.
//

import Foundation

struct PhoneFormatter {

    static func digits(from string: String) -> String {
        string.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
    }

    static func format(_ phone: String) -> String {
        var digits = digits(from: phone)

        guard !digits.isEmpty else { return "" }

        // 8 → 7
        if digits.first == "8" {
            digits = "7" + digits.dropFirst()
        }

        // если начинается не с 7 → добавляем
        if digits.first != "7" {
            digits = "7" + digits
        }

        // ограничиваем максимум до 11 цифр
        digits = String(digits.prefix(11))

        var result = "+7"

        if digits.count > 1 {
            let code = String(digits.dropFirst().prefix(3))
            if !code.isEmpty { result += " " + code }

            if digits.count > 4 {
                let p1 = String(digits.dropFirst(4).prefix(3))
                if !p1.isEmpty { result += " " + p1 }

                if digits.count > 7 {
                    let p2 = String(digits.dropFirst(7).prefix(2))
                    if !p2.isEmpty { result += " " + p2 }

                    if digits.count > 9 {
                        let p3 = String(digits.dropFirst(9).prefix(2))
                        if !p3.isEmpty { result += " " + p3 }
                    }
                }
            }
        }

        return result
    }

    static func isValid(_ phone: String) -> Bool {
        digits(from: phone).count == 11
    }
}

