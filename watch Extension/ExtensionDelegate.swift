//
//  ExtensionDelegate.swift
//  watch Extension
//
//  Created by Chris Paine on 10/3/19.
//  Copyright © 2019 Chris Paine. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        DataController.shared.load()
        scheduleNextReload()
    }
    
    func applicationWillEnterForeground() {
        NSLog("ExtensionDelegate: applicationWillEnterForeground()")
    }

    func applicationDidBecomeActive() {
        NSLog("ExtensionDelegate: applicationDidBecomeActive()")
        Networking().refreshMatchup()
    }

    func applicationWillResignActive() {
        NSLog("ExtensionDelegate: applicationWillResignActive()")
    }

    func applicationDidEnterBackground() {
        NSLog("ExtensionDelegate: applicationDidEnterBackground()")
    }
    
    func nextReloadTime(after date: Date) -> Date {
        let calendar = Calendar(identifier: .gregorian)
        let targetMinutes = DateComponents(minute: 15)
     
        var nextReloadTime = calendar.nextDate(
            after: date,
            matching: targetMinutes,
            matchingPolicy: .nextTime
        )!
     
        // if it's in less than 5 minutes, then skip this one and try next hour
        if nextReloadTime.timeIntervalSince(date) < 5 * 60 {
            nextReloadTime.addTimeInterval(3600)
        }
     
        return nextReloadTime
    }
    
    func scheduleNextReload() {
        let targetDate = nextReloadTime(after: Date())
     
        NSLog("ExtensionDelegate: scheduling next update at %@", "\(targetDate)")
     
        WKExtension.shared().scheduleBackgroundRefresh(
            withPreferredDate: Date(timeIntervalSinceNow: 10.0),
            userInfo: nil,
            scheduledCompletion: { error in
                NSLog("ExtensionDelegate: background task %@",
                error == nil ? "scheduled successfully" : "NOT scheduled: \(error!)")
            }
        )
    }

    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            switch task {
            case let backgroundTask as WKApplicationRefreshBackgroundTask:
                NSLog("ExtensionDelegate: handling WKApplicationRefreshBackgroundTask")
                
                scheduleNextReload()
                
                Networking().refreshMatchup {
                    NSLog("ExtensionDelegate: completed WKApplicationRefreshBackgroundTask")
                    backgroundTask.setTaskCompletedWithSnapshot(false)
                }
            default:
                task.setTaskCompletedWithSnapshot(false)
            }
        }
    }

}
