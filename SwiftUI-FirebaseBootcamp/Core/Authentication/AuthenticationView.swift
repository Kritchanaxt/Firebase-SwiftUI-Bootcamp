//
//  AuthenticationView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 2/5/2567 BE.
//

import SwiftUI

// Import ไลบรารี GoogleSignIn เพื่อใช้ในการลงชื่อเข้าใช้ด้วยบัญชี Google
import GoogleSignIn

// Import ไลบรารี GoogleSignInSwift เพื่อใช้ในการช่วยในกระบวนการลงชื่อเข้าใช้ด้วยบัญชี Google อย่างเชื่อถือได้
import GoogleSignInSwift


struct AuthenticationView: View {
    
    // สร้าง StateObject เพื่อเก็บ AuthenticationViewModel ซึ่งจะช่วยในการจัดการข้อมูลและการอัพเดต UI
    @StateObject private var viewModel = AuthenticationViewModel()
    
    // ประกาศคุณสมบัติ showSignInView เป็น Binding ซึ่งใช้ในการควบคุมการแสดงหน้าจอการลงชื่อเข้าใช้
    @Binding var showSignInView: Bool
        
    var body: some View {
        VStack {
            
            // การสร้างปุ่มลงชื่อเข้าใช้แบบไม่ระบุตัวตน
            Button(action: {
                
                // สร้าง Task ซึ่งใช้ในการจัดการกับโค้ดแบบ asynchronous
                Task {
                    do {
                        
                        // เรียกใช้ฟังก์ชัน signInAnonymous จาก ViewModel โดยใช้ await เพื่อรอให้ฟังก์ชันทำงานเสร็จสิ้นก่อนที่จะดำเนินการต่อ.
                        try await viewModel.signInAnonymous()
                        
                        // เมื่อการลงชื่อเข้าใช้สำเร็จโดยไม่ระบุตัวตน เซ็ตค่า showSignInView เป็น false เพื่อปิดหน้าจอการลงชื่อเข้าใช้.
                        showSignInView = false
                        
                      //  ในกรณีที่เกิดข้อผิดพลาดในขณะที่ทำงาน catch จะถูกเรียกใช้ เพื่อพิมพ์ error ที่เกิดขึ้นใน console เพื่อแสดงข้อผิดพลาดที่เกิดขึ้น.
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Sign In Anonymously")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
            })
            
            // การสร้างปุ่มลงชื่อเข้าใช้ด้วยบัญชี Email
            NavigationLink { // สร้าง NavigationLink เพื่อนำทางไปยังหน้าจอการลงชื่อเข้าใช้ด้วยอีเมล
                SignInEmailView(showSignInView: $showSignInView)
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            
            // การสร้างปุ่มลงชื่อเข้าใช้ด้วยบัญชี Google
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.signInGoogle()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
            
            // การสร้างปุ่มลงชื่อเข้าใช้ด้วยบัญชี Apple
            Button(action: {
                Task {
                    do {
                        try await viewModel.signInApple()
                        showSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                SignInWithAppleButtonViewRepresentable(type: .default, style: .black)
                    .allowsHitTesting(false)
            })
            .frame(height: 55)
            
            Spacer()
        }
        .padding()
        
        // กำหนดหัวเรื่องของหน้าจอใน NavigationView เป็น "Sign In"
        .navigationTitle("Sign In")
    }
}

#Preview {
    NavigationStack {
        AuthenticationView(showSignInView: .constant(false))
    }
}

