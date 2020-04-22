//
//  ViewController.swift
//  KeyChainTest_swift
//
//  Created by 김민영 on 2020/04/22.
//  Copyright © 2020 KIMMINYOUNG. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate{
    
    @IBOutlet weak var saveValue: UITextField!
    @IBOutlet weak var saveKey: UITextField!
    
    @IBOutlet weak var findKey: UITextField!
    
    @IBOutlet weak var resLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //델리게이트 설정
        saveValue.delegate = self
        saveKey.delegate = self
        
        findKey.delegate = self
        //라이트 모드 강제
        self.overrideUserInterfaceStyle = .light
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func saveBtn(_ sender: Any) {
        print("save value : \(String(describing: saveValue.text))")
        print("save key : \(String(describing: saveKey.text))")
        let resStatus = saveKeyChain(key: saveKey.text!, data: Data((saveValue.text)!.utf8))
        
        self.showAlertMsg(msg: resStatus ? "true":"false")
    }
    
    @IBAction func updateBtn(_ sender: Any) {
        print("update value : \(String(describing: saveValue.text))")
        print("update key : \(String(describing: saveKey.text))")
        let resStatus = updateKeyChain(key: saveKey.text!, data: Data((saveValue.text)!.utf8))
        
        self.showAlertMsg(msg: resStatus ? "true":"false")
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        print("delete key : \(String(describing: saveKey.text))")
        let resStatus = deleteKeyChain(key: saveKey.text!)
        self.showAlertMsg(msg: resStatus ? "true":"false")
    }
    
    @IBAction func findBtn(_ sender: Any) {

        guard LoadKeyChain(key: findKey.text!) != nil else {
            self.showAlertMsg(msg: "데이터가 없습니다.")
            return
        }
        
        let resData = LoadKeyChain(key: findKey.text!)
        
        print("find data -> String : \(String(decoding: resData!, as: UTF8.self))")
        self.showAlertMsg(msg: String(decoding: resData!, as: UTF8.self))
        
        resLabel.text = String(decoding: resData!, as: UTF8.self)
    }
    
        
    func saveKeyChain(key:String, data:Data)->Bool{
        let encodeKey = Data(key.utf8)
        
        let serviceName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        
        var query = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrGeneric as String : encodeKey,
            kSecAttrAccount as String : encodeKey,
            kSecAttrService as String : serviceName
        ] as [String : Any]
        
        //defaultKeyChain
        
        query.updateValue(data, forKey: kSecValueData as String)
        
        print("saveKeyChain // query : \(query)")
        
        SecItemDelete(query as CFDictionary)
        
        let status : OSStatus = SecItemAdd(query as CFDictionary, nil)

        return status == noErr
    }
    
    func LoadKeyChain(key:String) -> Data?{
        let encodeKey = Data(key.utf8)
        
        let serviceName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        
        var query = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrGeneric as String : encodeKey,
            kSecAttrAccount as String : encodeKey,
            kSecAttrService as String : serviceName
        ] as [String : Any]
        
        //defaultKeyChain
        
        query.updateValue(kSecMatchLimitOne as String, forKey: kSecMatchLimit as String)
        query.updateValue(kCFBooleanTrue as CFBoolean, forKey: kSecReturnData as String)
        
        var dataTypeRef : AnyObject?
        
        let status = withUnsafeMutablePointer(to: &dataTypeRef)
            {
                SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
            }
            print(status)
            if status == errSecSuccess{
                if let data = dataTypeRef as! Data?{
                    print(String(decoding: data, as: UTF8.self))
                    return data
                }
            }
            //errSecItemNotFound -25300
        
            return nil
    }
    
    func deleteKeyChain(key:String) -> Bool {
        
        let encodeKey = Data(key.utf8)
        
        let serviceName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        
        let query = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrGeneric as String : encodeKey,
            kSecAttrAccount as String : encodeKey,
            kSecAttrService as String : serviceName
        ] as [String : Any]
        
        //defaultKeyChain
        
        let status : OSStatus = SecItemDelete(query as CFDictionary)
        
        return status == noErr
    }
    
    func updateKeyChain(key:String, data:Data) -> Bool {

        let encodeKey = Data(key.utf8)
        
        let serviceName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        
        let query = [
            kSecClass as String : kSecClassGenericPassword as String,
            kSecAttrGeneric as String : encodeKey,
            kSecAttrAccount as String : encodeKey,
            kSecAttrService as String : serviceName
        ] as [String : Any]
        
        //defaultKeyChain
        
        let updateQuery = [
            kSecValueData as String : data
        ] as [String : Any]
        
        let status : OSStatus = SecItemUpdate(query as CFDictionary, updateQuery as CFDictionary)
        
        return status == noErr
    }
    
    func clearKeyChain() -> Bool{
        let query = [
            kSecClass as String : kSecClassGenericPassword
        ] as [String:Any]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        return status == noErr
        
    }
    
    func showAlertMsg(msg:String){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "결과", message: msg, preferredStyle: UIAlertController.Style.alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
}

