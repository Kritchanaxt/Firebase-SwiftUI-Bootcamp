//
//  AuthenticationManager.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 2/5/2567 BE.
//

import Foundation
import FirebaseAuth

//  โครงสร้างที่ใช้ในการเก็บข้อมูลผู้ใช้
struct AuthDataResultModel {
    let uid: String
    let email: String?
    let photoUrl: String?
    let isAnonymous: Bool
    
    // ใช้ในการสร้างอ็อบเจ็กต์จากข้อมูลผู้ใช้ที่ได้รับจากการยืนยันตัวตน โดยกำหนดค่า UID, อีเมล, URL ของรูปโปรไฟล์, และสถานะการเป็น anonymous ของผู้ใช้ให้กับอ็อบเจ็กต์ที่สร้างขึ้น โดยดึงข้อมูลเหล่านี้จากข้อมูลผู้ใช้ที่รับเข้ามาในคอนสตรักเตอร์
    init(user: User) {
        self.uid = user.uid
        self.email = user.email
        self.photoUrl = user.photoURL?.absoluteString
        self.isAnonymous = user.isAnonymous
    }
}

// Enum ที่ใช้ในการระบุผู้ให้บริการ (Provider) ในการยืนยันตัวตน
enum AuthProviderOption: String {
    case email = "password"
    case google =  "google.com"
    case apple = "apple.com"
}

// ถูกประกาศเป็น final ซึ่งหมายความว่าไม่สามารถสืบทอดจากคลาสนี้ได้
final class AuthenticationManager {
    
    static let shared = AuthenticationManager()
    private init() { }
    
    // ฟังก์ชันสำหรับการดึงข้อมูลผู้ใช้ที่ได้ยืนยันตัวตนแล้ว
    func getAuthenticatedUser() throws -> AuthDataResultModel {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        return AuthDataResultModel(user: user)
    }
    
    // ฟังก์ชันสำหรับการดึงรายการผู้ให้บริการที่สามารถใช้ในการยืนยันตัวตน
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        var providers: [AuthProviderOption] = []
        for provider  in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        print(providers)
        return providers
    }
    
    // ฟังก์ชันสำหรับการลงชื่อออก
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    // ฟังก์ชันสำหรับการลบบัญชีผู้ใช้
    func delet() async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        try await user.delete()
    }
}

// MARK: SIGN IN EMAIL
extension AuthenticationManager {
    
    //MARK: ฟังก์ชันที่เกี่ยวข้องกับการลงชื่อเข้าใช้ผ่าน email และการจัดการข้อมูลบัญชีผู้ใช้
    
    @discardableResult
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
}

// MARK: SIGN IN SSO
extension AuthenticationManager {
    
    // ฟังก์ชันที่เกี่ยวข้องกับการลงชื่อเข้าใช้ผ่าน Google
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    } 
    
    // ฟังก์ชันที่เกี่ยวข้องกับการลงชื่อเข้าใช้ผ่าน Apple
    @discardableResult
    func signInWithApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await signIn(credential: credential)
    }
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}

// MARK: SIGN IN ANONYMOUS

extension AuthenticationManager {
    
    // MARK: ฟังก์ชันสำหรับการลงชื่อเข้าใช้โดยไม่ระบุตัวตน (anonymous) และการเชื่อมโยงบัญชีผู้ใช้กับ provider อื่นๆ
    
    @discardableResult
    func signInAnonymous() async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signInAnonymously()
        return AuthDataResultModel(user: authDataResult.user)
    }
    
    func linkEmail(email: String, password: String) async throws -> AuthDataResultModel {
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        return try await linkCredential(credential: credential)
    }
    
    func linkGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await linkCredential(credential: credential)
    }
    
    func linkApple(tokens: SignInWithAppleResult) async throws -> AuthDataResultModel {
        let credential = OAuthProvider.credential(withProviderID: AuthProviderOption.apple.rawValue, idToken: tokens.token, rawNonce: tokens.nonce)
        return try await linkCredential(credential: credential)
    }
    
    // เชื่อมโยงบัญชีผู้ใช้ปัจจุบันกับผู้ใช้ใหม่ที่มาจากการลงชื่อเข้าใช้ผ่าน provider อื่น ๆ 
    // และส่งคืนข้อมูลผู้ใช้ใหม่ที่เชื่อมโยงแล้วในรูปแบบ AuthDataResultModel ถ้าไม่สามารถเชื่อมโยงได้ จะส่งข้อผิดพลาด URLError(.badURL) ออกไป
    private func linkCredential(credential: AuthCredential) async throws -> AuthDataResultModel{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badURL)
        }
        
        let authDataResult = try await user.link(with: credential)
        return AuthDataResultModel(user: authDataResult.user)
    }
}
