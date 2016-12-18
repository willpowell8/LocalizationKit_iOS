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
    
    private static var _liveEnabled:Bool = false;
    
    public static var liveEnabled:Bool {
        get {
            return _liveEnabled;
        }
        set (newValue){
            if(_liveEnabled != newValue){
                _liveEnabled = newValue
                if(newValue){
                    startSocket();
                }else{
                    // end socket
                    if((self.socket) != nil){
                        self.socket?.disconnect()
                    }
                }
            }
            
        }
    }
    
    
    public static func start(appKey:String, live:Bool){
        self.appKey = appKey
        NotificationCenter.default.addObserver(self, selector: #selector(Localization.defaultsChanged),
                                                        name: UserDefaults.didChangeNotification, object: nil)
        initialLanguage();
        
        self.liveEnabled = live;
        
    }
    
    @objc public static func defaultsChanged(){
        let userDefaults = UserDefaults.standard
        let val = userDefaults.bool(forKey: "live_localization");
        if(val == true && self.liveEnabled == false && self.languageCode != nil){
            self.loadLanguage(code: self.languageCode!);
        }
        self.liveEnabled = val;
    }
    
    public static func start(appKey:String){
        self.appKey = appKey
        initialLanguage();
    }
    
    public static func saveLanguageToDisk(code:String, translation:[AnyHashable:String]){
        let standard = UserDefaults.standard;
        standard.set(translation, forKey: "\(self.appKey!)_\(code)");
        standard.synchronize()
    }
    
    public static func loadLanguageFromDisk(code:String){
        let standard = UserDefaults.standard
        guard let data = standard.object(forKey: "\(self.appKey!)_\(code)") as? [AnyHashable : String] else {
            return
        }
        self.loadedLanguageTranslations = data;
        NotificationCenter.default.post(name: Localization.ALL_CHANGE, object: self)
    }
    
    private static func loadLanguage(code:String){
        self.loadLanguageFromDisk(code: code);
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlString = Localization.server+"/api/app/\((self.appKey)!)/language/\(code)"
        let url = URL(string: urlString as String)
        session.dataTask(with: url!) {
            (data, response, error) in
            if (response as? HTTPURLResponse) != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    guard let jsonData = json?["data"] as? [AnyHashable:String] else{
                        return;
                    }
                    loadedLanguageTranslations = jsonData;
                    saveLanguageToDisk(code: code, translation: self.loadedLanguageTranslations!);
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
            //let dictionary = data[0] as! [AnyHashable : Any]
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
            loadLanguage(code: language);
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "LOCALIZATION_CHANGED"), object: self)
        }
    }
    
    
    public static func get(_ key:String, alternate:String) -> String{
        let m = self.loadedLanguageTranslations
        if m == nil {
            return alternate
        }
        
        guard let localisation = loadedLanguageTranslations?[key] else {
            if liveEnabled && languageCode != nil && socket?.status == SocketIOClientStatus.connected {
                self.loadedLanguageTranslations?[key] = key
                if alternate != key {
                    self.sendMessage(type: "key:add", data: ["appuuid":self.appKey!, "key":key, "language":languageCode!, "raw":alternate])
                }else{
                    self.sendMessage(type: "key:add", data: ["appuuid":self.appKey!, "key":key, "language":languageCode!])
                }
            }
            return alternate;
        }
        return localisation
    }
}
