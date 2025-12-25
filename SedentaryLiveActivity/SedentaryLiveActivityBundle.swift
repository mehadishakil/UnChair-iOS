//
//  SedentaryLiveActivityBundle.swift
//  SedentaryLiveActivity
//
//  Created by Mehadi Hasan on 25/12/25.
//

import WidgetKit
import SwiftUI

@main
struct SedentaryLiveActivityBundle: WidgetBundle {
    var body: some Widget {
        SedentaryLiveActivity()
        if #available(iOS 18.0, *) {
            SedentaryLiveActivityControl()
        }
        SedentaryLiveActivityLiveActivity()
    }
}
