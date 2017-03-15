//
//  StatsGraphView.swift
//  CS 193P Final Project
//
//  Created by Christopher Ponce de Leon on 3/14/17.
//  Copyright © 2017 Stanford University. All rights reserved.
//

import UIKit

class StatsGraphView: UIView {

    var songPlayStatistics : SongPlayStatistics? {
        didSet { setNeedsDisplay() }
    }
    
    private var axes = AxesDrawer(color: UIColor.darkGray, contentScaleFactor: CGFloat(1.0))

    override func draw(_ rect : CGRect) {
        contentScaleFactor = 1.0
        let origin = CGPoint(x: bounds.minX, y: bounds.maxY)
        axes.drawAxes(in: rect, origin: origin, pointsPerUnit: contentScaleFactor)
    }

}
