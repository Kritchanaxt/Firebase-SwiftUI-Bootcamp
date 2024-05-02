//
//  SettingsView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 2/5/2567 BE.
//

import SwiftUI

struct SettingsView: View {
    
    //ใช้เพื่อสร้าง viewModel และเก็บค่า state ของ SettingsViewModel.
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                        
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button(role: .destructive) {
                Task {
                    do {
                        try viewModel.signOut()
                        showSignInView = true
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Delete account")
            }
            
            // ตรวจสอบว่ามีการตรวจสอบอีเมลในรายการ providers ของ viewModel หรือไม่ และแสดงส่วนของการทำงานเกี่ยวกับอีเมลใน emailSection ของ SettingsView ถ้ามี provider อีเมลอยู่ในรายการนั้น.
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            // ตรวจสอบว่าผู้ใช้เป็น anonymous หรือไม่ และแสดงส่วนของการเชื่อมโยงบัญชีใน anonymousSection ของ SettingsView ถ้าเป็น anonymous ซึ่งรวมถึงการเชื่อมโยงบัญชี Google, Apple, หรืออีเมล.
            if viewModel.authUser?.isAnonymous == true {
                anonymousSection
            }
        }
        .onAppear {
            viewModel.loadAuthProviders()
            viewModel.loadAuthUser()
        }
        .navigationBarTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}

extension SettingsView {
    
    private var emailSection: some View {
        Section {
            Button("Reset password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("RESET PASSWORD!")
                        
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update password") {
                Task {
                    do {
                        try await viewModel.updatePassword()
                        print("PASSWORD UPDATED!")
                        
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update email") {
                Task {
                    do {
                        try await viewModel.updateEmail()
                        print("EMAIL UPDATED!")
                        
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Email functions")
        }
    }
    
    private var anonymousSection: some View {
        Section {
            Button("Link Google Account") {
                Task {
                    do {
                        try await viewModel.linkGoogleAccount()
                        print("GOOGLE LINKED!")
                        
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link Apple Account") {
                Task {
                    do {
                        try await viewModel.linkAppleAccount()
                        print("APPLE LINKEd!")
                        
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Link Email Account") {
                Task {
                    do {
                        try await viewModel.linkEmailAccount()
                        print("EMAIL LINKED!")
                        
                    } catch {
                        print(error)
                    }
                }
            }
        } header: {
            Text("Create account")
        }
    }
}
