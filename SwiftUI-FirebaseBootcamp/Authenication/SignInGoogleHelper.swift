//
//  SignInGoogleHelper.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 3/5/2567 BE.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
}

// ถูกประกาศเป็น final ซึ่งหมายความว่าไม่สามารถสืบทอดจากคลาสนี้ได้ 
final class SignInGoogleHelper {
    
    @MainActor
    
    // ฟังก์ชัน asynchronous ที่ใช้ในการลงชื่อเข้าใช้ด้วย Google โดยใช้ GIDSignIn และส่งผลลัพธ์เป็น GoogleSignInResultModel ที่มี idToken, accessToken, ชื่อ, และอีเมล์ของผู้ใช้ที่ลงชื่อเข้าใช้ หากมีข้อผิดพลาดจะส่ง URLError ออกไป
    func signIn() async throws -> GoogleSignInResultModel{
        guard let topVC = Utilities.shared.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        
        let accessToken = gidSignInResult.user.accessToken.tokenString
        let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email: email)
        return tokens
    }
    
}
