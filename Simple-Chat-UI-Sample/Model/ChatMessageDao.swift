//
//  ChatMessageDao.swift
//  Simple-Chat-UI-Sample
//
//  Created by kawaharadai on 2018/08/12.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import CoreData
import UIKit

final class ChatMessageDao {
    
    /// 新規メッセージを保存する
    ///
    /// - Parameters:
    ///   - entityName: entity名
    ///   - mid: entiytのユニークなID
    ///   - message: 保存するメッセージ
    ///   - time: 保存時間
    ///   - day: 保存日
    static func save(entityName: String, mid: Int, message: String, time: Date, day: Date) {
        guard mid > 0 else {
            // midの新規作成に失敗(createNewId())
            return
        }
        let managedContext =  AppContext.shared.persistentContainer().viewContext
        guard let entity = NSEntityDescription.entity(forEntityName: entityName, in: managedContext) else {
            print("NSEntityDescription is nil")
            return
        }
        let managerObject = NSManagedObject(entity: entity,
                                            insertInto: managedContext)
        managerObject.setValue(mid, forKeyPath: AppContext.shared.mid)
        managerObject.setValue(message, forKeyPath: AppContext.shared.message)
        managerObject.setValue(time, forKeyPath: AppContext.shared.time)
        managerObject.setValue(day.stringDate(format: "yyyy-MM-dd"), forKeyPath: AppContext.shared.day)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
    /// オブジェクトに対して任意のuniqueIDを発行する
    ///
    /// - Parameters:
    ///   - entityName: entity名
    ///   - idName: idの種類
    /// - Returns: 任意のuniqueID
    static func createNewId(entityName: String, idName: String) -> Int {
        let managedContext = AppContext.shared.persistentContainer().viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            let fetchedArray = try managedContext.fetch(fetchRequest)
            guard !fetchedArray.isEmpty else { return 1 }
            let ids = fetchedArray.compactMap {
                $0.value(forKey: idName) as? Int
            }
            guard !ids.isEmpty, let maxId = ids.max() else { return 1 }
            return maxId + 1
        } catch {
            return 0
        }
    }
    
    /// 特定のentity情報をfetchしてNSFetchedResultsControllerとして返す(オブジェクトの配列を持っている)（セクション表示を簡単にするために必要）
    ///
    /// - Parameters:
    ///   - entityName: entity名
    ///   - sortSectionKey: section群をどのキーでソートするか
    ///   - sortObjectKey: object群をどのキーでソートするか
    /// - Returns: fetch結果を持ったNSFetchedResultsController
    static func createFetchedResultsController(entityName: String,
                                               sortSectionKey: String,
                                               sortObjectKey: String) -> NSFetchedResultsController<NSFetchRequestResult> {
        // NSFetchedResultsControllerの生成
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let managedContext =  AppContext.shared.persistentContainer().viewContext
        // entityをインスタンス化
        let entity = NSEntityDescription.entity(forEntityName: AppContext.shared.chatMessage, in: managedContext)
        fetchRequest.entity = entity
        //ソートキーの指定。セクションが存在する場合セクションに対応した属性を最初に指定する
        /// ascendind: true 昇順、false 降順
        let daySortDescriptor = NSSortDescriptor(key: sortSectionKey, ascending: true)
        let timeSortDescriptor = NSSortDescriptor(key: sortObjectKey, ascending: true)
        fetchRequest.sortDescriptors = [daySortDescriptor, timeSortDescriptor]
        
        //セクションとして"day"を指定
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: managedContext,
                                                                  sectionNameKeyPath: AppContext.shared.day,
                                                                  cacheName: AppContext.shared.message)
        // デリゲートでDB操作を監視できる
        //        fetchedResultsController = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            abort()
        }
        return fetchedResultsController
    }
    
}
