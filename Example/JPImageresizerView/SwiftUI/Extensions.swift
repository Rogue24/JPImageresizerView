//
//  Extensions.swift
//  JPImageresizerView_Example
//
//  Created by aa on 2022/6/27.
//  Copyright © 2022 ZhouJianPing. All rights reserved.
//

import SwiftUI

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

extension UIImage {
    static func bundleImage(_ name: String, ofType ext: String?) -> UIImage {
        UIImage(contentsOfFile: Bundle.main.path(forResource: name, ofType: ext)!)!
    }
}

@available(iOS 15.0.0, *)
extension UIViewController {
    @objc static func createCropViewController(saveOneDayImage: ((_ oneDayImage: UIImage?) -> ())?) -> UIViewController {
        let vc = UIHostingController(rootView: CropView(saveOneDayImage: saveOneDayImage))
        vc.view.clipsToBounds = true
        return vc
    }
}
