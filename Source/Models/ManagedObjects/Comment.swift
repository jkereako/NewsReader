//
//  Comment.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/28/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//


import CoreData

final class Comment: NSManagedObject {
  static let entityName = "Comment"

  init(context: NSManagedObjectContext, decodedComment: DecodedComment, article: Article) {
    let entity = NSEntityDescription.entityForName(
      Comment.entityName, inManagedObjectContext: context
      )!

    super.init(entity: entity, insertIntoManagedObjectContext: context)

    authorName = decodedComment.authorName

    // REVIEW: Find another place to put this.
    authorLocation = decodedComment.authorLocation.stringByReplacingOccurrencesOfString(
      "<br/>", withString: ""
    )
    content = decodedComment.content.stringByReplacingOccurrencesOfString(
      "<br/>", withString: "\n"
    )

    publishDate = decodedComment.publishDate
    self.article = article
  }

  @objc
  private override init(
    entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {

    super.init(entity: entity, insertIntoManagedObjectContext: context)
  }
}

extension Comment {
  @NSManaged var authorName: String
  @NSManaged var authorLocation: String?
  @NSManaged var publishDate: NSDate
  @NSManaged var content: String
  @NSManaged var article: Article
}
