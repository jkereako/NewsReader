//
//  HeadlineCell.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/26/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit

final class HeadlineCellController: UITableViewCell {
  @IBOutlet weak var sectionIcon: UIImageView!
  @IBOutlet weak var title: UILabel!
  @IBOutlet weak var publishDate: UILabel!
  @IBOutlet weak var commentButton: UIButton!

  var article: Article! {
    didSet {
      commentButton.hidden = true
      commentButton.titleLabel?.text = ""

      if let comments = self.article.comments where comments.count > 0 {
        commentButton.titleLabel?.text = String(comments.count)
        commentButton.hidden = false
      }

      if let image = UIImage(named: article!.section) {
        sectionIcon.image = image
      }
      else {
        sectionIcon.image = UIImage(named: "Placeholder")

      }
      title.text = article.title
      publishDate.text = article.publishDate.timeAgo
    }
  }
}
