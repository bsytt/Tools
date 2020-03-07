//
//  SYSocketManager.swift
//  DatianDigitalAgriculture
//
//  Created by bsy on 2019/12/5.
//  Copyright © 2019 bsy. All rights reserved.
//

import UIKit
//需要导入SocketRocket
@objc protocol SYSocketManagerDelegate {
    func sy_webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: SYSocketModel?)
    @objc optional func sy_webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!)
}
class SYSocketManager: NSObject {
    //socket链接
    private var webSocket :SRWebSocket!
    var time = 0
    
    var sy_delegate : SYSocketManagerDelegate?
    
    override init() {
        super.init()
        self.webSocket = SRWebSocket(urlRequest: URLRequest(url: URL(string: kBaseWebSocketURL)!))
        self.webSocket.delegate = self
        self.webSocket.open()
    }
    func sendMsg(_ msg:String) {
        self.webSocket.send(msg)
    }
    func sendMsg(_ msgData:Data) {
        self.webSocket.sendPing(msgData)
    }
    //  重连
    private func reconnect() {
        let url = URL(string: kBaseWebSocketURL)
        webSocket = SRWebSocket(url: url)
        webSocket.delegate = self
        webSocket.open()
    }
    func close() {
        webSocket.close()
    }
}
extension SYSocketManager: SRWebSocketDelegate {
    func webSocket(_ webSocket: SRWebSocket!, didReceiveMessage message: Any!) {
        let messageStr = message as! String
        let dic = messageStr.toObj()
        let model = SYSocketModel(dict: dic!)
        self.sy_delegate?.sy_webSocket(webSocket, didReceiveMessage: model)
    }

    func webSocket(_ webSocket: SRWebSocket!, didFailWithError error: Error!) {
        webSocket.delegate = nil
        if time < 70 {
            time += 1
            reconnect()
        }else {
            XYProgressHUD.show(message: "链接失败")
            self.sy_delegate?.sy_webSocket?(webSocket, didFailWithError: error)
        }
    }
    func webSocket(_ webSocket: SRWebSocket!, didCloseWithCode code: Int, reason: String!, wasClean: Bool) {
        print("关闭连接")
    }
    func webSocketDidOpen(_ webSocket: SRWebSocket!) {
        XYProgressHUD.dissmiss()
        sendMsg("")
    }
    func webSocket(_ webSocket: SRWebSocket!, didReceivePong pongPayload: Data!) {

    }
    
}
