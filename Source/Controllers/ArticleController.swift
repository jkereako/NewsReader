//
//  ArticleController.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/27/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit

class ArticleController: UITableViewController, Coordinator {
  @IBOutlet weak var articleTitle: UILabel!

  var appCoordinator: AppCoordinator?
  var article: Article!
  var content: String! {
    didSet {
      self.article.content = self.content
      tableView.reloadRowsAtIndexPaths(
        [NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Bottom
      )
    }
  }

  var contentFrame: CGRect? {
    didSet {
      tableView.reloadRowsAtIndexPaths(
        [NSIndexPath(forItem: 0, inSection: 0)], withRowAnimation: .Bottom
      )
    }
  }

  private var coordinator: ArticleCoordinator!

  override func viewDidLoad() {
    super.viewDidLoad()

    articleTitle.text = article.title

    // We must set these properties in this method in order for automatic cell
    // sizing to work.
    tableView.estimatedRowHeight = 64.0
    tableView.rowHeight = UITableViewAutomaticDimension

    // If the content doesn't exist, download it.
    if article.content == nil {
      coordinator = ArticleCoordinator(viewController: self, article: article,
                                       context:appCoordinator!.coreDataStack!.mainContext
      )
      coordinator.fetchArticle()
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    transitionCoordinator()?.animateAlongsideTransition(
      { [unowned self] (context: UIViewControllerTransitionCoordinatorContext) in
        let navBar = self.navigationController!.navigationBar

        navBar.setBackgroundImage(
          UIImage(named: self.article.section), forBarMetrics: .Default
        )
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
    return 1
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("content", forIndexPath: indexPath)

    guard let contentCell = cell as? ArticleContentCellController else {
      assertionFailure("Expected an article cell.")
      return UITableViewCell()
    }

    // Only set the content cell if all the data is there.
    guard article.content != nil else{
      return contentCell
    }

    contentCell.article = article

    return contentCell
  }
}
