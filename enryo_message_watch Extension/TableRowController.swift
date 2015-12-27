//
//  TableRowController.swift
//  enryo_message
//
//  Created by 酒井文也 on 2015/12/27.
//  Copyright © 2015年 just1factory. All rights reserved.
//

import WatchKit

class TableRowController: NSObject {

    //セル内のラベルと関連づけをする
    //（注意1）「Custom Class」の部分をTableRowController.swiftにする
    //（注意2）Row Controllerの「Indentifier」をTheRowにする
    @IBOutlet var messageTableLabel: WKInterfaceLabel!    
    
}
