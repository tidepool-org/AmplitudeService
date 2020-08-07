//
//  AmplitudeService+UI.swift
//  AmplitudeServiceKitUI
//
//  Created by Darin Krauss on 6/20/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import SwiftUI
import LoopKit
import LoopKitUI
import AmplitudeServiceKit

extension AmplitudeService: ServiceUI {

    public static func setupViewController() -> (UIViewController & ServiceSetupNotifying & CompletionNotifying)? {
        return ServiceViewController(rootViewController: AmplitudeServiceTableViewController(service: AmplitudeService(), for: .create))
    }

    public func settingsViewController(chartColors: ChartColorPalette, carbTintColor: Color, glucoseTintColor: Color, guidanceColors: GuidanceColors, insulinTintColor: Color) -> (UIViewController & ServiceSettingsNotifying & CompletionNotifying) {
      return ServiceViewController(rootViewController: AmplitudeServiceTableViewController(service: self, for: .update))
    }

}
