//
//  CreateQRCodeViewModel.swift
//  QRCodeScanner
//
//  Created by Ngo Nghia on 20/3/26.
//

import Foundation
import Combine

class CreateQRCodeViewModel : BaseViewModel {
    @Published private(set) var qrResult: String? = nil

    func startScan(_ code: String) {
        perform(key: "a") {
            
        }
        perform(key: "scan") {
//            let result = try await self.qrService.decode(code)
//            self.qrResult = result
//            self.setSuccess("Quét thành công!")
        }
    }
    
    
}
