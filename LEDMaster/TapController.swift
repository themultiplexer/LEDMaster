//
//  TapController.swift
//  LEDMaster
//
//  Created by Joshua Rutschmann on 06.07.21.
//

import Foundation
import QuartzCore

class TapController: NSObject, ObservableObject {
  
    @Published var bpm: Int
    var lasttime : Double = 0.0
    var avg : [Double] = []
    
    override init() {
        self.bpm = 0
    }

    func tap(){
        let currenttime : Double = CACurrentMediaTime() * 1000
        let diff = currenttime-lasttime
        if diff > 2000.0 {
            avg.removeAll()
        } else {
            if avg.count > 10 {
                avg.removeFirst()
            }
            avg.append(diff)
            self.bpm = Int(round(60000.0/avg.average))
        }
        self.lasttime = currenttime
    }

}

extension Array where Element: BinaryFloatingPoint {

    /// The average value of all the items in the array
    var average: Double {
        if self.isEmpty {
            return 0.0
        } else {
            let sum = self.reduce(0, +)
            return Double(sum) / Double(self.count)
        }
    }

}
