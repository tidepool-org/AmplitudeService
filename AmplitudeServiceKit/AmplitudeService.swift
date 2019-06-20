//
//  AmplitudeService.swift
//  AmplitudeServiceKit
//
//  Created by Darin Krauss on 6/20/19.
//  Copyright © 2019 LoopKit Authors. All rights reserved.
//

import Amplitude
import LoopKit


public final class AmplitudeService: Service {

    public static let managerIdentifier = "AmplitudeService"

    public static let localizedTitle = LocalizedString("Amplitude", comment: "The title of the Amplitude service")

    public var delegateQueue: DispatchQueue! {
        get {
            return delegate.queue
        }
        set {
            delegate.queue = newValue
        }
    }

    public weak var serviceDelegate: ServiceDelegate? {
        get {
            return delegate.delegate
        }
        set {
            delegate.delegate = newValue
        }
    }

    private let delegate = WeakSynchronizedDelegate<ServiceDelegate>()

    public var apiKey: String?

    private var client: Amplitude?

    public init() {
        self.apiKey = try? KeychainManager().getAmplitudeAPIKey()
        createClient()
    }

    public convenience init?(rawState: RawStateValue) {
        self.init()
    }

    public var rawState: RawStateValue {
        return [:]
    }

    public var isComplete: Bool { return apiKey?.isEmpty == false }

    public func notifyCreated(completion: @escaping () -> Void) {
        try! KeychainManager().setAmplitudeAPIKey(apiKey)
        createClient()
        notifyDelegateOfCreation(completion: completion)
    }

    public func notifyUpdated(completion: @escaping () -> Void) {
        try! KeychainManager().setAmplitudeAPIKey(apiKey)
        createClient()
        notifyDelegateOfUpdation(completion: completion)
    }

    public func notifyDeleted(completion: @escaping () -> Void) {
        try! KeychainManager().setAmplitudeAPIKey()
        notifyDelegateOfDeletion(completion: completion)
    }

    private func createClient() {
        if let apiKey = apiKey {
            let amplitude = Amplitude()
            amplitude.disableIdfaTracking()
            amplitude.disableLocationListening()
            amplitude.initializeApiKey(apiKey)
            client = amplitude
        } else {
            client = nil
        }
    }

}

extension AmplitudeService {

    public var debugDescription: String {
        return """
        ## AmplitudeService
        """
    }

}


extension AmplitudeService: Analytics {

    // MARK: - UIApplicationDelegate

    public func application(didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) {
        logEvent("App Launch")
    }

    // MARK: - Screens

    public func didDisplayBolusScreen() {
        logEvent("Bolus Screen")
    }

    public func didDisplaySettingsScreen() {
        logEvent("Settings Screen")
    }

    public func didDisplayStatusScreen() {
        logEvent("Status Screen")
    }

    // MARK: - Config Events

    public func transmitterTimeDidDrift(_ drift: TimeInterval) {
        logEvent("Transmitter time change", withProperties: ["value" : drift], outOfSession: true)
    }

    public func pumpTimeDidDrift(_ drift: TimeInterval) {
        logEvent("Pump time change", withProperties: ["value": drift], outOfSession: true)
    }

    public func pumpTimeZoneDidChange() {
        logEvent("Pump time zone change", outOfSession: true)
    }

    public func pumpBatteryWasReplaced() {
        logEvent("Pump battery replacement", outOfSession: true)
    }

    public func reservoirWasRewound() {
        logEvent("Pump reservoir rewind", outOfSession: true)
    }

    public func didChangeBasalRateSchedule() {
        logEvent("Basal rate change")
    }

    public func didChangeCarbRatioSchedule() {
        logEvent("Carb ratio change")
    }

    public func didChangeInsulinModel() {
        logEvent("Insulin model change")
    }

    public func didChangeInsulinSensitivitySchedule() {
        logEvent("Insulin sensitivity change")
    }

    public func didChangeLoopSettings(from oldValue: LoopSettings, to newValue: LoopSettings) {
        if newValue.maximumBasalRatePerHour != oldValue.maximumBasalRatePerHour {
            logEvent("Maximum basal rate change")
        }

        if newValue.maximumBolus != oldValue.maximumBolus {
            logEvent("Maximum bolus change")
        }

        if newValue.suspendThreshold != oldValue.suspendThreshold {
            logEvent("Minimum BG Guard change")
        }

        if newValue.dosingEnabled != oldValue.dosingEnabled {
            logEvent("Closed loop enabled change")
        }

        if newValue.retrospectiveCorrectionEnabled != oldValue.retrospectiveCorrectionEnabled {
            logEvent("Retrospective correction enabled change")
        }

        if newValue.glucoseTargetRangeSchedule != oldValue.glucoseTargetRangeSchedule {
            if newValue.glucoseTargetRangeSchedule?.timeZone != oldValue.glucoseTargetRangeSchedule?.timeZone {
                self.pumpTimeZoneDidChange()
            } else if newValue.glucoseTargetRangeSchedule?.override != oldValue.glucoseTargetRangeSchedule?.override {
                logEvent("Glucose target range override change", outOfSession: true)
            } else {
                logEvent("Glucose target range change")
            }
        }
    }

    // MARK: - Loop Events

    public func didAddCarbsFromWatch() {
        logEvent("Carb entry created", withProperties: ["source" : "Watch"], outOfSession: true)
    }

    public func didRetryBolus() {
        logEvent("Bolus Retry", outOfSession: true)
    }

    public func didSetBolusFromWatch(_ units: Double) {
        logEvent("Bolus set", withProperties: ["source" : "Watch"], outOfSession: true)
    }

    public func didFetchNewCGMData() {
        logEvent("CGM Fetch", outOfSession: true)
    }

    public func loopDidSucceed() {
        logEvent("Loop success", outOfSession: true)
    }

    public func loopDidError() {
        logEvent("Loop error", outOfSession: true)
    }

    private func logEvent(_ name: String, withProperties properties: [AnyHashable: Any]? = nil, outOfSession: Bool = false) {
        client?.logEvent(name, withEventProperties: properties, outOfSession: outOfSession)
    }

}


extension KeychainManager {

    func setAmplitudeAPIKey(_ amplitudeAPIKey: String? = nil) throws {
        try replaceGenericPassword(amplitudeAPIKey, forService: AmplitudeAPIKeyService)
    }

    func getAmplitudeAPIKey() throws -> String {
        return try getGenericPasswordForService(AmplitudeAPIKeyService)
    }

}

fileprivate let AmplitudeAPIKeyService = "AmplitudeAPIKey"
