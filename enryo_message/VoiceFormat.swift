//
//  VoiceFormat.swift
//  enryo_message
//
//  Created by 酒井文也 on 2015/12/26.
//  Copyright © 2015年 just1factory. All rights reserved.
//

import UIKit

//Realmクラスのインポート
import RealmSwift

class VoiceFormat: Object {
    
    //Realmクラスのインスタンス
    static let realm = try! Realm()
    
    //id
    dynamic private var id = 0
    
    //音声にしたいデータ
    dynamic var formatText = ""
    
    //PrimaryKeyの設定
    override static func primaryKey() -> String? {
        return "id"
    }
    
    //新規追加用のインスタンス生成メソッド
    static func create() -> VoiceFormat {
        let voice = VoiceFormat()
        voice.id = self.getLastId()
        return voice
    }
    
    //プライマリキーの作成メソッド
    static func getLastId() -> Int {
        if let voice = realm.objects(VoiceFormat).last {
            return voice.id + 1
        } else {
            return 1
        }
    }
    
    //インスタンス保存用メソッド
    func save() {
        try! VoiceFormat.realm.write {
            VoiceFormat.realm.add(self)
        }
    }
    
    //インスタンス削除用メソッド
    func delete() {
        try! VoiceFormat.realm.write {
            VoiceFormat.realm.delete(self)
        }
    }
    
    //登録順のデータの全件取得をする
    static func fetchAllVoiceFormatList() -> [VoiceFormat] {
        let voices = realm.objects(VoiceFormat).sorted("id", ascending: false)
        var voiceList: [VoiceFormat] = []
        for voice in voices {
            voiceList.append(voice)
        }
        return voiceList
    }
    
}
