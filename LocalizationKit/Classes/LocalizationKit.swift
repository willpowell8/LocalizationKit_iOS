//
//  Language.swift
//  Pods
//
//  Created by Will Powell on 03/11/2016.
//
//

import Foundation
import SocketIO

public class Language:NSObject,NSCoding {
    public var localizedName:String = "";
    public var key:String = ""; // language code eg. en, zh-Hans
    public var localizedNames:[String:Any]? // localized language names
    
    init (localizedName:String, key:String, localizedNames:[String:Any]?){
        self.key = key;
        self.localizedName = localizedName
        self.localizedNames = localizedNames
    }
    
    required convenience public init?(coder decoder: NSCoder) {
        if let localizedNameTemp = decoder.decodeObject(forKey: "localizedName") as? String {
            let keyTemp = decoder.decodeObject(forKey: "key") as? String
            if let localizedNamesTemp = decoder.decodeObject(forKey: "localizedNames") as? [String:String] {
                self.init(localizedName: localizedNameTemp, key: keyTemp!, localizedNames: localizedNamesTemp)
            }else{
                self.init(localizedName: localizedNameTemp, key: keyTemp!, localizedNames: nil)
            }
        }else{
            self.init(localizedName: "English", key: "en", localizedNames: nil)
        }
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.localizedName, forKey: "localizedName")
        aCoder.encode(self.key, forKey: "key")
        if let localizationNames = self.localizedNames {
            aCoder.encode(localizationNames, forKey: "localizedNames")
        }
    }
    
    public func name(forLangageCode languageCode:String)->String?{
        return localizedNames?[languageCode] as? String
    }
    
    public var localName:String?{
        get{
            return name(forLangageCode: key)
        }
    }
}

public class Localization {
    
    /**
        Remote server address
    */
    public static var server:String = "https://www.localizationkit.com";
    
    
    /**
         If the keys are empty show the localization key eg. en.Home.Title to highlight the missing keys
    */
    public static var ifEmptyShowKey = false
    
    /**
         core socket
     */
    public static var socket:SocketIOClient?
    
    /**
         App Key
     */
    private static var appKey:String?
    
    /**
         Loaded language string
     */
    private static var loadedLanguageTranslations:[AnyHashable:String]?
    
    /**
         Notification event fired when language is initially loaded of localization text is changed
     */
    public static var ALL_CHANGE = Notification.Name(rawValue: "LOCALIZATION_CHANGED")
    public static var INLINE_EDIT_CHANGED = Notification.Name(rawValue: "LOCALIZATION_INLINE_EDIT")
    
    
    private static let storageLocation:String = "SELECTED_LANGUAGE"
    
    private static var _liveEnabled:Bool = false;
    
    /**
         Allow the inline editor screens using long press on the string field
     */
    public static var allowInlineEdit = false {
        didSet{
            if oldValue != allowInlineEdit {
                NotificationCenter.default.post(name: Localization.INLINE_EDIT_CHANGED, object: nil)
            }
        }
    }
    
