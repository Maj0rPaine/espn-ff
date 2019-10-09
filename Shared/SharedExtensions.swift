//
//  Extensions.swift
//  espn-ff
//
//  Created by Chris Paine on 10/8/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import UIKit

extension UIImage {
    static func load(from url: String?) -> UIImage? {
        guard let urlString = url,
            let url = URL(string: urlString),
            let imageData = try? Data(contentsOf: url),
            let image = UIImage(data: imageData) else { return nil }
        return image
    }
}
