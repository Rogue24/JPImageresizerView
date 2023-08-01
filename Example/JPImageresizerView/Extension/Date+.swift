//
//  Date+.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/12/27.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import SwiftUI

extension Date {
    typealias DateInfo = (year: String, month: String, day: String, weekday: String)
    
    var info: DateInfo {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday], from: self)
    
        let year = "\(components.year!)"
        let month = Months[components.month! - 1]
        let day = "\(components.day!)"
        let weekday = ShotWeekdays[components.weekday! - 1] // 星期几（注意，周日是“1”，周一是“2”。。。。）
        return (year, month, day, weekday)
    }
    
    var mmssString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: self)
    }
    
    var ssString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "mm:ss"
        return formatter.string(from: self)
    }
}

// MARK: - Const
let Months = [
    "January",
    "February",
    "March",
    "April",
    "May",
    "June",
    "July",
    "August",
    "September",
    "October",
    "November",
    "December"
]

let ShotMonths = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
]

let Weekdays = [
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
]

let ShotWeekdays = [
    "Sun",
    "Mon",
    "Tue",
    "Wed",
    "Thu",
    "Fri",
    "Sat"
]

