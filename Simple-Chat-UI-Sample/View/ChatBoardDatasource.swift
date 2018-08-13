//
//  ChatBoardDatasource.swift
//  Simple-Chat-UI-Sample
//
//  Created by kawaharadai on 2018/08/12.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import CoreData
import UIKit

class ChatBoardDatasource: NSObject {
    var messages = [ChatMessage]()
    var nsFetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>? = nil
}

extension ChatBoardDatasource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.nsFetchedResultsController?.sections?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let sections = self.nsFetchedResultsController?.sections else { return nil }
        return sections[section].name
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = self.nsFetchedResultsController?.sections else { return 0 }
        return sections[section].numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier,
                                                       for: indexPath) as? ChatMessageCell else {
            fatalError("cell is nil")
    }
        guard let object = self.nsFetchedResultsController?.object(at: indexPath),
            let chatMessage = object as? ChatMessage else {
            fatalError("object is nil")
        }
        cell.setCellData(object: chatMessage)
        return cell
    }
    
}
