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
    
    /// remote server url
    public static var server:String = "https://www.localizationkit.com";
    
    /// Current language code
    public static var languageCode:String?
    /// core socket
    public static var socket:SocketIOClient?
    
    private static var appKey:String?
    
    private static var loadedLanguage:String?
    private static var loadedLanguageTranslations:[AnyHashable:String]?
    
    /// Notification event fired when language is initially loaded of localization text is changed
    public static var ALL_CHANGE = Notification.Name(rawValue: "LOCALIZATION_CHANGED")
    
    private static var _liveEnabled:Bool = false;
    
    /// If live updates are enabled
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
    
    /// Start Localization Service
    /// - parameter appKey: API key
    /// - parameter live: should enable dynamic update
    public static func start(appKey:String, live:Bool){
        self.appKey = appKey
        initialLanguage();
        self.liveEnabled = live;
        
    }
    
    /// Start Localization Service
    /// - parameter appKey: API key
    /// - parameter useSettings: Use the settings bundle
    public static func start(appKey:String, useSettings:Bool){
        self.appKey = appKey
        
        NotificationCenter.default.addObserver(self, selector: #selector(Localization.defaultsChanged),
                                               name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        initialLanguage();
    }
    
    /// Start Localization Service
    /// - parameter appKey: API key
    public static func start(appKey:String){
        self.appKey = appKey
        initialLanguage();
    }
    
    @objc public static func defaultsChanged(){
        let userDefaults = UserDefaults.standard
        let val = userDefaults.bool(forKey: "live_localization");
        if(val == true && self.liveEnabled == false && self.languageCode != nil){
            self.loadLanguage(code: self.languageCode!);
        }
        self.liveEnabled = val;
    }
    
    
    /// Save localization to local storage
    /// - parameter code: language 2 character code
    /// - parameter translation: translations associated with the language
    public static func saveLanguageToDisk(code:String, translation:[AnyHashable:String]){
        let standard = UserDefaults.standard;
        standard.set(translation, forKey: "\(self.appKey!)_\(code)");
        standard.synchronize()
    }
    
    /// Load localization from local storage
    /// - parameter code: language 2 character code
    public static func loadLanguageFromDisk(code:String){
        let standard = UserDefaults.standard
        guard let data = standard.object(forKey: "\(self.appKey!)_\(code)") as? [AnyHashable : String] else {
            return
        }
        self.loadedLanguageTranslations = data;
        NotificationCenter.default.post(name: Localization.ALL_CHANGE, object: self)
    }
    
    /// Request localization
    /// - parameter code: language 2 character code
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
    /// Request Available Languages
    public static func availableLanguages(_: @escaping ([[String:String]]) -> Swift.Void){
        loadAvailableLanguages { (languages) in
            print("languages");
        }
    }
    
    /// Load available languages from server
    private static func loadAvailableLanguages(_: @escaping ([[String:String]]) -> Swift.Void){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlString = Localization.server+"/api/app/\((self.appKey)!)/languages/"
        let url = URL(string: urlString as String)
        session.dataTask(with: url!) {
            (data, response, error) in
            if (response as? HTTPURLResponse) != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    /*guard let jsonData = json?["data"] as? [AnyHashable:String] else{
                        return;
                    }
                    loadedLanguageTranslations = jsonData;
                    self.joinLanguageRoom()
                    NotificationCenter.default.post(name: Localization.ALL_CHANGE, object: self)*/
                    
                } catch {
                    print("error serializing JSON: \(error)")
                }
                
            }
            }.resume()
    }
    
    /// Subscribe to current language updates
    private static func joinLanguageRoom(){
        let languageRoom = "\((self.appKey)!)_\((self.languageCode)!)"
        sendMessage(type: "join", data: ["room":languageRoom])
    }
    
    /// Load initial language
    private static func initialLanguage(){
        let url = URL(string: "\(server)/app/#/app/\(appKey!)")
        print("LocalizationKit:", url!)
        let defs = UserDefaults.standard
        let languages:NSArray = (defs.object(forKey: "AppleLanguages") as? NSArray)!
        let current:String  = languages.object(at: 0) as! String
        let currentParts = current.characters.split{$0 == "-"}.map(String.init)
        let currentLanguage:String = currentParts[0] as String
        setLanguage(currentLanguage)
    }
    
    /// Reset to device's natural language
    public func resetToDeviceLanguage(){
        self.resetToDeviceLanguage();
    }
    
    /// Get the Notification.Name for a Localization Key for a Highlight event
    /// - parameter localizationKey: localization key for element
    public static func highlightEvent(localizationKey:String) -> Notification.Name{
        return Notification.Name(rawValue: "LOC_HIGHLIGHT_\(localizationKey)")
    }
    
    /// Get the Notification.Name for a Localization Key for a Text/Localization event
    /// - parameter localizationKey: localization key for element
    public static func localizationEvent(localizationKey:String) -> Notification.Name{
        return Notification.Name(rawValue: "LOC_TEXT_\(localizationKey)")
    }
    
    /// Start socket server
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
            guard let meta = dictionary["meta"] as? String else {
                return;
            }
            NotificationCenter.default.post(name: self.highlightEvent(localizationKey: meta), object: self)
        })
        socket?.on("text", callback: {(data,ack) in
            let dictionary = data[0] as! [AnyHashable : Any]
            guard let meta = dictionary["meta"] as? String else {
                return;
            }
            let value = dictionary["value"] as! String
            self.loadedLanguageTranslations?[meta] = value
            NotificationCenter.default.post(name: self.localizationEvent(localizationKey: meta), object: self)
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
    
    /// Set Language Code
    /// - parameter language: language 2 character code
    public static func setLanguage(_ language:String){
        if languageCode != language {
            languageCode = language
            loadLanguage(code: language);
            //NotificationCenter.default.post(name: Notification.Name(rawValue: "LOCALIZATION_CHANGED"), object: self)
        }
    }
    
    /// Get translation for text
    /// - parameter key: the unique translation text identifier
    /// - parameter alternate: the default text for this key
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
