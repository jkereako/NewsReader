//
//  ArticleContentCellController.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/27/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import UIKit

final class ArticleContentCellController: UITableViewCell {
  @IBOutlet weak var publishDate: UILabel!
  @IBOutlet weak var byline: UILabel!
  @IBOutlet weak var articleContent: UILabel!

  private static var dateFormatter: NSDateFormatter!
  
  override func awakeFromNib() {
    guard let localeIdentifier = NSBundle.mainBundle().preferredLocalizations.first else {
      // This will almost never be triggered.
      fatalError("\n\n  Unable to fetch locale identifier.\n\n")
    }

    let locale = NSLocale(localeIdentifier: localeIdentifier)
    ArticleContentCellController.dateFormatter = NSDateFormatter()
    ArticleContentCellController.dateFormatter.locale = locale
    ArticleContentCellController.dateFormatter.dateStyle = .LongStyle
    ArticleContentCellController.dateFormatter.timeStyle = .LongStyle
  }

  var article: Article! {
    didSet {
      publishDate.text = ArticleContentCellController.dateFormatter.stringFromDate(
        self.article!.publishDate
      )

      byline.text = self.article.byline
      articleContent.text = self.article.content!
    }
  }
}