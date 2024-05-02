//
//  SignInAppleHelper.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 6/5/2567 BE.
//

// Import ไลบรารี Foundation เพื่อใช้ในการสนับสนุนฟังก์ชันพื้นฐานของ Swift และการจัดการกับข้อมูลเชิงพื้นฐาน เช่น การสร้างและใช้งานข้อมูล String, Data, Error, และอื่นๆ
import Foundation

// Import ไลบรารี SwiftUI ใช้ในการสร้างอินเทอร์เฟซและองค์ประกอบของ SwiftUI ที่ใช้ในการสร้าง UI สำหรับแอปพลิเคชัน
import SwiftUI

// Import ไลบรารี AuthenticationServices ใช้ในการจัดการกับการตรวจสอบสิทธิ์การใช้งาน เช่น การเข้าสู่ระบบด้วย Apple ID และการใช้งาน OAuth อื่นๆ
import AuthenticationServices

// Import ไลบรารี CryptoKit ใช้ในการสร้างและใช้งานคริปโตแกรฟต์ เพื่อการเข้ารหัสและถอดรหัสข้อมูลในรูปแบบต่างๆ
import CryptoKit

struct SignInWithAppleButtonViewRepresentable: UIViewRepresentable {
    
    let type: ASAuthorizationAppleIDButton.ButtonType
    let style: ASAuthorizationAppleIDButton.Style
    
    // ฟังก์ชันที่ใช้สร้างและคืนค่า ASAuthorizationAppleIDButton เมื่อเริ่มต้นการสร้าง UIView.
    func makeUIView(context: Context) -> ASAuthorizationAppleIDButton {
        ASAuthorizationAppleIDButton(authorizationButtonType: type, authorizationButtonStyle: style)
    }
    
    // ฟังก์ชันที่ไม่ทำอะไรเมื่อมีการอัพเดต UIView.
    func updateUIView(_ uiView: ASAuthorizationAppleIDButton, context: Context) {
        
    }
    
}

struct SignInWithAppleResult {
    let token: String
    let nonce: String
    let name: String?
    let email: String?
}

@MainActor

// กำหนดให้ SignInAppleHelper คลาสสุดท้ายที่ไม่สามารถสืบทอดและมีการสืบทอดได้
// NSObject ใช้ในการจัดการวัตถุ Objective-C ใน Swift ซึ่งมักใช้เพื่อประสิทธิภาพและการใช้ APIs ของ Objective-C ในแอป Swift
final class SignInAppleHelper: NSObject {
    
    private var currentNonce: String?
    
    // ทำให้เป็น closure ที่รับผลลัพธ์จากการลงชื่อเข้าใช้ด้วย Apple ID และไม่มีการส่งค่าคืน และมีค่าเริ่มต้นเป็น nil ซึ่งหมายถึงยังไม่มี closure ถูกกำหนดให้กับ completionHandler อีก
    private var completionHandler: ((Result<SignInWithAppleResult, Error>) -> Void)? = nil
    
    // ฟังก์ชัน async ที่ใช้เริ่มต้นกระบวนการการลงชื่อเข้าใช้ด้วย Apple ID และคืนค่าผลลัพธ์ SignInWithAppleResult.
    func startSignInWithAppleFlow() async throws -> SignInWithAppleResult {
        try await withCheckedThrowingContinuation { continuation in
            self.startSignInWithAppleFlow { result in
                switch result {
                case .success(let signInAppleResult):
                    continuation.resume(returning: signInAppleResult)
                    return
                case .failure(let error):
                    continuation.resume(throwing: error)
                    return
                }
            }
        }
    }
    
    // ฟังก์ชันที่ใช้เริ่มต้นกระบวนการการลงชื่อเข้าใช้ด้วย Apple ID และใช้ completion handler เพื่อรับผลลัพธ์.
    func startSignInWithAppleFlow(completion: @escaping (Result<SignInWithAppleResult, Error>) -> Void) {
        guard let topVC = Utilities.shared.topViewController() else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        let nonce = randomNonceString()
        currentNonce = nonce
        completionHandler = completion
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = topVC
        authorizationController.performRequests()
    }
    
    // ฟังก์ชันที่ใช้สร้าง nonce สุ่มของความยาวที่กำหนด.
    // MARK: Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }

    @available(iOS 13, *)
    
    // ฟังก์ชันที่ใช้ในการแฮชข้อมูลโดยใช้ SHA256 algorithm.
    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    
}

// Extension ของ SignInAppleHelper เพื่อดำเนินการเมื่อการยืนยันตัวตนด้วย Apple ID เสร็จสิ้นหรือเกิดข้อผิดพลาด.
extension SignInAppleHelper: ASAuthorizationControllerDelegate {
    
    // เมื่อลงชื่อเข้าใช้ด้วย Apple ID เสร็จสมบูรณ์ ฟังก์ชันจะดึงข้อมูลการใบรับรอง Apple ID และตรวจสอบค่าที่สำคัญ 
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard
            let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let appleIDToken = appleIDCredential.identityToken,
            let idTokenString = String(data: appleIDToken, encoding: .utf8),
            let nonce = currentNonce else {
            completionHandler?(.failure(URLError(.badServerResponse)))
            return
        }
        let name = appleIDCredential.fullName?.givenName
        let email = appleIDCredential.email

        let tokens = SignInWithAppleResult(token: idTokenString, nonce: nonce, name: name, email: email)
        completionHandler?(.success(tokens))
    }
    
    // เมื่อเกิดข้อผิดพลาดในกระบวนการลงชื่อเข้าใช้ด้วย Apple ID จะแสดงข้อผิดพลาดที่เกิดขึ้น และเรียกใช้ completionHandler โดยส่งผลลัพธ์การล้มเหลวที่มีรหัสเป็น cannotFindHost ในกรณีที่ไม่สามารถหาโฮสต์ได้
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Sign in with Apple errored: \(error)")
        completionHandler?(.failure(URLError(.cannotFindHost)))
    }

}

// Extension ของ UIViewController เพื่อให้เป็น Presentation Context สำหรับ ASAuthorizationController.
extension UIViewController: ASAuthorizationControllerPresentationContextProviding {
    
    // ฟังก์ชัน presentationAnchor ส่งคืน ASPresentationAnchor โดยใช้หน้าต่างของ view ปัจจุบันใน SwiftUI ในการนำเสนอ ASAuthorizationController
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
