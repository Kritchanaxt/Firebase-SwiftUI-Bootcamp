//
//  ProfileView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 8/5/2567 BE.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    // สร้าง ViewModel สำหรับจัดการข้อมูลผู้ใช้
    @StateObject private var viewModel = ProfileViewModel()
    
    // Binding สำหรับการแสดงหรือซ่อนหน้าจอการลงชื่อเข้าใช้
    @Binding var showSignInView: Bool
    
    // State สำหรับจัดเก็บรายการที่เลือกจาก PhotosPicker
    @State private var selectedItem: PhotosPickerItem? = nil
    
    // State สำหรับจัดเก็บ URL ของรูปภาพที่เลือก
    @State private var url: URL? = nil
    
    // ตัวเลือกของ preferences ที่ผู้ใช้สามารถเลือกได้
    let preferenceOptions: [String] = ["Sports", "Movies", "Books"]
    
    private func preferenceIsSelected(text: String) -> Bool {
        
        // ตรวจสอบว่าตัวเลือก preferences ถูกเลือกแล้วหรือยัง
        viewModel.user?.preferences?.contains(text) == true
    }
                                       
    var body: some View {
        List {
            if let user = viewModel.user {
                
                // แสดง User ID
                Text("UserId: \(user.userId)")
                
                if let isAnonymous = user.isAnonymous {
                    
                    // แสดงสถานะการเป็นผู้ใช้แบบไม่ระบุตัวตน
                    Text("Is Anonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button {
                    
                    // ปุ่มสำหรับสลับสถานะการเป็นสมาชิกพรีเมียม
                    viewModel.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
                
                VStack {
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { string in
                            Button(string) {
                                if preferenceIsSelected(text: string) {
                                    
                                    // ลบ preference หากถูกเลือกแล้ว
                                    viewModel.removeUserPreference(text: string)
                                } else {
                                    
                                    // เพิ่ม preference หากยังไม่ได้เลือก
                                    viewModel.addUserPreference(text: string)
                                }
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            
                            // เปลี่ยนสีปุ่มตามสถานะการเลือก
                            .tint(preferenceIsSelected(text: string) ? .green : .red)
                        }
                    }
                    
                    Text("User preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        // แสดงรายการ preferences ที่ผู้ใช้เลือก
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    if user.favoriteMovie == nil {
                        
                        // เพิ่มหนังโปรดถ้ายังไม่ได้เลือก
                        viewModel.addFavoriteMovie()
                    } else {
                        
                        // ลบหนังโปรดถ้าเลือกแล้ว
                        viewModel.removeFavoriteMovie()
                    }
                } label: {
                    Text("Favorite Movie: \((user.favoriteMovie?.title ?? ""))")
                }
                
                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    
                    // PhotosPicker สำหรับเลือกภาพ
                    Text("Select a photo")
                }
                
                // แสดงภาพ
                if let urlString = viewModel.user?.profileImagePathUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                    }
                }
                
                if viewModel.user?.profileImagePath != nil {
                    Button("Delete image") {
                        
                        // ปุ่มลบภาพ
                        viewModel.deleteProfileImage()
                    }
                }
            }
        }
        .task {
            
            // โหลดข้อมูลผู้ใช้เมื่อแสดงผล
            try? await viewModel.loadCurrentUser()
        }
        .onChange(of: selectedItem, perform: { newValue in
            if let newValue {
                
                // บันทึกรูปภาพที่เลือก
                viewModel.saveProfileImage(item: newValue)
            }
        })
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    
                    // ลิงก์ไปยังหน้าจอตั้งค่า
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    RootView()
}