    /**
         The build language is the initial language for the current language keys
     */
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
        get{
            return language?.key
        }
    }
    
    
    private static var _language:Language? {
        didSet{
            saveSelectedLanguageCode()
        }
    }
    
    /**
         Selected current language
     */
    public static var language:Language? {
        get{
            return _language
        }
    }
    
    /**
         Get language iso-639-1 code for selected language
     */
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
    
    /**
         save the current selected language
     */
    private static func saveSelectedLanguageCode(){
        if let language = self._language {
            let encodedData = NSKeyedArchiver.archivedData(withRootObject: language)
            let standard = UserDefaults.standard;
            standard.set(encodedData, forKey: "\(self.appKey!)_\(storageLocation)");
            standard.synchronize()
        }
    }
    
    /**
         Load current language
     */
    private static func loadSelectedLanguageCode(_ completion: @escaping (_ language:Language?) -> Swift.Void)->Swift.Void{
        let standard = UserDefaults.standard;
        if let val = standard.data(forKey: "\(self.appKey!)_\(storageLocation)") {
            if let storedLanguage = NSKeyedUnarchiver.unarchiveObject(with: val) as? Language {
                return completion(storedLanguage)
            }
        }
        let defs = UserDefaults.standard
        let languages:NSArray = (defs.object(forKey: "AppleLanguages") as? NSArray)!
        let current:String  = languages.object(at: 0) as! String
        languageFromAvailableLanguages(languagecode: current, completion: completion)
        
    }
    
    private static func languageFromAvailableLanguages(languagecode:String, completion: @escaping (_ language:Language?) -> Swift.Void){
        let current = languagecode
        self.availableLanguages { (languages) in
            if let language = findLanguage(languages: languages, languageKey: current) {
                return completion(language)
            }
            if current.contains("-") {
                let currentComponents = current.components(separatedBy: "-")
                let reducedCurrentComponents = currentComponents[0..<(currentComponents.count-1)]
                let newCurrent = reducedCurrentComponents.joined(separator: "-")
                if let language = findLanguage(languages: languages, languageKey: newCurrent) {
                    return completion(language)
                }
                if newCurrent.contains("-") {
                    let finalCurrentComponents = newCurrent.components(separatedBy: "-")
                    let finalReducedCurrentComponents = finalCurrentComponents[0..<(finalCurrentComponents.count-1)]
                    let finalNewCurrent = finalReducedCurrentComponents.joined(separator: "-")
                    if let language = findLanguage(languages: languages, languageKey: finalNewCurrent) {
                        return completion(language)
                    }
                }
            }
            return completion(nil)
        }
    }
    
    /**
         Find a language by code within language array
     */
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
        if val == true,self.liveEnabled == false, let language = self.language {
            self.loadLanguage(language);
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
        guard let appKey = self.appKey else {
            return
        }
        let standard = UserDefaults.standard;
        standard.set(translation, forKey: "\(appKey)_\(code)");
        standard.synchronize()
    }
    
    /**
        Load localization from local storage
        - Parameter code: language 2 character code
    */
    public static func loadLanguageFromDisk(code:String){
        guard let appKey = self.appKey else {
            return
        }
        let standard = UserDefaults.standard
        guard let data = standard.object(forKey: "\(appKey)_\(code)") as? [AnyHashable : String] else {
            return
        }
        self.loadedLanguageTranslations = data;
        NotificationCenter.default.post(name: Localization.ALL_CHANGE, object: self)
    }
    /**
     Request localization
     - Parameter code: language 2 character code
     */
    private static func loadLanguage(_ language:Language){
        self.loadLanguage(language: language) {
            return;
        }
    }
    
    /**
        Request localization
        - Parameter code: language 2 character code
     */
    private static func loadLanguage(language:Language, _ completion: @escaping () -> Swift.Void){
        guard let appKey = self.appKey else {
            return
        }
        self.loadLanguageFromDisk(code: language.key);
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlString = Localization.server+"/api/app/\(appKey)/language/\(language.key)"
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
                    saveLanguageToDisk(code: language.key, translation: self.loadedLanguageTranslations!);
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
        guard let appKey = self.appKey, let url = URL(string: "\(server)/app/#/app/\(appKey)") else {
            return
        }
        
        print("LocalizationKit:", url)
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
        guard let url = URL(string: server) else {
            print("Start Socket URL Incorrect")
            return
        }
        
        socket = SocketIOClient(socketURL: url)
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
            if let dictionary = data[0] as? [AnyHashable : Any] {
                guard let meta = dictionary["meta"] as? String else {
                    return;
                }
                NotificationCenter.default.post(name: self.highlightEvent(localizationKey: meta), object: self)
            }
        })
        socket?.on("text", callback: {(data,ack) in
            if let dictionary = data[0] as? [AnyHashable : Any] {
                guard let meta = dictionary["meta"] as? String else {
                    return;
                }
                if let value = dictionary["value"] as? String {
                    self.loadedLanguageTranslations?[meta] = value
                    NotificationCenter.default.post(name: self.localizationEvent(localizationKey: meta), object: self)
                }
            }
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
        guard let appKey = self.appKey, let langCode = self.language?.key else{
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
        if let appKey = self.appKey, let languageCode = self.languageCode {
            let languageRoom = "\(appKey)_\(languageCode)"
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
        let languageCode = language
        self.languageFromAvailableLanguages(languagecode: languageCode) { (language) in
            if let lang = language {
                self.setLanguage(lang)
            }
        }
    }
    
    /**
     Set Language Code with completion call back
     - Parameter language: language 2 character code
     - Parameter completion: function called when language has been loaded
     */
    public static func setLanguage(_ language:String, _ completion: @escaping () -> Swift.Void){
        let languageCode = language
        self.languageFromAvailableLanguages(languagecode: languageCode) { (language) in
            if let lang = language {
                self.setLanguage(lang, completion)
            }
        }
    }
    
    public static func setLanguage(_ language:Language){
        self.setLanguage(language) {
            return;
        }
    }
    
    public static func setLanguage(_ languageNew:Language, _ completion: @escaping () -> Swift.Void){
        if language?.key != languageNew.key {
            self.leaveLanguageRoom();
            _language = languageNew
            self.loadLanguage(language: languageNew, {
                completion();
            })
        }else{
            completion();
        }
    }
    
    /**
 
    */
    
    public static func set(_ key:String,value:String, language:String? = nil){
        guard let appKey = self.appKey else {
            print("You havent specified an app key")
            return
        }
        var data = ["appuuid":appKey, "key":key, "value":value, "language": Localization.languageCode!]
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
        guard let appKey = self.appKey else {
            print("Cannot get without appkey")
            return alternate
        }
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
                    self.sendMessage(type: "key:add", data: ["appuuid":appKey, "key":key, "language":buildLanguageCode, "raw":alternate])
                }else{
                    self.sendMessage(type: "key:add", data: ["appuuid":appKey, "key":key, "language":buildLanguageCode])
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


