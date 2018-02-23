//
//  TodoItem.swift
//  TodoList
//
//  Created by 默司 on 2018/2/22.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import Foundation

struct TodoItem: Codable {
    var id: String? = nil
    var title: String
    var creator: String
    var timestamp: TimeInterval = Date().timeIntervalSince1970
    var state: Bool = false
    
    init(title: String, creator: String) {
        self.title = title
        self.creator = creator
    }
}
