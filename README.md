# test_390_technology
iOS sports news app with modular architecture (Clean Architecture + MVVM), caching, local persistence, and secure API consumption.

⚙️   Technical Features ⚙️
🔍 SOLID Principles Applied🔍
🧹 Clean Code Implementation 🧹
📡 Networking & API
🔐 HTTPS Requests (TLS 1.2+)
🔑 API Key Management via KeychainHandler
🔄 Cache Persistence (CoreData + URLSession Caching)
⚡ Combine Framework for reactive data flow

🖼️ Image Handling
🖼 Kingfisher for async image loading & caching
💾 Double-Layer Cache:

Memory Cache (NSCache)

Disk Cache (CoreData)

🔄 Data Flow
📥 Pull-to-Refresh with UIRefreshControl
📲 Detail Screen with full article content
❌ Error Handling:

CustomErrorView with retry button

APIError enum for service errors

🧪 Testing
✅ DI Container for testable ViewModels

🚀 Installation (Updated)
Add Kingfisher via SPM:

swift
Copy
// Package Dependency
.package(url: "https://github.com/onevcat/Kingfisher.git", from: "7.0.0")

Demo: https://vimeo.com/1075422381/0b111dd07b?ts=0&share=copy
Demo2: https://vimeo.com/1075422655/db36edf48e?ts=0&share=copy

📜 License
MIT License © 2024 - [Elderson Laborit]

✨ "Code like the ball is in the 90th minute!" ⚽
