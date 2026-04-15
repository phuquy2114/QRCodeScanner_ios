//
//  SoundManager.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 8/4/26.
//

import Foundation

class SoundManager {
    
    func checkBoolValue(key: String) -> Bool {
        let check = UserDefaults.standard.object(forKey: key)
        if check == nil {
            // Ghi trực tiếp thay vì gọi setBoolValue để tránh Deadlock (kẹt hàng đợi)
            UserDefaults.standard.set(true, forKey: key)
            return true
        }
        let value = UserDefaults.standard.bool(forKey: key)
        print("\(key) - \(value)") // 0
        return value
    }
    
    func setBoolValue(value: Bool, key: String) {
        print("\(key) - \(value)")
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getBoolValue(key: String) -> Bool {
        return UserDefaults.standard.bool(forKey: key)
    }
    
}
