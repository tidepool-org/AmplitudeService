//
//  AmplitudeService+UI.swift
//  AmplitudeServiceKitUI
//
//  Created by Darin Krauss on 6/20/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import LoopKit
import LoopKitUI
import AmplitudeServiceKit

extension AmplitudeService: ServiceUI {

    public static func setupViewController() -> (UIViewController & ServiceSetupNotifying & CompletionNotifying)? {
        return ServiceViewController(rootViewController: AmplitudeServiceTableViewController(amplitudeService: AmplitudeService(), for: .create))
    }

    public func settingsViewController() -> (UIViewController & ServiceSetupNotifying & CompletionNotifying) {
      return ServiceViewController(rootViewController: AmplitudeServiceTableViewController(amplitudeService: self, for: .update))
    }

}
