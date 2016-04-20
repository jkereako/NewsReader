//
//  Helpers.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/30/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit

// http://stackoverflow.com/questions/9577392/uitextfield-subview-of-uitableviewcell-get-indexpath-of-cell/27938042#27938042
func indexPathForCellContainingView(view: UIView, inTableView tableView:UITableView) -> NSIndexPath? {
  let touchPoint = tableView.convertPoint(
    CGPoint(x: CGRectGetMidX(view.bounds), y: CGRectGetMidY(view.bounds)), fromView:view
  )

  return tableView.indexPathForRowAtPoint(touchPoint)
}