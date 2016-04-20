//
//  FetchedResultsDataSourceDelegate.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Foundation

protocol FetchedResultsControllerDataSourceDelegate {
  func configure(cell cell: AnyObject, object: AnyObject)
  func delete(object object: AnyObject)
}
