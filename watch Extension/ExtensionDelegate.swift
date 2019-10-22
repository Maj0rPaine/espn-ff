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
        // TODO: reloadRootControllers
        
        scheduleNextReload()
    }
    
    func applicationWillEnterForeground() {
        NSLog("ExtensionDelegate: applicationWillEnterForeground()")
    }

    func applicationDidBecomeActive() {
        NSLog("ExtensionDelegate: applicationDidBecomeActive()")
    }

    func applicationWillResignActive() {
        NSLog("ExtensionDelegate: applicationWillResignActive()")
    }

    func applicationDidEnterBackground() {
        NSLog("ExtensionDelegate: applicationDidEnterBackground()")
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

extension ExtensionDelegate {
    func scheduleNextReload() {
        // TODO: Check if leagues are saved before scheduling
        
        Networking(url: URL(string: "https://site.api.espn.com")!).getCurrentGameSchedule { schedule in
            /// Only schedule background tasks for games in progress
            if let schedule = schedule, schedule.containsGamesInProgress {
                NSLog("ExtensionDelegate: scheduling next update")
                
                WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date(timeIntervalSinceNow: 300), userInfo: nil, scheduledCompletion: { error in
                       NSLog("ExtensionDelegate: background task %@",
                       error == nil ? "scheduled successfully" : "NOT scheduled: \(error!)")
                })
            }
        }
    }
}
