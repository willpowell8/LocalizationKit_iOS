//
//  Language.swift
//  Pods
//
//  Created by Will Powell on 03/11/2016.
//
//

import Foundation
import SocketIO

public class Localization {
    
    public static var server:String = "http://www.localizationkit.com";
    
    public static var bundle:Bundle?
    public static var languageCode:String?
    public static var socket:SocketIOClient?
    
    private static var appKey:String?
    
    
    private static var loadedLanguage:String?
    private static var loadedLanguageTranslations:[AnyHashable:String]?
    
    public static var ALL_CHANGE = Notification.Name(rawValue: "LOCALIZATION_CHANGED")
    
    
    public static func start(appKey:String){
        self.appKey = appKey
        initialLanguage();
        
        startSocket();
        
    }
    
    private static func loadLanguage(key:String){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlString = Localization.server+"/api/app/\((self.appKey)!)/language/\(key)"
        let url = URL(string: urlString as String)
        session.dataTask(with: url!) {
            (data, response, error) in
            if (response as? HTTPURLResponse) != nil {
                let dataString = String(data: data!, encoding: .utf8)
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    loadedLanguageTranslations = json?["data"] as! [AnyHashable:String];
                    self.joinLanguageRoom()
                    NotificationCenter.default.post(name: Localization.ALL_CHANGE, object: self)
                    
                } catch {
                    print("error serializing JSON: \(error)")
                }
                
            }
            }.resume()
    }
    
    private static func joinLanguageRoom(){
        let languageRoom = "\((self.appKey)!)_\((self.languageCode)!)"
        sendMessage(type: "join", data: ["room":languageRoom])
    }
    
    private static func initialLanguage(){
        let defs = UserDefaults.standard
        let languages:NSArray = (defs.object(forKey: "AppleLanguages") as? NSArray)!
        let current:String  = languages.object(at: 0) as! String
        let currentParts = current.characters.split{$0 == "-"}.map(String.init)
        let currentLanguage:String = currentParts[0] as String
        setLanguage(currentLanguage)
    }
    
    
    private static func startSocket(){
        let url = URL(string: server)
        socket = SocketIOClient(socketURL: url!)
        socket?.on("connect", callback: {(data,ack) in
            self.joinLanguageRoom()
            let appRoom = "\((self.appKey)!)_app"
            sendMessage(type: "join", data: ["room":appRoom])
            NotificationCenter.default.post(name: ALL_CHANGE, object: self)
        })
        socket?.on("languages", callback: {(data,ack) in
            let dictionary = data[0] as! [AnyHashable : Any]
        })
        socket?.on("highlight", callback: {(data,ack) in
            let dictionary = data[0] as! [AnyHashable : Any]
            let meta = dictionary["meta"] as! String
            let event = "LOC_HIGHLIGHT_\(meta)"
            NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: self)
        })
        socket?.on("text", callback: {(data,ack) in
            let dictionary = data[0] as! [AnyHashable : Any]
            let meta = dictionary["meta"] as! String
            let value = dictionary["value"] as! String
            self.loadedLanguageTranslations?[meta] = value
            let event = "LOC_TEXT_\(meta)"
            NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: self)
        })
        socket?.connect()
    }
    
    
    private static func joinRoom(name:String){
        self.sendMessage(type: "join", data: ["room":name])
    }
    
    private static func leaveRoom(name:String){
        self.sendMessage(type: "leave", data: ["room":name])
    }
    
    private static func sendMessage(type:String, data:SocketData...){
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit(type, with: data)
        }
    }
    
    
    public static func setLanguage(_ language:String){
        if languageCode != language {
            languageCode = language
            loadLanguage(key: language);
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "LOCALIZATION_CHANGED"), object: self)
        }
    }
    
    
    public static func get(_ key:String, alternate:String) -> String{
        let m = self.loadedLanguageTranslations
        if m == nil {
            return key
        }
        
        guard let localisation = loadedLanguageTranslations?[key] else {
            if languageCode != nil && socket?.status == SocketIOClientStatus.connected {
                self.loadedLanguageTranslations?[key] = key
                self.sendMessage(type: "key:add", data: ["appuuid":self.appKey!, "key":key, "language":languageCode!])
            }
            return key;
        }
        return localisation
    }
}
