//
//  PrettyDatesHelper.swift
//  Diary
//
//  Created by Stephen McMillan on 16/02/2019.
//  Copyright © 2019 Stephen McMillan. All rights reserved.
//

import Foundation

extension Date {
    /// Returns the current date in the format 'Friday 15 February' etc
    var longStringRepresentation: String {
        let dateFormatter = DateFormatter()
        // eg. Friday 15 February
        dateFormatter.dateFormat = "EEEE dd MMMM"
        
        return dateFormatter.string(for: self) ?? "Date Unknown"
    }
}
