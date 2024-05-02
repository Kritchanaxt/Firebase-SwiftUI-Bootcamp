//
//  AuthenticationViewModel.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 8/5/2567 BE.
//

import Foundation

// ประกาศคลาสนี้จะทำงานบน Main thread เสมอ
@MainActor

// ประกาศคลาส AuthenticationViewModel เป็น ObservableObject ที่ใช้เก็บข้อมูลและโมเดลที่เกี่ยวข้องกับการลงชื่อเข้าใช้
final class AuthenticationViewModel: ObservableObject {
        
    // สร้างฟังก์ชัน signInGoogle เพื่อทำการลงชื่อเข้าใช้ด้วยบัญชี Google โดยใช้ async/await เพื่อจัดการกับโค้ดแบบ asynchronous
    func signInGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthenticationManager.shared.signInWithGoogle(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)     }
    
    // สร้างฟังก์ชัน signInApple เพื่อทำการลงชื่อเข้าใช้ด้วยบัญชี Apple โดยใช้ async/await เช่นเดียวกัน
    func signInApple() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    // สร้างฟังก์ชัน signInAnonymous เพื่อทำการลงชื่อเข้าใช้แบบไม่ระบุตัวตน โดยใช้ async/await เช่นเดียวกัน
    func signInAnonymous() async throws {
        let authDataResult = try await AuthenticationManager.shared.signInAnonymous()
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
}
