//
//  SettingsViewModel.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//

import Combine
import SwiftUI
import AudioToolbox

@MainActor
class SettingsViewModel: BaseViewModel {
    
    override init() {
        super.init()
    }
    
    func onChangeToggle(item: SettingSound, value: Bool) {
        
        // Chỉ demo phản hồi (feedback) khi người dùng bật công tắc (value == true)
        guard value else { return }
        
        switch item {
        case .vibrate:
            // Tạo chế độ rung phản hồi xúc giác (Haptic Feedback) mức độ vừa phải
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.prepare()
            generator.impactOccurred()
            
        case .beep:
            // Phát tiếng "Bíp" bằng âm thanh hệ thống của Apple (ID 1052 là tiếng bíp ngắn)
            AudioServicesPlaySystemSound(1052)
            
        case .autoFocus:
            // Auto Focus không có tiếng. Cấu hình đã được @AppStorage lưu tự động.
            // Màn hình Scanner (Camera) sẽ tự đọc UserDefaults để lấy giá trị này.
            break
            
        case .touchFocus:
            // Tương tự Auto Focus
            break
        }
    }
    
}

