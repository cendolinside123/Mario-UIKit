//
//  RectType.swift
//  Mario
//
//  Created by Jan Sebastian on 10/06/24.
//

import Foundation
import UIKit

enum RectType {
    case Background
    case HardItem
    case SemiHardItem
}

struct RectInfo {
    let rect:  CGRect
    let type: RectType
}
