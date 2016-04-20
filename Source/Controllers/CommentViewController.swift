//
//  CommentViewController.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/30/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit

class CommentViewController: UITableViewController {
  var comments: [Comment]!

  override func viewDidLoad() {
    super.viewDidLoad()

    // We must set these properties in this method in order for automatic cell
    // sizing to work.
    tableView.estimatedRowHeight = 64.0
    tableView.rowHeight = UITableViewAutomaticDimension

  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    transitionCoordinator()?.animateAlongsideTransition(
      { [unowned self] (context: UIViewControllerTransitionCoordinatorContext) in
        let navBar = self.navigationController!.navigationBar

        navBar.tintColor = UIColor.whiteColor()
        navBar.barTintColor = ColorPalette.Blue
        navBar.topItem?.title = ""

      },
      completion: nil
    )
  }

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return comments.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCellWithIdentifier("comment") as? CommentCellController else {

      assertionFailure("Could not dequeue cell.")
      return UITableViewCell()
    }

    cell.comment = comments[indexPath.row]

    return cell
  }

}
