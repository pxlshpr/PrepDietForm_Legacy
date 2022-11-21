//
//  File.swift
//  
//
//  Created by Ahmed Khalaf on 14/11/2022.
//

import Foundation

extension Double {
    /// uses commas, rounds it off
    var formattedEnergy: String {
        let rounded = self.rounded()
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let number = NSNumber(value: Int(rounded))
        
        guard let formatted = numberFormatter.string(from: number) else {
            return "\(Int(rounded))"
        }
        return formatted
    }
    
    /// no commas, but rounds it off
    var formattedMacro: String {
        "\(Int(self.rounded()))"
    }
    
    /// commas, only rounded off if greater than 100, otherwise 1 decimal place
    var formattedGoalValue: String {
        if self >= 100 {
            let rounded = self.rounded()
            
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            let number = NSNumber(value: Int(rounded))
            
            guard let formatted = numberFormatter.string(from: number) else {
                return "\(Int(rounded))"
            }
            return formatted
        } else {
            return self.rounded(toPlaces: 1).cleanAmount
        }
    }

}
