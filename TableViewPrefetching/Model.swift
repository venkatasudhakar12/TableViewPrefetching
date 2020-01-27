//
//  Model.swift
//  TableViewPrefetching
//
//  Created by Sudhakar on 27/01/20.
//  Copyright © 2020 Sudhakar. All rights reserved.
//

import Foundation

struct Preview {
    var url:URL?
    let order:Int
    init(url:String?,order:Int) {
        self.url = url?.toUrl
        self.order = order
    }
}

public extension String{
    var toUrl:URL?{
        URL(string: self)
    }
}
