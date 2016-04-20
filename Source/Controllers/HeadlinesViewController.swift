//
//  HeadlinesViewController.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit
import CoreData

final class HeadlinesViewController: UITableViewController, Coordinator {
  var appCoordinator: AppCoordinator?

  private var dataSource: FetchedResultsControllerDataSource?
  private var originalFRC: NSFetchedResultsController!

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if let frc = dataSource {
      frc.resume()
    }

    let navBar = self.navigationController!.navigationBar

    navBar.topItem?.title = "Top Stories"
  }

  override func viewWillDisappear(animated: Bool) {
    dataSource?.pause()

    super.viewWillDisappear(animated)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

    if segue.identifier == "showArticle", let cell = sender as? HeadlineCellController {

      guard let indexPath = tableView.indexPathForCell(cell),
        let article = dataSource?.objectAtIndexPath(indexPath) as? Article,
        let toVC = segue.destinationViewController as?
        ArticleController else {

          assertionFailure("Unexpected behavior.")
          return
      }

      toVC.appCoordinator = appCoordinator
      toVC.article = article
    }

    else if segue.identifier == "showComments", let button = sender as? UIButton {

      guard let indexPath = indexPathForCellContainingView(button, inTableView: tableView),
        let article = dataSource?.objectAtIndexPath(indexPath) as? Article,
        let toVC = segue.destinationViewController as? CommentViewController else {
          assertionFailure("Unexpected behavior.")
          return
      }

      toVC.comments = article.comments?.allObjects as? [Comment]

    }
  }
}

extension HeadlinesViewController {
  @IBAction func refreshAction(sender: UIRefreshControl) {
    appCoordinator?.start()
  }
}

extension HeadlinesViewController: AsyncOperationDelegate {
  func coreDataStackDidFinish(context context: NSManagedObjectContext) {
    // TODO: Check the managed object context for nil
    let request = NSFetchRequest(entityName: Article.entityName)
    request.sortDescriptors = [NSSortDescriptor(key: "publishDate", ascending: false)]
    // request.predicate = NSPredicate(format: "publishDate >= %@", NSDate())

    originalFRC = NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: nil,
      cacheName: nil)

    dataSource = FetchedResultsControllerDataSource(
      tableView: tableView,
      reuseIdentifier: "headline",
      allowEditing: false,
      frc: originalFRC!,
      delegate: self
    )

    dataSource?.resume()
  }

  func contextDidSave(context context: NSManagedObjectContext) {
    refreshControl?.endRefreshing()
  }
}

extension HeadlinesViewController: FetchedResultsControllerDataSourceDelegate {
  func configure(cell cell: AnyObject, object: AnyObject) {

    guard let theCell = cell as? HeadlineCellController, let article = object as? Article else {
      return
    }

    theCell.article = article
  }

  func delete(object object: AnyObject) {
  }
}


extension HeadlinesViewController: UISearchBarDelegate {
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    guard let searchTerm = searchBar.text else {
      assertionFailure("Expected a search text to have a value.")
      return
    }

    if searchTerm.characters.count > 0 {
      let request = NSFetchRequest(entityName: Article.entityName)
      // Sort by title
      request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
      request.predicate = NSPredicate(format: "title CONTAINS [cd] %@", searchTerm)

      let frc = NSFetchedResultsController(
        fetchRequest: request,
        managedObjectContext: appCoordinator!.coreDataStack!.mainContext,
        sectionNameKeyPath: nil,
        cacheName: nil)

      dataSource?.frc = frc
    }

    else {
      dataSource?.frc = originalFRC
    }

    dataSource?.resume()
  }

  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()

    // Dismiss the search bar from the parent view
    NSNotificationCenter.defaultCenter().postNotificationName(
      dismissSearchBarNotification, object: nil
    )
  }

  func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
    return true
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    tableView.reloadData()
  }
}
