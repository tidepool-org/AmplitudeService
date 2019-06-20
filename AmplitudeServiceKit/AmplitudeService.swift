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

    public var hasValidConfiguration: Bool { return apiKey?.isEmpty == false }

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

    public func recordAnalyticsEvent(_ name: String, withProperties properties: [AnyHashable: Any]?, outOfSession: Bool) {
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
