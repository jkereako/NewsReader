//
//  Decoders.swift
//  NewsReader
//
//  Created by Jeff Kereakoglow on 3/30/16.
//  Copyright © 2016 Alexis Digital. All rights reserved.
//

import Foundation
import Argo

extension NSURL: Decodable {
  public typealias DecodedType = NSURL
  
  public static func decode(j: JSON) -> Decoded<NSURL> {
    switch j {
    case .String(let s):
      return NSURL(string: s).map(pure) ?? .typeMismatch("URL", actual: j)
    default:
      return .typeMismatch("URL", actual: j)
    }
  }
}
