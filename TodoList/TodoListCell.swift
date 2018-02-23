//
//  TodoListCell.swift
//  TodoList
//
//  Created by 默司 on 2018/2/22.
//  Copyright © 2018年 CCMOS. All rights reserved.
//

import UIKit

class TodoListCell: UITableViewCell {
    
    lazy var dateFormat: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "MM/dd HH:mm"
        return df
    }()
    
    var item: TodoItem! {
        didSet {
            titleLabel.text = item.title
            titleLabel.sizeToFit()
            creatorLabel.text = "by \(item.creator)"
            creatorLabel.sizeToFit()
            stateLabel.text = item.state ? "✔︎" : ""
            stateLabel.sizeToFit()
            timeLabel.text = dateFormat.string(from: Date(timeIntervalSince1970: item.timestamp))
            timeLabel.sizeToFit()
        }
    }
    
    lazy var titleLabel = UILabel()
    lazy var creatorLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.darkGray
        return l
    }()
    lazy var stateLabel = UILabel()
    lazy var timeLabel: UILabel = {
        let l = UILabel()
        l.textColor = UIColor.gray
        return l
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    func setupUI() {
        self.selectionStyle = .none
        self.backgroundView?.backgroundColor = .clear
        self.backgroundColor = .white
        
        self.addSubview(titleLabel)
        self.addSubview(stateLabel)
        self.addSubview(creatorLabel)
        self.addSubview(timeLabel)
        
        self.stateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.stateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8).isActive = true
        self.stateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        self.stateLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        
        self.titleLabel.numberOfLines = 1
        self.titleLabel.lineBreakMode = .byTruncatingTail
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.leftAnchor.constraint(equalTo: stateLabel.rightAnchor, constant: 8).isActive = true
        self.titleLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: 8).isActive = true
        self.titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true

        self.creatorLabel.translatesAutoresizingMaskIntoConstraints = false
        self.creatorLabel.setContentHuggingPriority(UILayoutPriority(rawValue: 1000), for: .horizontal)
        self.creatorLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -8).isActive = true
        self.creatorLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        
        self.timeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.timeLabel.rightAnchor.constraint(equalTo: creatorLabel.leftAnchor, constant: -16).isActive = true
        self.timeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
    }
}
