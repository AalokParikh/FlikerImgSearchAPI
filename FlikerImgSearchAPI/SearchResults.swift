//
//  SearchResults.swift
//  FlikerImgSearchAPI
//
//  Created by Aalok Parikh on 09/08/18.
//  Copyright © 2018 home. All rights reserved.
//

import Foundation

struct SearchResults {
    var searchText : String
    var searchResults : [SearchPhoto]
    var page : Int
    var totalPage : Int
}
