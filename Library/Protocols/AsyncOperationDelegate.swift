//
//  AsyncOperationDelegate.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/29/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Foundation
import CoreData

protocol AsyncOperationDelegate {
  func coreDataStackDidFinish(context context: NSManagedObjectContext)
  func contextDidSave(context context: NSManagedObjectContext)
}
