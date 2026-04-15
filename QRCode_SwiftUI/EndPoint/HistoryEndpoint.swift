//
//  HistoryEndpoint.swift
//  QRCode_SwiftUI
//
//  Created by Ngo Nghia on 7/4/26.
//
import Alamofire

// MARK: - Cách dùng: define endpoint cho từng feature
// Ví dụ cho History feature
enum HistoryEndpoint: APIEndpoint {
    case getAll
    case getOne(id: String)
    case delete(id: String)

    var path: String {
        switch self {
        case .getAll:          return "/history"
        case .getOne(let id):  return "/history/\(id)"
        case .delete(let id):  return "/history/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .getAll, .getOne: return .get
        case .delete:          return .delete
        }
    }
}

// MARK: - QR Endpoint
enum QREndpoint: APIEndpoint {
    case create
    case update(id: String)
    case uploadLogo(id: String)
    case downloadPDF(id: String)

    var path: String {
        switch self {
        case .create:               return "/qr"
        case .update(let id):       return "/qr/\(id)"
        case .uploadLogo(let id):   return "/qr/\(id)/logo"
        case .downloadPDF(let id):  return "/qr/\(id)/pdf"
        }
    }

    var method: HTTPMethod { .post }
}

// MARK: - User Endpoint
enum UserEndpoint: APIEndpoint {
    case me
    case updateProfile
    case updateAvatar
    case deleteAccount

    var path: String {
        switch self {
        case .me:              return "/user/me"
        case .updateProfile:   return "/user/me"
        case .updateAvatar:    return "/user/me/avatar"
        case .deleteAccount:   return "/user/me"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .me:            return .get
        case .updateProfile: return .patch
        case .updateAvatar:  return .post
        case .deleteAccount: return .delete
        }
    }
}

// MARK: - Usage examples in ViewModel
/*
 final class HistoryViewModel: BaseViewModel {
     @Published var items: [HistoryItem] = []

     override func onAppear() {
         Task { await run { try await fetchAll() } }
     }

     // GET danh sách
     private func fetchAll() async throws {
         items = try await NetworkService.shared.get(
             HistoryEndpoint.getAll,
             type: [HistoryItem].self
         )
     }

     // DELETE
     func delete(id: String) {
         Task {
             await run {
                 try await NetworkService.shared.delete(HistoryEndpoint.delete(id: id))
                 items.removeAll { $0.id == id }
             }
         }
     }
 }

 final class CreateViewModel: BaseViewModel {
     @Published var uploadProgress: Double = 0

     // POST với JSON body
     func createQR(payload: CreateQRRequest) {
         Task {
             await run {
                 let result: QRItem = try await NetworkService.shared.post(
                     QREndpoint.create,
                     body: payload,
                     type: QRItem.self
                 )
                 // dùng result...
             }
         }
     }

     // PATCH
     func updateProfile(payload: UpdateProfileRequest) {
         Task {
             await run {
                 let _: UserProfile = try await NetworkService.shared.patch(
                     UserEndpoint.updateProfile,
                     body: payload,
                     type: UserProfile.self
                 )
             }
         }
     }

     // UPLOAD ảnh logo + progress
     func uploadLogo(id: String, imageData: Data) {
         Task {
             await run {
                 let item = UploadItem.image(imageData, name: "logo", fileName: "logo.jpg")
                 let _: QRItem = try await NetworkService.shared.upload(
                     QREndpoint.uploadLogo(id: id),
                     items: [item],
                     progress: { [weak self] value in
                         self?.uploadProgress = value
                     },
                     type: QRItem.self
                 )
             }
         }
     }

     // DOWNLOAD PDF + progress
     func downloadPDF(id: String) {
         Task {
             await run {
                 let result = try await NetworkService.shared.download(
                     QREndpoint.downloadPDF(id: id),
                     fileName: "qr_\(id).pdf",
                     progress: { [weak self] value in
                         self?.uploadProgress = value
                     }
                 )
                 // result.fileURL là đường dẫn file đã lưu
                 print("Saved to:", result.fileURL)
             }
         }
     }
 }
 */

// MARK: - Cách gọi trong ViewModel
/*
 final class HistoryViewModel: BaseViewModel {

     @Published var items: [HistoryItem] = []

     override func onAppear() {
         Task { await run { try await self.fetchHistory() } }
     }

     private func fetchHistory() async throws {
         items = try await NetworkService.shared.request(
             HistoryEndpoint.getAll,
             type: [HistoryItem].self
         )
     }

     func delete(id: String) {
         Task {
             await run {
                 try await NetworkService.shared.requestVoid(
                     HistoryEndpoint.delete(id: id)
                 )
                 items.removeAll { $0.id == id }
             }
         }
     }
 }
 */
