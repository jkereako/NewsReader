//
//  CommentCellController.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/30/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit

class CommentCellController: UITableViewCell {
  @IBOutlet weak var authorName: UILabel!
  @IBOutlet weak var authorLocation: UILabel!
  @IBOutlet weak var commentContent: UILabel!
  @IBOutlet weak var publishDate: UILabel!

  var comment: Comment! {
    didSet {
      authorName.text = comment.authorName
      authorLocation.text = comment.authorLocation
      commentContent.text = comment.content
      publishDate.text = comment.publishDate.timeAgo
    }
  }
}
