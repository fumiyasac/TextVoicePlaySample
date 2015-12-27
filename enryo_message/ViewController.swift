//
//  ViewController.swift
//  enryo_message
//
//  Created by 酒井文也 on 2015/12/26.
//  Copyright © 2015年 just1factory. All rights reserved.
//

import UIKit
//import RealmSwift
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate,AVSpeechSynthesizerDelegate {

    //配置する部品
    @IBOutlet var titleThumbImage: UIImageView!
    @IBOutlet var targetVoiceTextField: UITextField!
    @IBOutlet var voiceListTable: UITableView!
    
    //メンバ変数(登録用変数の格納)
    var addVoice: String = ""
    
    //メンバ変数(音声用変数の格納)
    var targetVoice: String = ""
    
    //テーブルビューに関する「メンバ変数
    var cellCount: Int!
    var cellSectionCount: Int = 1
    
    //テーブルデータ表示用の言葉一覧
    var voiceFormatArray: NSMutableArray = []
    
    //履歴用の言葉一覧
    var voiceHistoryArray: NSMutableArray = []
    
    //AVSpeechSynthesizerのインスタンス変数
    var talker:AVSpeechSynthesizer = AVSpeechSynthesizer()
    
    override func viewWillAppear(animated: Bool) {
        self.fetchAndReloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //デリゲート
        self.targetVoiceTextField.delegate = self
        self.voiceListTable.delegate = self
        self.voiceListTable.dataSource = self
        self.talker.delegate = self
        
        //Xibのクラスを読み込む宣言を行う
        let nibDefault:UINib = UINib(nibName: "VoicePatternCell", bundle: nil)
        self.voiceListTable.registerNib(nibDefault, forCellReuseIdentifier: "VoicePatternCell")
    }
    
    //各データのfetchとテーブルビューのリロードを行う
    func fetchAndReloadData() {
        
        //テーブルビュー用のデータを表示する
        self.voiceFormatArray.removeAllObjects()
        let voices = VoiceFormat.fetchAllVoiceFormatList()
        
        self.cellCount = voices.count
        
        if self.cellCount != 0 {
            for voice in voices {
                self.voiceFormatArray.addObject(voice)
            }
        }
        
        //テーブルビューをリロード
        self.reloadData()
    }
    
    //TableView: テーブルの要素数を設定する
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.cellSectionCount
    }
    
    //TableView: テーブルのセクションのセル数を設定する
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellCount
    }
    
    //TableView: 表示するセルの中身を設定する
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //Xibファイルを元にデータを作成する
        let cell = tableView.dequeueReusableCellWithIdentifier("VoicePatternCell") as? VoicePatternCell
        
        //テキスト・画像等の表示
        let voiceData: VoiceFormat = self.voiceFormatArray[indexPath.row] as! VoiceFormat
        
        cell!.voicePatternId.text = "内容："
        cell!.voicePatternText.text = String(voiceData.formatText)
        
        //セルのアクセサリタイプと背景の設定
        cell!.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        cell!.selectionStyle = UITableViewCellSelectionStyle.None
        
        return cell!
    }
    
    //TableView: セルをタップした時に呼び出される
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    //TableView: Editableの状態にする.
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    //TableView: 特定の行のボタン操作を有効にする.
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    //TableView: Buttonを拡張＆データ削除処理
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        //選択ボタン
        let mySelectButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "選択") { (action, index) -> Void in
            
            //テーブルビューを編集不可にする
            tableView.editing = false
            
            //声にする内容をテキストフィールドへ反映させる
            let voiceData: VoiceFormat = self.voiceFormatArray[indexPath.row] as! VoiceFormat
            let targetVoice: String = String(voiceData.formatText)
            self.targetVoiceTextField.text = targetVoice
            
        }
        mySelectButton.backgroundColor = UIColor.blueColor()
        
        //削除ボタン
        let myDeleteButton: UITableViewRowAction = UITableViewRowAction(style: .Normal, title: "削除") { (action, index) -> Void in
            
            //テーブルビューを編集不可にする
            tableView.editing = false
            
            //データを1件削除
            let voiceData: VoiceFormat = self.voiceFormatArray[indexPath.row] as! VoiceFormat
            voiceData.delete()
            
            //データをリロードする
            self.fetchAndReloadData()
        }
        myDeleteButton.backgroundColor = UIColor.redColor()
        return [myDeleteButton, mySelectButton]
    }
    
    //TableView: セルの高さを返す
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(60.0)
    }
    
    //TableView: テーブルビューをリロードする
    func reloadData(){
        self.voiceListTable.reloadData()
    }
    
    //キーボードを引っ込める処理
    @IBAction func closeKeyBoard(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }

    //声のデータ追加アクション
    @IBAction func addVoiceAction(sender: UIButton) {
        
        //登録されたアラートを表示してOKを押すと戻る
        let formAlert = UIAlertController(
            title: "音声内容追加",
            message: "音声のパターンを入力して下さい。",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        formAlert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Default,
                handler: {
                    (action: UIAlertAction!) -> Void in
                    
                    //UIAlertAction内にテキストフィールドを1個以上追加する際の書き方
                    let textFields:Array<UITextField>? = formAlert.textFields as Array<UITextField>?
                    
                    //----- 喋ってほしい音声のパターンを追加(ここから) -----
                    if textFields != nil {
                        
                        for textField:UITextField in textFields! {
                            
                            //テキストがnilないしは空以外の場合は喋って欲しい言葉を登録
                            if textField.text != nil && textField.text != "" {
                                
                                //値を格納してRealmに追加
                                self.addVoice = textField.text!
                                print(self.addVoice)
                                
                                //Realmにデータを1件登録する
                                let voiceFormatObject = VoiceFormat.create()
                                voiceFormatObject.formatText = self.addVoice
                                
                                //登録処理
                                voiceFormatObject.save()
                            }
                        }
                    }
                    //----- 喋ってほしい音声のパターンを追加(ここまで) -----
                    
                    //テーブルビューのリロード
                    self.fetchAndReloadData()
                }
            )
        )
        
        //テキストフィールドの追加
        formAlert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
        })
        
        //戻る処理
        presentViewController(formAlert, animated: true, completion: nil)
    }
    
    //音声再生アクション
    @IBAction func playVoiceAction(sender: UIButton) {
        
        self.targetVoice = self.targetVoiceTextField.text!
        
        //異常処理時
        if self.targetVoice.isEmpty {
            
            //エラーのアラートを表示してOKを押すと戻る
            let errorAlert = UIAlertController(
                title: "エラー",
                message: "入力必須の項目に不備があります。",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            errorAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler: nil
                )
            )
            presentViewController(errorAlert, animated: true, completion: nil)
        
        //正常処理時
        } else {
            
            //Realmにデータを1件登録する
            let voiceHistoryObject = VoiceHistory.create()
            voiceHistoryObject.formatText = self.targetVoice
            voiceHistoryObject.deviceType = 1
            voiceHistoryObject.createDate = NSDate()
            
            //登録処理
            voiceHistoryObject.save()
            
            //話す内容をセット
            let utterance = AVSpeechUtterance(string: self.targetVoice)
            
            //言語を日本に設定
            /*
             * (2015.12.26) 下記のようなエラーが発生しており現在も未解決です。フォーラムでもまだ未解決っぽい。。。
             * シミュレーターでは問題なく動作します。
             *
             * 実装の参考：
             * http://dev.classmethod.jp/smartphone/iphone/swfit-avspeechsynthesizer/
             *
             * 2015-12-26 17:45:04.276 enryo_message[438:63495] |AXSpeechAssetDownloader|error| ASAssetQuery error 
             * fetching results (for com.apple.MobileAsset.MacinTalkVoiceAssets) Error Domain=ASError Code=21
             * "Unable to copy asset information" UserInfo={NSDescription=Unable to copy asset information}
             *
             */

            //読む言語（言語の選択だけで他の詳細な設定はできない）
            utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
            //読む速さ
            utterance.rate = 0.55
            //音量
            utterance.volume = 1
            
            //実行されたらテキストフィールドは空にする
            self.targetVoiceTextField.text = ""
            
            //実行
            self.talker.speakUtterance(utterance)
            
            //登録されたアラートを表示してOKを押すと戻る
            let correctAlert = UIAlertController(
                title: "音声再生中...",
                message: "音声の再生と履歴が登録されました。",
                preferredStyle: UIAlertControllerStyle.Alert
            )
            correctAlert.addAction(
                UIAlertAction(
                    title: "OK",
                    style: UIAlertActionStyle.Default,
                    handler: nil
                )
            )
            
            //戻る処理
            presentViewController(correctAlert, animated: true, completion: nil)
            
        }
        
    }
    
    //Debug: 音声読み上げ開始時のデリゲートメソッド
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didStartSpeechUtterance utterance: AVSpeechUtterance) {
        print("----- 開始 -----")
    }
    
    //Debug: 音声読み上げ最中のデリゲートメソッド
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        let word = (utterance.speechString as NSString).substringWithRange(characterRange)
        print("----- 内容: \(word) -----")
    }
    
    //Debug: 音声読み上げ終了時のデリゲートメソッド
    func speechSynthesizer(synthesizer: AVSpeechSynthesizer, didFinishSpeechUtterance utterance: AVSpeechUtterance) {
        print("---- 終了 -----")
    }
    
    //WatchOS2: Realmに格納されている定型文データを全件取得
    func getAllVoiceFormat() -> NSMutableArray {
        
        let targetArray: NSMutableArray = []
        let voices = VoiceFormat.fetchAllVoiceFormatList()
        
        if voices.count != 0 {
            
            for voice in voices {
                let message: String = voice.formatText
                targetArray.addObject(message)
            }
        }
        return targetArray
    }

    //WatchOS2: Watch側のデータを受け取って音声を出力＆Realmへ格納
    func receiveMessageAndSaveForWatch(message: String) {
        
        //Realmにデータを1件登録する
        let voiceHistoryObject = VoiceHistory.create()
        voiceHistoryObject.formatText = message
        voiceHistoryObject.deviceType = 2
        voiceHistoryObject.createDate = NSDate()
        
        //登録処理
        voiceHistoryObject.save()
        
        //話す内容をセット
        let utterance = AVSpeechUtterance(string: message)
        
        //読む言語（言語の選択だけで他の詳細な設定はできない）
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        //読む速さ
        utterance.rate = 0.55
        //音量
        utterance.volume = 1
        
        //実行
        self.talker.speakUtterance(utterance)
    }
        
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

