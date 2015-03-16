//
//  TableViewDiffCalculator.swift
//  Places
//
//  Created by Jack Flintermann on 3/13/15.
//  Copyright (c) 2015 Places. All rights reserved.
//

import UIKit

public class TableViewDiffCalculator: NSObject {
    weak var tableView: UITableView?
    @objc
    public init(tableView: UITableView) {
        self.tableView = tableView
        self.rows = []
        self.insertionAnimation = UITableViewRowAnimation.Automatic
        self.deletionAnimation = UITableViewRowAnimation.Automatic
    }
    public var insertionAnimation, deletionAnimation : UITableViewRowAnimation
    public var rows : Array<NSObject>? = [NSObject]() {
        didSet {
            let oldRows = oldValue? ?? []
            let newRows = self.rows? ?? []
            let changes = LCS(x: oldRows, y: newRows).diff()
            if (changes.count > 0) {
                tableView?.beginUpdates()
                for change in changes {
                    switch(change) {
                    case .Insert(let idx):
                        tableView?.insertRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: insertionAnimation)
                    case .Delete(let idx):
                        tableView?.deleteRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: deletionAnimation)
                    }
                }
                tableView?.endUpdates()

            }
        }
    }
    
}
