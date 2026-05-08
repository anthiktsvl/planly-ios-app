<div align="center">

# 🗓️ Planly

### *Your Personal Productivity Companion* ✨

A beautiful full-stack productivity app that helps you organize tasks, manage projects, and never miss a meeting! 💕

![Swift](https://img.shields.io/badge/Swift-5.9-FA7343?style=for-the-badge&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017+-0D96F6?style=for-the-badge&logo=swift&logoColor=white)
![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=for-the-badge&logo=node.js&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)

---

### ✨ *Because staying organized should be beautiful* ✨

[Features](#-features) • [Screenshots](#-screenshots) • [Tech Stack](#-tech-stack) • [Getting Started](#-getting-started) • [API Docs](#-api-documentation)

</div>

---

## 🎯 Features

### 📋 **Task Management**
- ✅ Create and organize tasks with priorities (High, Medium, Low)
- 🎨 Beautiful gradient UI with color-coded priorities
- ✏️ Add descriptions, categories, and due dates
- ⏰ Set start and end times for tasks
- ✨ Mark tasks as complete with satisfying animations

### 📅 **Calendar View**
- 🗓️ Interactive monthly calendar
- 👆 Tap any day to see tasks
- 🔴 Visual indicators for days with tasks
- 📊 See task count at a glance

### 📊 **Projects** 
- 📁 Group related tasks into projects
- 🎯 Track project progress
- 👥 Collaborate with team members

### 👥 **Meetings** *(Coming Soon)*
- 🎥 Schedule and manage meetings
- ⏰ Get reminded before meetings start
- 📝 Add meeting notes and participants

### 🔐 **Secure Authentication**
- 🔒 JWT-based authentication
- 🛡️ Bcrypt password hashing
- 👤 Personalized user experience

---

## 📱 Screenshots

> *Add your beautiful app screenshots here!* 📸

<div align="center">

| Home View | Calendar | Tasks |
|-----------|----------|-------|
| ![Home](screenshots/home.png) | ![Calendar](screenshots/calendar.png) | ![Tasks](screenshots/tasks.png) |

</div>

---

## 🛠️ Tech Stack

### Frontend (iOS)
```
🎨 SwiftUI          - Modern declarative UI framework
⚡ Combine           - Reactive data flow
🌐 URLSession        - Native networking
🎯 MVVM Pattern      - Clean architecture
```

### Backend (API)
```
🚀 Node.js + Express - RESTful API server
🐘 PostgreSQL        - Relational database
🔐 JWT               - Secure authentication
🔒 bcrypt            - Password encryption
```

---

## 📁 Project Structure

```
planly-ios-application/
├── 📱 frontend-SwiftUI/
│   ├── Models/              # Data models
│   ├── Views/               # UI components
│   │   ├── Home/
│   │   ├── Calendar/
│   │   ├── Tasks/
│   │   └── Profile/
│   ├── ViewModels/          # Business logic
│   ├── Services/            # API & networking
│   │   └── API/
│   └── Components/          # Reusable UI components
│
└── 🔧 planly-backend/
    ├── src/
    │   ├── routes/          # API endpoints
    │   ├── models/          # Database models
    │   ├── middleware/      # Auth & validation
    │   └── config/          # Configuration
    └── migrations/          # Database migrations
```

---

## 🚀 Getting Started

### Prerequisites

Before you begin, make sure you have:

- ✅ **Xcode 15+** (for iOS development)
- ✅ **Node.js 18+** (for backend)
- ✅ **PostgreSQL 15+** (for database)
- ✅ **iOS 17+ device or simulator**

---

### 🔧 Backend Setup

```bash
# Navigate to backend
cd planly-backend

# Install dependencies
npm install

# Create environment file
cp .env.example .env

# Edit .env with your database credentials
# Example:
# PORT=3000
# DATABASE_URL=postgresql://user:password@localhost:5432/planly
# JWT_SECRET=your-super-secret-key

# Run database migrations
npm run migrate

# Start the server
npm start
```

✅ **Backend running on:** `http://localhost:3000`

---

### 📱 iOS App Setup

```bash
# Navigate to frontend
cd frontend-SwiftUI

# Open project in Xcode
open Planly.xcodeproj
```

**In Xcode:**

1. 📝 Update API URL in `Services/API/APIConfig.swift`:
   ```swift
   static let baseURL = "http://localhost:3000/api"
   ```

2. ▶️ Select a simulator or device

3. ⌘R Press **Cmd + R** to build and run

---

## 🔑 Environment Variables

Create a `.env` file in the `planly-backend` folder:

```env
PORT=3000
DATABASE_URL=postgresql://username:password@localhost:5432/planly
JWT_SECRET=your-super-secret-jwt-key-change-this
NODE_ENV=development
```

> ⚠️ **Never commit your `.env` file to GitHub!**

---

## 📚 API Documentation

### Base URL
```
http://localhost:3000/api
```

### Authentication Endpoints

#### Register
```http
POST /auth/register
Content-Type: application/json

{
  "name": "Anthi",
  "email": "anthi@planly.com",
  "password": "SecurePassword123"
}
```

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "anthi@planly.com",
  "password": "SecurePassword123"
}
```

### Task Endpoints

#### Get All Tasks
```http
GET /tasks
Authorization: Bearer {token}
```

#### Create Task
```http
POST /tasks
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Finish Planly README",
  "description": "Make it cute and professional",
  "date": "2026-02-06",
  "priority": "high",
  "category": "Development"
}
```

#### Update Task
```http
PUT /tasks/:id
Authorization: Bearer {token}
```

#### Delete Task
```http
DELETE /tasks/:id
Authorization: Bearer {token}
```

> 📖 For full API documentation, see [API.md](docs/API.md)

---

## 🎨 Design Philosophy

Planly is designed with love and attention to detail:

- 💕 **Beautiful gradients** - Pink and purple themes throughout
- 🎯 **Intuitive UX** - Everything is where you expect it
- ⚡ **Fast & responsive** - Native SwiftUI performance
- 🌙 **Modern iOS design** - Following Apple's HIG
- ✨ **Delightful animations** - Smooth transitions and feedback

---

## 🗺️ Roadmap

- [x] ✅ Task management
- [x] 📅 Calendar view
- [x] 🔐 User authentication
- [x] 🎨 Beautiful UI with gradients
- [ ] 📊 Projects feature
- [ ] 👥 Meetings management
- [ ] 🔔 Push notifications
- [ ] 🌙 Dark mode optimization
- [ ] ☁️ iCloud sync
- [ ] 🍎 Apple Watch app
- [ ] 📤 Share tasks
- [ ] 🎯 Task templates

---

## 🤝 Contributing

Contributions are always welcome! 💕

1. 🍴 Fork the repository
2. 🌿 Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. 💾 Commit your changes (`git commit -m '✨ Add some AmazingFeature'`)
4. 📤 Push to the branch (`git push origin feature/AmazingFeature`)
5. 🎉 Open a Pull Request

---

## 🐛 Known Issues

- [ ] Calendar scrolling performance on older devices
- [ ] Date parsing for different timezones

> Found a bug? [Open an issue](https://github.com/anthiktsvl/planly-ios-application/issues) 🐛

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 👩‍💻 Author

**Anthi Ktsvl**

- 💼 GitHub: [@anthiktsvl](https://github.com/anthiktsvl)
- 📧 Email: anthik@planly.com
- 🌟 Portfolio: [your-portfolio-link.com](#)

---

## 💖 Acknowledgments

- Thanks to the SwiftUI community for inspiration
- Icons by [SF Symbols](https://developer.apple.com/sf-symbols/)
- Color gradients inspired by modern iOS design trends

---

<div align="center">

### ⭐ If you like Planly, give it a star! ⭐

Made with 💕 and lots of ☕

**Happy Planning!** ✨

</div>
