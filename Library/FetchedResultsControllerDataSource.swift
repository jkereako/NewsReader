//
//  FetchedResultsControllerDataSource.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit
import CoreData

final class FetchedResultsControllerDataSource: NSObject {
  var frc: NSFetchedResultsController
  let tableView: UITableView
  let reuseIdentifier: String
  let allowEditing: Bool
  let delegate: FetchedResultsControllerDataSourceDelegate

  init(tableView: UITableView, reuseIdentifier: String, allowEditing: Bool,
       frc: NSFetchedResultsController, delegate: FetchedResultsControllerDataSourceDelegate) {

    self.tableView = tableView
    self.reuseIdentifier = reuseIdentifier
    self.allowEditing = allowEditing
    self.frc = frc
    self.delegate = delegate

    super.init()

    self.frc.delegate = self
    self.tableView.dataSource = self
  }

  func objectAtIndexPath(indexPath: NSIndexPath) -> AnyObject? {
    return frc.objectAtIndexPath(indexPath)
  }

  func resume() {
    do {
      try frc.performFetch()
      tableView.reloadData()
    } catch {
      print(error)
    }
  }

  func pause() {
    frc.delegate = nil
  }
}


// MARK: - UITableViewDataSource
extension FetchedResultsControllerDataSource: UITableViewDataSource {
  //  func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
  //    return delegate.headerTitle(section: section)
  //  }

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    guard frc.sections != nil else {
      return 0
    }

    return frc.sections!.count
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let aSection: NSFetchedResultsSectionInfo

    aSection = (frc.sections?[section])!

    return aSection.numberOfObjects
  }

  func tableView(
    tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

    let object = frc.objectAtIndexPath(indexPath)
    let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath)

    delegate.configure(cell: cell, object: object)

    return cell
  }
}

// MARK: Table view delegate
extension FetchedResultsControllerDataSource: UITableViewDelegate {
  func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    return allowEditing
  }

  func tableView(
    tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle,
    forRowAtIndexPath indexPath: NSIndexPath) {

    if editingStyle == .Delete {
      delegate.delete(
        object: frc.objectAtIndexPath(indexPath)
      )
    }
  }
}

// MARK: Fetched results controller delegate
extension FetchedResultsControllerDataSource: NSFetchedResultsControllerDelegate {
  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject,
                  atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType,
                              newIndexPath: NSIndexPath?) {
    switch type {

    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Automatic)

    case .Update:
      if let cell = tableView.cellForRowAtIndexPath(indexPath!) {
        delegate.configure(cell: cell, object: anObject)
      }

    case .Move:
      tableView.moveRowAtIndexPath(indexPath!, toIndexPath: newIndexPath!)

    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
    }
  }
}

