//
//  HTMLParser.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/27/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Foundation
import Fuzi

struct HTMLParser {
  let xPathQuery: String
  let html: String

  func parse() -> [String]? {
    do {
      var results = [String]()
      let doc = try HTMLDocument(string: html, encoding: NSUTF8StringEncoding)
      doc.root?.childNodes(ofTypes: [.Text])

      for node in doc.xpath(xPathQuery) {
        results.append(node.stringValue)
      }

      return results

    } catch {
      print(error)
    }

    return nil
  }
}
