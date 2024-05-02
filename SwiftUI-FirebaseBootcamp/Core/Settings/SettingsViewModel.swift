//
//  SettingsViewModel.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 8/5/2567 BE.
//

import Foundation

// ประกาศ attribute เพื่อระบุว่าคลาส SettingsViewModel และฟังก์ชันภายในมีการทำงานบน Main Actor ซึ่งเป็นหลักการที่ใช้ใน SwiftUI เพื่อป้องกันปัญหาการแก้ไข UI ใน background thread.
@MainActor

// ประกาศคลาส SettingsViewModel เป็น final class ที่ดำเนินการเป็น ObservableObject ซึ่งใช้ในการจัดการข้อมูลและสถานะที่อาจเปลี่ยนแปลงในแอปพลิเคชัน.
final class SettingsViewModel: ObservableObject {
    
    // ประกาศ Published property ซึ่งเมื่อมีการเปลี่ยนแปลงค่า จะอัปเดต UI ที่ใช้ค่านี้ด้วย.
    @Published var authProviders: [AuthProviderOption] = []
    
    // ประกาศ Published property สำหรับเก็บข้อมูลผู้ใช้ที่ลงชื่อเข้าใช้ โดย AuthDataResultModel ซึ่งเป็นโมเดลข้อมูลผู้ใช้จาก Firebase Authentication.
    @Published var authUser: AuthDataResultModel? = nil
    
    // ฟังก์ชันสำหรับโหลดโปรไฟล์การลงชื่อเข้าใช้จาก AuthenticationManager และอัปเดตค่าใน authProviders.
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    // ฟังก์ชันสำหรับโหลดข้อมูลผู้ใช้ที่ลงชื่อเข้าใช้จาก AuthenticationManager และอัปเดตค่าใน authUser.
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    // ฟังก์ชันสำหรับลงชื่อออกจากระบบโดยเรียกใช้ signOut() จาก AuthenticationManager.
    func signOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    // ฟังก์ชันสำหรับลบบัญชีผู้ใช้โดยเรียกใช้ delete() จาก AuthenticationManager โดยใช้ async/await.
    func deleteAccount() async throws {
        try await AuthenticationManager.shared.delet()
    }
    
    // ฟังก์ชันสำหรับรีเซ็ตรหัสผ่านโดยเรียกใช้ resetPassword(email:) จาก AuthenticationManager โดยใช้ async/await.
    func resetPassword() async throws {
        let authUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email =  authUser.email  else {
            throw URLError(.fileDoesNotExist)
        }
        
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    // ฟังก์ชันสำหรับอัปเดตอีเมลโดยเรียกใช้ updateEmail(email:) จาก AuthenticationManager โดยใช้ async/await.
    func updateEmail() async throws {
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    // ฟังก์ชันสำหรับอัปเดตรหัสผ่านโดยเรียกใช้ updatePassword(password:) จาก AuthenticationManager โดยใช้ async/await.
    func updatePassword() async throws {
        let password = "Hello123!"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    // ฟังก์ชันสำหรับเชื่อมโยงบัญชี Google โดยเรียกใช้ฟังก์ชันที่เกี่ยวข้องจาก SignInGoogleHelper และ AuthenticationManager โดยใช้ async/await.
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        self.authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    // ฟังก์ชันสำหรับเชื่อมโยงบัญชี Apple โดยเรียกใช้ฟังก์ชันที่เกี่ยวข้องจาก SignInAppleHelper และ AuthenticationManager โดยใช้ async/await.
    func linkAppleAccount() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        self.authUser = try await AuthenticationManager.shared.linkApple(tokens: tokens)
    }
    
    // ฟังก์ชันสำหรับเชื่อมโยงบัญชีอีเมลโดยเรียกใช้ linkEmail(email: password:) จาก AuthenticationManager โดยใช้ async/await.
    func linkEmailAccount() async throws {
        let email = "anotherEmail@gmail.com"
        let password = "Hello123!"
        self.authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }

}
