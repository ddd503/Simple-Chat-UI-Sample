//
//  AppContext.swift
//  Simple-Chat-UI-Sample
//
//  Created by kawaharadai on 2018/08/12.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import CoreData
import Foundation

final class AppContext {
    
    static let shared = AppContext()
    // プロジェクト名
    private let containerName = "Simple_Chat_UI_Sample"
    // entity名
    let chatMessage = "ChatMessage"
    // プロパティ名
    let mid = "mid"
    let message = "message"
    let time = "time"
    let day = "day"
    
    /// Core Data stack
    func persistentContainer() -> NSPersistentContainer {
        let container = NSPersistentContainer(name: self.containerName)
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }
    
    // MARK: - Core Data Saving support
    func saveContext () {
        let context = self.persistentContainer().viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}
