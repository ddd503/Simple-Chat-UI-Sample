//
//  Date+String.swift
//  Simple-Chat-UI-Sample
//
//  Created by kawaharadai on 2018/08/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import Foundation

extension Date {
    
    func stringDate(format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
}
