//
//  ChatBoardViewController.swift
//  Simple-Chat-UI-Sample
//
//  Created by kawaharadai on 2018/08/12.
//  Copyright © 2018年 kawaharadai. All rights reserved.
//

import CoreData
import UIKit

class ChatBoardViewController: UIViewController {
    
    @IBOutlet weak var chatBoardTableView: UITableView!
    @IBOutlet weak var inputMessageTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputAreaView: UIView!
    @IBOutlet weak var constraintTextViewHeight: NSLayoutConstraint!
    private let datasource = ChatBoardDatasource()
    private let maxInputTextSize: CGFloat = 100
    private let inputTextInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getDatasource()
        self.registKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Action
    @IBAction func send(_ sender: UIButton) {
        ChatMessageDao.save(entityName: AppContext.shared.chatMessage,
                            mid: ChatMessageDao.createNewId(entityName: AppContext.shared.chatMessage,
                                                            idName: AppContext.shared.mid),
                            message: self.inputMessageTextView.text ?? "",
                            time: Date(),
                            day: Date())
        self.cleanTextView()
        self.getDatasource()
    }
    
    @IBAction func background(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    // MARK: - Private
    private func setup() {
        self.chatBoardTableView.delegate = self
        self.chatBoardTableView.dataSource = self.datasource
        self.chatBoardTableView.register(UINib(nibName: ChatMessageCell.identifier, bundle: nil),
                                         forCellReuseIdentifier: ChatMessageCell.identifier)
        self.setupTextView()
    }
    
    /// 送信ボタンが押下されたあとに、キーボードを初期状態に戻す処理
    private func cleanTextView() {
        inputMessageTextView.text = ""
        sendButton.isEnabled = false
        // テキストが入っていない状態のサイズを取得し、サイズを戻す
        let size = inputMessageTextView.sizeThatFits(inputMessageTextView.frame.size)
        constraintTextViewHeight.constant = size.height
        inputMessageTextView.resignFirstResponder()
    }
    
    private func setupTextView() {
        self.inputMessageTextView.delegate = self
        // 入力欄のinsetを調整
        self.inputMessageTextView.textContainerInset = inputTextInset
    }
    
    /// DBからデータを取得
    private func getDatasource() {
        self.datasource.nsFetchedResultsController =
            ChatMessageDao.createFetchedResultsController(entityName: AppContext.shared.chatMessage,
                                                          sortSectionKey: AppContext.shared.day,
                                                          sortObjectKey: AppContext.shared.time)
        self.chatBoardTableView.reloadData()
        self.scrollToNewMessage()
    }
    
    /// 最新のメッセージまでスクロール移動する
    private func scrollToNewMessage() {
        DispatchQueue.main.async { [weak self] in
            guard let section = self?.chatBoardTableView.numberOfSections,
                section > 0 else { return }
            guard let row = self?.chatBoardTableView.numberOfRows(inSection: section - 1), row > 0 else { return }
            let indexPath = IndexPath(row: row - 1 , section: section - 1)
            self?.chatBoardTableView.scrollToRow(at: indexPath,
                                                 at: .bottom,
                                                 animated: false)
        }
    }
    
    /// キーボードの出し入れのタイミングの通知を登録
    private func registKeyboardNotification() {
        let notification = NotificationCenter.default
        notification.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        notification.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    /// キーボードが表示されたときの処理
    ///
    /// - Parameter notification: 通知情報
    @objc func keyboardWillShow(notification: Notification) {
        let rect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        UIView.animate(withDuration: duration!,
                       animations: { [weak self] () in
                        let transform = CGAffineTransform(translationX: 0,
                                                          y: -(rect?.size.height)!)
                        self?.view.transform = transform
        })
    }
    
    /// キーボードが非表示されたときの処理
    ///
    /// - Parameter notification: 通知情報
    @objc func keyboardWillHide(notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Double
        UIView.animate(withDuration: duration!,
                       animations: { [weak self] () in
                        self?.view.transform = CGAffineTransform.identity
        })
    }
    
}

// MARK: - UITableViewDelegate
extension ChatBoardViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? ChatMessageCell {
            // 角丸処理
            cell.messageBackgroundView?.layer.cornerRadius = 10
            cell.messageBackgroundView?.layer.masksToBounds = true
        }
    }
    
}

// MARK: - UITextViewDelegate
extension ChatBoardViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        // 入力欄に文字が入っていないときは送信ボタンを押せなくする
        sendButton.isEnabled = textView.text.count > 0
        
        // 10ptを最大値として入力欄を拡張する
        let textViewHeight = textView.sizeThatFits(inputMessageTextView.frame.size).height
        if textViewHeight < maxInputTextSize {
            constraintTextViewHeight.constant = textViewHeight
        }
        
    }
    
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        // テキストを一番下まで表示する
        inputMessageTextView.scrollRangeToVisible(inputMessageTextView.selectedRange)
        return true
    }
    
}
