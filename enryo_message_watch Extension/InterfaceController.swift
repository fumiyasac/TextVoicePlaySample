//
//  InterfaceController.swift
//  enryo_message_watch Extension
//
//  Created by 酒井文也 on 2015/12/26.
//  Copyright © 2015年 just1factory. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {

    //メンバ変数
    var resultList: NSMutableArray = []
    var targetSendMessage: String = ""
    
    //部品の配置
    @IBOutlet var messageResultLabel: WKInterfaceLabel!
    @IBOutlet var messageDetailTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
        
        //初期メッセージ表示
        self.messageResultLabel.setText("既存データを取得中...")
        
        //Interactive Messagingでデータを取得
        if (WCSession.defaultSession().reachable) {
            let message = ["command" : "init"]
            WCSession.defaultSession().sendMessage(message,
                replyHandler: { (reply) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        //成功時のメッセージ
                        self.messageResultLabel.setText("読み上げる言葉を選択")
                        
                        //中のデータを可変配列に変換
                        self.resultList = reply["result"] as! NSMutableArray
                        
                        //テーブルのカウント数
                        self.messageDetailTable.setNumberOfRows(self.resultList.count, withRowType: "TheRow")
                        
                        //テーブルビューの描画実行
                        if self.messageDetailTable.numberOfRows > 0 {
                            
                            for index in 0..<self.messageDetailTable.numberOfRows {
                                
                                //ラベルにテキストを設定する
                                let row = self.messageDetailTable.rowControllerAtIndex(index) as! TableRowController
                                let displayMessage: String = (self.resultList.objectAtIndex(index) as? String)!
                                print("テーブルビュー用のメッセージ：\(displayMessage)")
                                row.messageTableLabel.setText(displayMessage)
                            }
                        }
                        
                    })
                },
                errorHandler: { (error) -> Void in
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        //失敗時のメッセージ
                        self.messageResultLabel.setText("データ取得失敗")
                    })
                }
            )
            
        }
        
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        if table == self.messageDetailTable {
            
            //選択された行のメッセージを抜き出す
            let sendMessage: String = (self.resultList[rowIndex] as? String)!
            
            //送信メッセージをメンバ変数へ格納
            self.targetSendMessage = sendMessage
            
            if (WCSession.defaultSession().reachable) {
                let message = ["command" : self.targetSendMessage]
                WCSession.defaultSession().sendMessage(message,
                    replyHandler: { (reply) -> Void in
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            //App側からのメッセージ
                            print(reply["result"])
                            
                        })
                    },
                    errorHandler: { (error) -> Void in
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            //失敗時のメッセージ
                            print("送信失敗しました")
                        })
                    }
                )
            }
                
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
