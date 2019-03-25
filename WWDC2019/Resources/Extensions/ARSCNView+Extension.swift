//
//  ARSCNView+Extension.swift
//  WWDC2019
//
//  Created by Munir Wanis on 2019-03-23.
//  Copyright © 2019 Wanis Co. All rights reserved.
//

import ARKit

extension ARSCNView {
    public func isDebug(enabled condition: Bool) {
        if condition {
            debugOptions = [
                ARSCNDebugOptions.showFeaturePoints,
                ARSCNDebugOptions.showWorldOrigin
            ]
        } else {
            debugOptions = []
        }
    }
}
