//
//  VoiceHistory.swift
//  enryo_message
//
//  Created by 酒井文也 on 2015/12/26.
//  Copyright © 2015年 just1factory. All rights reserved.
//

import UIKit

//Realmクラスのインポート
import RealmSwift

class VoiceHistory: Object {
    
    //Realmクラスのインスタンス
    static let realm = try! Realm()
    
    //id
    dynamic private var id = 0
    
    //音声で送信したデータ
    dynamic var formatText = ""
    
    //音声で送信したデータ
    dynamic var deviceType = 1
    
    //食べた日にち
    dynamic var createDate = NSDate(timeIntervalSince1970: 0)
    
    //PrimaryKeyの設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    //新規追加用のインスタンス生成メソッド
    static func create() -> VoiceHistory {
        let voice = VoiceHistory()
        voice.id = self.getLastId()
        return voice
    }
    
    //プライマリキーの作成メソッド
    static func getLastId() -> Int {
        if let voice = realm.objects(VoiceHistory).last {
            return voice.id + 1
        } else {
            return 1
        }
    }
    
    //インスタンス保存用メソッド
    func save() {
        try! VoiceHistory.realm.write {
            VoiceHistory.realm.add(self)
        }
    }
    
    //最新の記録データを取得をする（使用しないのでコメントアウト）
    /*
    static func fetchLastVoiceHistory() -> [String: String] {
        
        if let voice = realm.objects(VoiceHistory).sorted("id", ascending: true).first {
            
            let deviceType: String = String(voice.deviceType)
            let createDate: String = String(voice.createDate)
            let sendMessage: String = String(voice.formatText)
            
            return [
                "device":deviceType,
                "create":createDate,
                "detail":sendMessage
            ]
        } else {
            return [
                "device":"",
                "create":"",
                "detail":""
            ]
        }

    }
    */
    
}
