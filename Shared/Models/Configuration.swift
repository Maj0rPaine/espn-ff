//
//  Configuration.swift
//  espn-ff
//
//  Created by Chris Paine on 10/6/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import Foundation

struct Configuration: Codable {
    var cookies: [Cookie]
    var leagues: [League]
}
