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
import HealthKit

extension AmplitudeService: ServiceUI {
    
    public static var image: UIImage? {
        UIImage(named: "amplitude_logo", in: Bundle(for: AmplitudeServiceTableViewController.self), compatibleWith: nil)!
    }

    public static func setupViewController(colorPalette: LoopUIColorPalette) -> SetupUIResult<UIViewController & ServiceCreateNotifying & ServiceOnboardNotifying & CompletionNotifying, ServiceUI>
    {
        return .userInteractionRequired(ServiceViewController(rootViewController: AmplitudeServiceTableViewController(service: AmplitudeService(), for: .create)))
    }
    
    public func settingsViewController(colorPalette: LoopUIColorPalette) -> (UIViewController & ServiceOnboardNotifying & CompletionNotifying)
    {
        return ServiceViewController(rootViewController: AmplitudeServiceTableViewController(service: self, for: .update))
    }
    
    public func supportMenuItem(supportInfoProvider: SupportInfoProvider, urlHandler: @escaping (URL) -> Void) -> AnyView? {
        return nil
    }
}
