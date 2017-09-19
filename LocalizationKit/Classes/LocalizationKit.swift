//
//  Language.swift
//  Pods
//
//  Created by Will Powell on 03/11/2016.
//
//

import Foundation
import SocketIO

public class Language {
    public var localizedName:String = "";
    public var key:String = "";
    public var localizedNames:[String:Any]? // localized language names
    
    init (localizedName:String, key:String, localizedNames:[String:Any]?){
        self.key = key;
        self.localizedName = localizedName
        self.localizedNames = localizedNames
    }
    
    public func localizedName(forLangageCode languageCode:String)->String?{
        return localizedNames?[languageCode] as? String
    }
}

public class Localization {
    
    /**
        Remote server address
    */
    public static var server:String = "https://www.localizationkit.com";
    
    
    /**
     
    */
    
    public static var ifEmptyShowKey = false
    public static var allowInlineEdit = false {
        didSet{
            if oldValue != allowInlineEdit {
                NotificationCenter.default.post(name: Localization.INLINE_EDIT_CHANGED, object: nil)
            }
        }
    }
    
    public static var buildLanguageCode = "en"
    
    /**
        Trim localizationkey
    */
    public static func parse(str:String)->String{
        let newString = str.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        let character = CharacterSet(charactersIn:"0123456789.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ").inverted
        return newString.trimmingCharacters(in: character);
    }
    
    /**
        Current language code
    */
    public static var languageCode:String? {
        didSet{
            saveSelectedLanguageCode()
        }
    }
    
    public static var language639Code:String? {
        get {
            if let langCode = languageCode {
                if langCode.contains("-") {
                    let languageParts = langCode.components(separatedBy: "-")
                    return languageParts[0]
                }else{
                    return languageCode
                }
            }
            return nil
        }
    }
    
    private static func saveSelectedLanguageCode(){
        let standard = UserDefaults.standard;
        standard.set(languageCode, forKey: "\(self.appKey!)_SELECTED");
        standard.synchronize()
    }
    
    private static func loadSelectedLanguageCode(_ completion: @escaping (_ languageKey:String?) -> Swift.Void)->Swift.Void{
        let standard = UserDefaults.standard;
        if let val = standard.string(forKey: "\(self.appKey!)_SELECTED") {
            return completion(val)
        }
        let defs = UserDefaults.standard
        let languages:NSArray = (defs.object(forKey: "AppleLanguages") as? NSArray)!
        let current:String  = languages.object(at: 0) as! String
        //let currentParts = current.characters.split{$0 == "-"}.map(String.init)
        self.availableLanguages { (languages) in
            if let language = findLanguage(languages: languages, languageKey: current) {
                return completion(language.key)
            }
            if current.contains("-") {
                let currentComponents = current.components(separatedBy: "-")
                let reducedCurrentComponents = currentComponents[0..<(currentComponents.count-1)]
                let newCurrent = reducedCurrentComponents.joined(separator: "-")
                if let language = findLanguage(languages: languages, languageKey: newCurrent) {
                    return completion(language.key)
                }
                if newCurrent.contains("-") {
                    let finalCurrentComponents = newCurrent.components(separatedBy: "-")
                    let finalReducedCurrentComponents = finalCurrentComponents[0..<(finalCurrentComponents.count-1)]
                    let finalNewCurrent = finalReducedCurrentComponents.joined(separator: "-")
                    if let language = findLanguage(languages: languages, languageKey: finalNewCurrent) {
                        return completion(language.key)
                    }
                }
            }
            return completion(nil)
        }
    }
    
    private static func findLanguage(languages:[Language], languageKey:String)->Language? {
        let foundLanguage = languages.filter({ (language) -> Bool in
            return language.key == languageKey
        })
        if foundLanguage.count == 1 {
            return foundLanguage[0]
        }
        return nil
    }
    
    
    /**
        core socket
    */
    public static var socket:SocketIOClient?
    
    private static var appKey:String?
    
    private static var loadedLanguage:String?
    private static var loadedLanguageTranslations:[AnyHashable:String]?
    
    /**
        Notification event fired when language is initially loaded of localization text is changed
    */
    public static var ALL_CHANGE = Notification.Name(rawValue: "LOCALIZATION_CHANGED")
    public static var INLINE_EDIT_CHANGED = Notification.Name(rawValue: "LOCALIZATION_INLINE_EDIT")
    
