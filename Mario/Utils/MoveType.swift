//
//  MoveType.swift
//  Mario
//
//  Created by Jan Sebastian on 07/06/24.
//

import Foundation


indirect enum MoveType {
    case Left
    case Right
    case Jump
    case JumpMove(dir: MoveType)
    case Idle
    case Fall
    case FallMove(dir: MoveType)
}
