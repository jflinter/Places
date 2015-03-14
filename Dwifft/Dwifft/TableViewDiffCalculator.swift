//
//  TableViewDiffCalculator.swift
//  Places
//
//  Created by Jack Flintermann on 3/13/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

import UIKit

public class TableViewDiffCalculator: NSObject {
    let tableView: UITableView
    @objc
    public init(tableView: UITableView) {
        self.tableView = tableView
        self.rows = []
        self.insertionAnimation = UITableViewRowAnimation.Automatic
        self.deletionAnimation = UITableViewRowAnimation.Automatic
    }
    public var insertionAnimation, deletionAnimation : UITableViewRowAnimation
    public var rows : Array<NSObject> = [NSObject]() {
        didSet {
            tableView.beginUpdates()
            for change in LCS(x: oldValue, y: self.rows).diff() {
                switch(change) {
                case .Insert(let idx):
                    tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: insertionAnimation)
                case .Delete(let idx):
                    tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: deletionAnimation)
                }
            }
            tableView.endUpdates()
        }
    }
    
}