    private static var _liveEnabled:Bool = false;
    
    /** 
        If live updates are enabled
    */
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
                    if let socket = self.socket {
                       socket.disconnect()
                    }
                }
            }
            
        }
    }
    
    /**
        Start Localization Service
        - Parameter appKey: API key
        - Parameter live: should enable dynamic update
    */
    public static func start(appKey:String, live:Bool){
        self.appKey = appKey
        initialLanguage();
        self.liveEnabled = live;
        
    }
    
    /**
        Start Localization Service
        - Parameter appKey: API key
        - Parameter useSettings: Use the settings bundle
    */
    public static func start(appKey:String, useSettings:Bool){
        self.appKey = appKey
        
        NotificationCenter.default.addObserver(self, selector: #selector(Localization.defaultsChanged),
                                               name: UserDefaults.didChangeNotification, object: nil)
        defaultsChanged()
        initialLanguage();
    }
    
    /**
        Start Localization Service
        - Parameter appKey: API key
    */
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
        
        self.allowInlineEdit = userDefaults.bool(forKey: "live_localization_inline");
    }
    
    
    /**
        Save localization to local storage
        - parameter code: language 2 character code
        - parameter translation: translations associated with the language
     */
    public static func saveLanguageToDisk(code:String, translation:[AnyHashable:String]){
        let standard = UserDefaults.standard;
        standard.set(translation, forKey: "\(self.appKey!)_\(code)");
        standard.synchronize()
    }
    
    /**
        Load localization from local storage
        - Parameter code: language 2 character code
    */
    public static func loadLanguageFromDisk(code:String){
        let standard = UserDefaults.standard
        guard let data = standard.object(forKey: "\(self.appKey!)_\(code)") as? [AnyHashable : String] else {
            return
        }
        self.loadedLanguageTranslations = data;
        NotificationCenter.default.post(name: Localization.ALL_CHANGE, object: self)
    }
    /**
     Request localization
     - Parameter code: language 2 character code
     */
    private static func loadLanguage(code:String){
        self.loadLanguage(code: code) { 
            return;
        }
    }
    
    /**
        Request localization
        - Parameter code: language 2 character code
     */
    private static func loadLanguage(code:String, _ completion: @escaping () -> Swift.Void){
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
                    completion();
                } catch {
                    print("error serializing JSON: \(error)")
                }
                
            }
            }.resume()
    }
    
    /**
        Request Available Languages
    */
    public static func availableLanguages(_ completion: @escaping ([Language]) -> Swift.Void){
        let language = self.languageCode ?? "en"
        loadAvailableLanguages (languageCode: language) { (languages) in
            completion(languages)
        }
    }
    
    /**
        Request Available Languages
    */
    public static func availableLanguages(languageCode:String,_ completion: @escaping ([Language]) -> Swift.Void){
        loadAvailableLanguages (languageCode: languageCode) { (languages) in
            completion(languages)
        }
    }
    
    /**
        Load available languages from server
    */
    private static func loadAvailableLanguages(languageCode:String, _ completion: @escaping ([Language]) -> Swift.Void){
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlString = Localization.server+"/api/app/\((self.appKey)!)/languages/"
        let url = URL(string: urlString as String)
        session.dataTask(with: url!) {
            (data, response, error) in
            if (response as? HTTPURLResponse) != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    guard let languages = json?["languages"] as? [[String:AnyHashable]] else{
                        return;
                    }
                    var languagesOutput = [Language]()
                    for i in 0..<languages.count {
                        let languageKey = languages[i]["key"] as! String;
                        var languageNameLocalized = languageKey
                        var languageNames = [String:Any]()
                        if let languageName = languages[i]["name"] as? [String:Any] {
                            languageNames = languageName
                            if let langCode = languageName[languageCode] as? String {
                                languageNameLocalized = langCode
                            }
                        }
                        languagesOutput.append(Language(localizedName: languageNameLocalized, key: languageKey, localizedNames:languageNames))
                    }
                    print("Completed");
                    completion(languagesOutput)
                } catch {
                    print("error serializing JSON: \(error)")
                }
                
            }
            }.resume()
    }
    
    
    
    /**
        Load initial language
    */
    private static func initialLanguage(){
        let url = URL(string: "\(server)/app/#/app/\(appKey!)")
        print("LocalizationKit:", url!)
        loadSelectedLanguageCode { (language) in
            guard let lang = language else {
                print("No language available")
                return
            }
            setLanguage(lang)
        }
    }
    
    /**
        Reset to device's natural language
    */
    public func resetToDeviceLanguage(){
        self.resetToDeviceLanguage();
    }
    
    /**
        Get the Notification.Name for a Localization Key for a Highlight event
        - Parameter localizationKey: localization key for element
    */
    public static func highlightEvent(localizationKey:String) -> Notification.Name{
        return Notification.Name(rawValue: "LOC_HIGHLIGHT_\(localizationKey)")
    }
    
    /**
        Get the Notification.Name for a Localization Key for a Text/Localization event
        - Parameter localizationKey: localization key for element
    */
    public static func localizationEvent(localizationKey:String) -> Notification.Name{
        return Notification.Name(rawValue: "LOC_TEXT_\(localizationKey)")
    }
    
    /**
        Start socket server
    */
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
    
    /**
        Subscribe to current language updates
    */
    
    private static var hasJoinedLanguageRoom:Bool = false
    private static func joinLanguageRoom(){
        guard liveEnabled == true else {
            return
        }
        guard let appKey = self.appKey, let langCode = self.languageCode else{
            return
        }
        hasJoinedLanguageRoom = true
        let languageRoom = "\(appKey)_\(langCode)"
        joinRoom(name:languageRoom)
    }
    
    private static func leaveRoom(name:String){
        self.sendMessage(type: "leave", data: ["room":name])
    }
    
    /**
        Subscribe to current language updates
     */
    private static func leaveLanguageRoom(){
        if self.appKey != nil && self.languageCode != nil {
            let languageRoom = "\((self.appKey)!)_\((self.languageCode)!)"
            leaveRoom(name:languageRoom)
        }
    }
    
    private static func sendMessage(type:String, data:SocketData...){
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit(type, with: data)
        }
    }
    
    /**
        Set Language Code
        - Parameter language: language 2 character code
    */
    public static func setLanguage(_ language:String){
        self.setLanguage(language) { 
            
        }
    }
    
    /**
        Set Language Code with completion call back
        - Parameter language: language 2 character code
        - Parameter completion: function called when language has been loaded
     */
    public static func setLanguage(_ language:String, _ completion: @escaping () -> Swift.Void){
        if languageCode != language {
            self.leaveLanguageRoom();
            languageCode = language
            self.loadLanguage(code: language, { 
                completion();
            })
        }else{
            completion();
        }
    }
    
    /**
 
    */
    
    public static func set(_ key:String,value:String, language:String? = nil){
        var data = ["appuuid":Localization.appKey!, "key":key, "value":value, "language": Localization.languageCode!]
        if language != nil {
            data["language"] = language
        }
        if liveEnabled && languageCode != nil && socket?.status == SocketIOClientStatus.connected {
            self.loadedLanguageTranslations?[key] = value
            self.sendMessage(type: "translation:save", data: data)
            NotificationCenter.default.post(name: self.localizationEvent(localizationKey: key), object: self)
        }
    }
    
    /**
        Get translation for text
        - Parameter key: the unique translation text identifier
        - Parameter alternate: the default text for this key
    */
    public static func get(_ key:String, alternate:String) -> String{
        let m = self.loadedLanguageTranslations
        let keyString = self.languageCode != nil ? "\(self.languageCode!)-\(key)" : "NA-\(key)"
        if m == nil {
            if alternate.characters.count == 0 && ifEmptyShowKey == true {
                return keyString
            }
            return alternate
        }
        
        guard let localisation = loadedLanguageTranslations?[key] else {
            if liveEnabled && languageCode != nil && socket?.status == SocketIOClientStatus.connected {
                self.loadedLanguageTranslations?[key] = key
                if alternate != key && alternate != keyString {
                    self.sendMessage(type: "key:add", data: ["appuuid":self.appKey!, "key":key, "language":buildLanguageCode, "raw":alternate])
                }else{
                    self.sendMessage(type: "key:add", data: ["appuuid":self.appKey!, "key":key, "language":buildLanguageCode])
                }
            }
            
            if alternate.characters.count == 0 && ifEmptyShowKey == true {
                return keyString
            }
            return alternate;
        }
        
        if localisation.characters.count == 0 && ifEmptyShowKey == true {
            return keyString
        }
        return localisation
    }
}


