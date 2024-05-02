//
//  SignInEmailViewModel.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 8/5/2567 BE.
//

import Foundation

// ประกาศคลาสนี้ทำงานบน Main thread เสมอ
@MainActor

// ประกาศคลาส SignInEmailViewModel ให้เป็น ObservableObject ที่ใช้เก็บข้อมูลและโมเดลที่เกี่ยวข้องกับการลงชื่อเข้าใช้ด้วยอีเมลและรหัสผ่าน
final class SignInEmailViewModel: ObservableObject {
    
    // ใช้ @Published เพื่อทำให้สามารถติดตามการเปลี่ยนแปลงของค่าได้และอัปเดต UI
    @Published var email = ""
    @Published var password = ""
    
    // ฟังก์ชัน signUp และ signIn ใช้ในการลงชื่อเข้าใช้ด้วยอีเมลและรหัสผ่าน โดยใช้ async/await สำหรับการทำงานแบบ asynchronous
    func signUp() async throws {
        
        // เช็คว่า email และ password ไม่ว่างเปล่าหรือไม่ ถ้ามีการละเว้น email หรือ password ว่างเปล่าจะแสดงข้อความ "No email or password found." ใน console และฟังก์ชันจะจบการทำงานทันที
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
        // ใช้ await เพื่อรอให้กระบวนการเสร็จสิ้นก่อนที่จะดำเนินการต่อ
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signIn() async throws {
        
        // เช็คว่า email และ password ไม่ว่างเปล่าหรือไม่ ถ้ามีการละเว้น email หรือ password ว่างเปล่าจะแสดงข้อความ "No email or password found." ใน console และฟังก์ชันจะจบการทำงานทันที
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password found.")
            return
        }
        
       // ใช้ await เพื่อรอให้กระบวนการเสร็จสิ้นก่อนที่จะดำเนินการต่อ
       try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
