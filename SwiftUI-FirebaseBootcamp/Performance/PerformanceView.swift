//
//  PerformanceView.swift
//  SwiftUI-FirebaseBootcamp
//
//  Created by Kritchanaxt_. on 18/5/2567 BE.
//

import SwiftUI
import FirebasePerformance

final class PerformanceManager {
    
    // คลาสนี้เป็น Singleton ที่ใช้ในการจัดการการติดตามประสิทธิภาพการทำงานของแอปพลิเคชัน
    static let shared = PerformanceManager()
    private init() { }
    
    private var traces: [String:Trace] = [:]
    
    //  เริ่มการติดตามด้วยชื่อที่กำหนด
    func startTrace(name: String) {
        let trace = Performance.startTrace(name: name)
        traces[name] = trace
    }
    
    // ตั้งค่า value สำหรับ attribute ของการติดตาม
    func setValue(name: String, value: String, forAttribute: String) {
        guard let trace = traces[name] else { return }
        trace.setValue(value, forAttribute: forAttribute)
    }
    
    // หยุดการติดตาม
    func stopTrace(name: String) {
        guard let trace = traces[name] else { return }
        trace.stop()
        traces.removeValue(forKey: name)
    }
}

//  View ที่ใช้แสดงเนื้อหาและเรียกใช้งาน PerformanceManager เพื่อเริ่มและหยุดการติดตาม
struct PerformanceView: View {
    
    @State private var title: String = "Some Title"
    
    var body: some View {
        Text("Hello, World!")
        
            // เรียกใช้ฟังก์ชัน configure และ downloadProductsAndUploadToFirebase เมื่อ View ปรากฏบนหน้าจอ และเริ่มการติดตามหน้าจอ
            .onAppear {
                configure()
                downloadProductsAndUploadToFirebase()
                
                // เริ่มการติดตามหน้าจอ
                PerformanceManager.shared.startTrace(name: "performance_screen_time")
            }
            
            // หยุดการติดตามหน้าจอเมื่อ View หายไปจากหน้าจอ
            .onDisappear {
                
                // หยุดการติดตามหน้าจอ
                PerformanceManager.shared.stopTrace(name: "performance_screen_time")
            }
    }
    
    // จำลองการโหลดข้อมูลและติดตามสถานะการทำงาน
    private func configure() {
        
        // เริ่มการติดตามการโหลด View
        PerformanceManager.shared.startTrace(name: "performance_view_loading")
        
        Task {
            
            // จำลองการโหลดข้อมูล
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            PerformanceManager.shared.setValue(name: "performance_view_loading", value: "Started downloading", forAttribute: "func_state")

            try? await Task.sleep(nanoseconds: 2_000_000_000)
            PerformanceManager.shared.setValue(name: "performance_view_loading", value: "Finished downloading", forAttribute: "func_state")
            
            // หยุดการติดตามการโหลด View
            PerformanceManager.shared.stopTrace(name: "performance_view_loading")

        }
    }
    
    // ดาวน์โหลดข้อมูลสินค้าและอัพโหลดไปยัง Firebase
    func downloadProductsAndUploadToFirebase() {
        
        // ดาวน์โหลดข้อมูลจาก URL และบันทึกการทำงานโดยใช้ HTTPMetric
        let urlString = "https://dummyjson.com/products"
        guard let url = URL(string: urlString), let metric = HTTPMetric(url: url, httpMethod: .get) else { return }
        metric.start()
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(from: url)
                if let response = response as? HTTPURLResponse {
                    metric.responseCode = response.statusCode
                }
                metric.stop()
                print("SUCCESS")
            } catch {
                print(error)
                metric.stop()
            }
        }
    }
}

#Preview {
    PerformanceView()
}

