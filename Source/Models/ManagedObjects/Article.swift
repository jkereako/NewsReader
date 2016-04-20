//
//  Article+CoreDataProperties.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import CoreData

final class Article: NSManagedObject {
  static let entityName = "Article"

  init(context: NSManagedObjectContext, decodedArticle: DecodedArticle) {
    let entity = NSEntityDescription.entityForName(
      Article.entityName, inManagedObjectContext: context
      )!

    super.init(entity: entity, insertIntoManagedObjectContext: context)

    title = decodedArticle.title
    publishDate = decodedArticle.publishDate
    byline = decodedArticle.byline
    section = decodedArticle.section.rawValue
    url = decodedArticle.url.absoluteString
  }

  @objc
  private override init(
    entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {

    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }
}

extension Article {
  @NSManaged var byline: String
  @NSManaged var content: String?
  @NSManaged var title: String
  @NSManaged var publishDate: NSDate
  @NSManaged var section: String
  @NSManaged var url: String
  @NSManaged var comments: NSSet?
}
