//
//  SignInEmailView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 2/5/2567 BE.
//

import SwiftUI

struct SignInEmailView: View {
    
    // ประกาศ StateObject เพื่อเก็บ SignInEmailViewModel ซึ่งจะถูกอัปเดตโดยอัตโนมัติเมื่อมีการเปลี่ยนแปลงในข้อมูล
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool

    var body: some View {
        VStack {
            
            // สร้าง TextField สำหรับกรอกอีเมล โดยที่ข้อมูลจะถูกผูกกับตัวแปร email ใน SignInEmailViewModel
            TextField("Email...", text: $viewModel.email)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            // สร้าง SecureField สำหรับกรอกรหัสผ่าน โดยที่ข้อมูลจะถูกผูกกับตัวแปร password ใน SignInEmailViewModel
            SecureField("Password...", text: $viewModel.password)
                .padding()
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            
            Button {
                Task {
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                    
                    do {
                        try await viewModel.signIn()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Sign In")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 50)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(30)
            }
            
            // สร้าง Spacer เพื่อย้าย UI ไปไว้ที่ด้านล่าง
            Spacer()
        }
        .padding()
        
        // กำหนดหัวเรื่องของหน้าจอให้เป็น "Sign In With Email"
        .navigationTitle("Sign In With Email")
    }
}

#Preview {
    SignInEmailView(showSignInView:  .constant(false) )
}
