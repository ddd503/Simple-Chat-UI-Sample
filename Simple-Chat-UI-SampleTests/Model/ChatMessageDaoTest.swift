//
//  ChatMessageDaoTest.swift
//  Simple-Chat-UI-SampleTests
//
//  Created by kawaharadai on 2018/08/13.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import CoreData
import XCTest
@testable import Simple_Chat_UI_Sample

class ChatMessageDaoTest: XCTestCase {
    
    override func setUp() {
        self.deleteAll(entityName: AppContext.shared.chatMessage)
    }
    
    override func tearDown() {
        self.deleteAll(entityName: AppContext.shared.chatMessage)
    }
    
    // CoreDataにentityオブジェクトを保存するテスト
    func testSave() {
        ChatMessageDao.save(entityName: AppContext.shared.chatMessage,
                            mid: 1,
                            message: "テストメッセージ",
                            time: "2018/08/10 10:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"),
                            day: "2018/08/10 10:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"))
        let nsFetchedResultsController =
            ChatMessageDao.createFetchedResultsController(entityName: AppContext.shared.chatMessage,
                                                          sortSectionKey: AppContext.shared.day,
                                                          sortObjectKey: AppContext.shared.time)
        let object = nsFetchedResultsController.object(at: IndexPath(row: 0, section: 0)) as! ChatMessage
        XCTAssertEqual(object.mid, 1)
        XCTAssertEqual(object.message, "テストメッセージ")
        XCTAssertEqual(object.day, "2018-08-10")
        XCTAssertEqual(object.time?.stringDate(format: "hh:mm"), "10:00")
    }
    
    // uniqueIDを発行するテスト
    func testCreateNewId() {
        for _ in 0..<3 {
            ChatMessageDao.save(entityName: AppContext.shared.chatMessage,
                                mid: ChatMessageDao.createNewId(entityName: AppContext.shared.chatMessage,
                                                                idName: AppContext.shared.mid),
                                message: "テスト",
                                time: Date(),
                                day: Date())
        }
        let nsFetchedResultsController =
            ChatMessageDao.createFetchedResultsController(entityName: AppContext.shared.chatMessage,
                                                          sortSectionKey: AppContext.shared.day,
                                                          sortObjectKey: AppContext.shared.time)
        var testArray: [Int64] = []
        for i in 0..<3 {
            let chatMessage = nsFetchedResultsController.fetchedObjects![i] as! ChatMessage
            testArray.append(chatMessage.mid)
        }
        XCTAssertEqual(testArray[0], 1)
        XCTAssertEqual(testArray[1], 2)
        XCTAssertEqual(testArray[2], 3)
    }
    
    // DBの情報をチャットボード(tableView)用にセクション毎に保存日時で分類した形で全件取得するテスト
    // セクション、インデックス共に保存時の日付、降順でソートする
    func testCreateFetchedResultsController() {
        ChatMessageDao.save(entityName: AppContext.shared.chatMessage,
                            mid: ChatMessageDao.createNewId(entityName: AppContext.shared.chatMessage,
                                                            idName: AppContext.shared.mid),
                            message: "テスト2-0",
                            time: "2018/08/10 10:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"),
                            day: "2018/08/10 10:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"))
        ChatMessageDao.save(entityName: AppContext.shared.chatMessage,
                            mid: ChatMessageDao.createNewId(entityName: AppContext.shared.chatMessage,
                                                            idName: AppContext.shared.mid),
                            message: "テスト1-0",
                            time: "2018/08/11 12:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"),
                            day: "2018/08/11 12:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"))
        ChatMessageDao.save(entityName: AppContext.shared.chatMessage,
                            mid: ChatMessageDao.createNewId(entityName: AppContext.shared.chatMessage,
                                                            idName: AppContext.shared.mid),
                            message: "テスト0-1",
                            time: "2018/08/12 09:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"),
                            day: "2018/08/12 09:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"))
        ChatMessageDao.save(entityName: AppContext.shared.chatMessage,
                            mid: ChatMessageDao.createNewId(entityName: AppContext.shared.chatMessage,
                                                            idName: AppContext.shared.mid),
                            message: "テスト0-0",
                            time: "2018/08/12 12:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"),
                            day: "2018/08/12 12:00".strToDate(dateFormat: "yyyy/MM/dd hh:mm"))
        
        let nsFetchedResultsController =
            ChatMessageDao.createFetchedResultsController(entityName: AppContext.shared.chatMessage,
                                                          sortSectionKey: AppContext.shared.day,
                                                          sortObjectKey: AppContext.shared.time)
        XCTAssertEqual(nsFetchedResultsController.sections![0].name, "2018-08-10")
        XCTAssertEqual(nsFetchedResultsController.sections![1].name, "2018-08-11")
        XCTAssertEqual(nsFetchedResultsController.sections![2].name, "2018-08-12")
        XCTAssertEqual(nsFetchedResultsController.sections![0].numberOfObjects, 1)
        XCTAssertEqual(nsFetchedResultsController.sections![1].numberOfObjects, 1)
        XCTAssertEqual(nsFetchedResultsController.sections![2].numberOfObjects, 2)
    }
    
    /// 指定したEntityを全件削除（UT用）
    ///
    /// - Parameter entityName: entity名
    func deleteAll(entityName: String) {
        let managedContext =  AppContext.shared.persistentContainer().viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try managedContext.execute(deleteRequest)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    
}

// UT用にStringを拡張
private extension String {
    
    func strToDate(dateFormat: String) -> Date  {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale?
        dateFormatter.timeStyle = .short
        dateFormatter.dateStyle = .short
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.date(from: self)!
    }
    
}

