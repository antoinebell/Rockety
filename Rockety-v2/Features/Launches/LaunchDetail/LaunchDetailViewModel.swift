//
//  LaunchDetailViewModel.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 24.10.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//

import EventKit
import Foundation
import RxCocoa
import RxSwift
import UIKit

protocol LaunchDetailViewModelInputs {
    /// Called when viewDidAppear
    func viewDidAppear()
    
    /// Add event to calendar
    func addEventToCalendar()
}

protocol LaunchDetailViewModelOutputs: ActivityIndicating {
    /// Returns the launch
    var launch: Launch { get }
    
    /// Emits the icon for the calendar button
    var calendarButtonImage: Driver<UIImage?> { get }
    
    /// Emits the isEnabled state for the calendar button
    var calendarButtonIsEnabled: Driver<Bool?> { get }
    
    /// Emits that calendar access is denied or restricted
    var calendarAuthorizationDenied: Signal<Void> { get }
    
    /// Emits that calendar access is not determined
    var calendarAuthorizationNotDetermined: Signal<Void> { get }
    
    /// Emits that calendar event was added
    var eventAdded: Signal<Void> { get }
    
    /// Emits that calendar event addition encountered an error
    var eventAddedError: Signal<Void> { get }
}

protocol LaunchDetailViewModelType {
    var inputs: LaunchDetailViewModelInputs { get }
    var outputs: LaunchDetailViewModelOutputs { get }
}

final class LaunchDetailViewModel: BaseViewModel, LaunchDetailViewModelType, LaunchDetailViewModelInputs, LaunchDetailViewModelOutputs {
    
    var inputs: LaunchDetailViewModelInputs { return self }
    var outputs: LaunchDetailViewModelOutputs { return self }
    
    // MARK: - Inputs
    
    func viewDidAppear() {
        viewDidAppearRelay.accept(())
    }
    
    func addEventToCalendar() {
        let status = EKEventStore.authorizationStatus(for: .event)
        switch status {
        case .authorized:
            let eventStore = EKEventStore()
            let event = EKEvent(eventStore: eventStore)
            event.title = launch.launchTitle
            event.startDate = launch.windowStart
            event.endDate = launch.windowEnd
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
                try eventStore.save(event, span: .thisEvent)
                Defaults.setEventAddedToCalendar(launchId: launch.launchLibraryId ?? 0)
                eventAddedRelay.accept(())
            } catch {
                eventAddedErrorRelay.accept(())
            }
        case .denied, .restricted:
            calendarAuthorizationDeniedRelay.accept(())
        case .notDetermined:
            calendarAuthorizationNotDeterminedRelay.accept(())
        @unknown default:
            return
        }
    }
    
    // MARK: - Outputs
    
    var launch: Launch
    
    var calendarButtonImage: Driver<UIImage?> {
        return calendarButtonImageRelay.asDriver()
    }
    
    var calendarButtonIsEnabled: Driver<Bool?> {
        return calendarButtonIsEnabledRelay.asDriver()
    }
    
    var calendarAuthorizationDenied: Signal<Void> {
        return calendarAuthorizationDeniedRelay.asSignal()
    }
    
    var calendarAuthorizationNotDetermined: Signal<Void> {
        return calendarAuthorizationNotDeterminedRelay.asSignal()
    }
    
    var eventAdded: Signal<Void> {
        return eventAddedRelay.asSignal()
    }
    
    var eventAddedError: Signal<Void> {
        return eventAddedErrorRelay.asSignal()
    }
    
    // MARK: - Private
    
    // - Properties
    
    // - Private relays
    private let eventsRelay = BehaviorRelay<Bool?>(value: nil)
    
    // - Input relays
    private let viewDidAppearRelay = PublishRelay<Void>()
    
    // - Output relays
    private let calendarButtonImageRelay = BehaviorRelay<UIImage?>(value: nil)
    private let calendarButtonIsEnabledRelay = BehaviorRelay<Bool?>(value: nil)
    private let calendarAuthorizationDeniedRelay = PublishRelay<Void>()
    private let calendarAuthorizationNotDeterminedRelay = PublishRelay<Void>()
    private let eventAddedRelay = PublishRelay<Void>()
    private let eventAddedErrorRelay = PublishRelay<Void>()
    
    // MARK: - Init
    init(launch: Launch) {
        self.launch = launch
        
        super.init()
        
        viewDidAppearRelay
            .map { Defaults.getEventAddedToCalendar(launchId: launch.launchLibraryId ?? 0) }
            .bind(to: eventsRelay)
            .disposed(by: disposeBag)
        
        eventAddedRelay
            .map { Defaults.getEventAddedToCalendar(launchId: launch.launchLibraryId ?? 0) }
            .bind(to: eventsRelay)
            .disposed(by: disposeBag)
        
        eventsRelay
            .unwrap()
            .map { value in
                if value {
                    return UIImage(named: "calendar-done")!
                } else {
                    return UIImage(named: "calendar")!
                }
            }
            .bind(to: calendarButtonImageRelay)
            .disposed(by: disposeBag)
        
        eventsRelay
            .unwrap()
            .not()
            .bind(to: calendarButtonIsEnabledRelay)
            .disposed(by: disposeBag)
    }
}
