<div align="center">

# 🗓️ Planly

### *Your Personal Productivity Companion* ✨

A beautiful full-stack productivity app that helps you organize tasks, manage projects, schedule meetings, and boost your productivity with smart templates! 💕

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
- 📁 Assign tasks to projects
- 👥 Add assignees to tasks
- 🔔 Get notifications when tasks are due

### 📊 **Project Management**
- 📁 Create and organize projects with custom colors
- 🎯 Track project progress with visual indicators
- 📈 Monitor completion rates
- 📝 Add project descriptions and categories
- ⏰ Set project deadlines
- 🔗 Link tasks to projects
- 📊 View project analytics and insights

### 👥 **Meeting Management**
- 🎥 Schedule and manage meetings
- ⏰ Set meeting start and end times
- 📝 Add meeting descriptions and agendas
- 👥 Invite attendees via email
- 🔗 Add video meeting links (Google Meet, Zoom, etc.)
- 📅 View upcoming, past, and today's meetings
- 🔔 Get reminders before meetings start
- ✅ Track meeting status (scheduled, in progress, completed)

### 📅 **Calendar & Analytics**
- 🗓️ Interactive calendar view
- 📊 Productivity analytics and insights
- 📈 Task completion trends
- ⏰ Time tracking per category
- 🎯 Goal tracking and achievements

### 🎨 **Smart Templates**
- 📋 **Task Templates** - Quick-start templates for common tasks
  - Quick Email (5 min)
  - Code Review (30 min)
  - Client Call (45 min)
  - Write Blog Post (2 hours)
  - Team Sync (30 min)
  - Bug Fix (1 hour)

- 📁 **Project Templates** - Complete project setups with tasks
  - Website Launch (6 tasks)
  - Marketing Campaign (6 tasks)
  - Event Planning (6 tasks)

- 🎥 **Meeting Templates** - Pre-configured meeting types
  - Daily Standup (15 min, 3 agenda items)
  - Weekly Planning (60 min, 4 agenda items)
  - Client Presentation (45 min, 5 agenda items)
  - 1-on-1 (30 min, 4 agenda items)

### 🎨 **Customization**
- 🌈 Multiple color themes (Pink, Purple, Blue, Green, Orange, Teal)
- 📱 Adaptive font sizes for accessibility
- 💫 Animated backgrounds and transitions
- 🎯 Personalized user profiles
- ⚙️ Customizable work hours and preferences

### 🔔 **Notifications**
- 📬 Task notifications
- 📅 Meeting reminders
- ⏰ Project deadline alerts
- 🔔 Customizable notification preferences
- ⏱️ Configurable reminder times

### 🔐 **Secure Authentication**
- 🔒 JWT-based authentication
- 🛡️ Bcrypt password hashing
- 👤 Personalized user experience
- 🔄 Secure profile updates
- 🌐 Timezone support

---

## 📱 Screenshots

> *Add your beautiful app screenshots here!* 📸

<div align="center">

| Home View | Tasks | Meetings | Templates |
|-----------|-------|----------|-----------|
| ![Home](screenshots/home.png) | ![Tasks](screenshots/tasks.png) | ![Meetings](screenshots/meetings.png) | ![Templates](screenshots/templates.png) |

| Projects | Calendar | Analytics | Profile |
|----------|----------|-----------|---------|
| ![Projects](screenshots/projects.png) | ![Calendar](screenshots/calendar.png) | ![Analytics](screenshots/analytics.png) | ![Profile](screenshots/profile.png) |

</div>

---

## 🛠️ Tech Stack

### Frontend (iOS)
```
🎨 SwiftUI          - Modern declarative UI framework
⚡ Combine           - Reactive data flow
🌐 URLSession        - Native networking
🎯 MVVM Pattern      - Clean architecture
🔔 UserNotifications - Local notifications
📅 EventKit          - Calendar integration
🎨 Custom Components - Reusable UI elements
```

### Backend (API)
```
🚀 Node.js + Express - RESTful API server
🐘 PostgreSQL        - Relational database
🔐 JWT               - Secure authentication
🔒 bcrypt            - Password encryption
🛡️ Middleware        - Auth & validation
📊 Complex queries   - Advanced data relationships
```

---

## 📁 Project Structure

```
planly-ios-app/
├── 📱 frontend-SwiftUI/
│   ├── Models/              # Data models
│   │   ├── Models.swift     # Core models (Task, Project, Meeting)
│   │   ├── Priority.swift   # Priority enum
│   │   └── APIModels.swift  # API response models
│   │
│   ├── Views/               # UI components
│   │   ├── Home/            # Home view with quick actions
│   │   ├── Tasks/           # Task management
│   │   ├── Projects/        # Project management
│   │   ├── Meetings/        # Meeting scheduler
│   │   ├── Calendar/        # Calendar view
│   │   ├── Profile/         # User profile & settings
│   │   └── Templates/       # Template library
│   │
│   ├── ViewModels/          # Business logic
│   │   ├── AuthViewModel.swift
│   │   ├── AppDataViewModel.swift
│   │   └── ThemeManager.swift
│   │
│   ├── Services/            # API & networking
│   │   ├── APIService.swift
│   │   ├── NetworkManager.swift
│   │   └── NotificationManager.swift
│   │
│   └── Components/          # Reusable UI components
│       ├── ColorTheme.swift
│       └── FontManager.swift
│
└── 🔧 src/                  # Backend
    ├── routes/              # API endpoints
    │   ├── authRoutes.js
    │   ├── taskRoutes.js
    │   ├── projectRoutes.js
    │   └── meetingRoutes.js
    │
    ├── controllers/         # Route handlers
    │   ├── authController.js
    │   ├── taskController.js
    │   ├── projectController.js
    │   └── meetingController.js
    │
    ├── middleware/          # Auth & validation
    │   └── authMiddleware.js
    │
    └── config/              # Configuration
        └── database.js
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
# Navigate to backend directory
cd planly-ios-app

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
cd planly-ios-app

# Open project in Xcode
open planly.xcodeproj
```

**In Xcode:**

1. 📝 Update API URL in `Services/APIService.swift`:
   ```swift
   static let baseURL = "http://localhost:3000/api"
   ```

2. ▶️ Select a simulator or device

3. ⌘R Press **Cmd + R** to build and run

4. 📝 Create an account or login to start organizing!

---

## 🔑 Environment Variables

Create a `.env` file in the root folder:

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
  "date": "2026-05-09",
  "priority": "high",
  "category": "Development",
  "startTime": "09:00:00",
  "endTime": "11:00:00",
  "projectId": 1,
  "assignees": ["team@planly.com"]
}
```

### Project Endpoints

#### Get All Projects
```http
GET /projects
Authorization: Bearer {token}
```

#### Create Project
```http
POST /projects
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "Website Redesign",
  "description": "Modernize company website",
  "category": "Development",
  "estimatedHours": 40,
  "deadline": "2026-06-01",
  "color": "#FF69B4"
}
```

### Meeting Endpoints

#### Get All Meetings
```http
GET /meetings
Authorization: Bearer {token}
```

#### Create Meeting
```http
POST /meetings
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Weekly Standup",
  "description": "Team sync meeting",
  "date": "2026-05-09",
  "startTime": "10:00:00",
  "endTime": "10:30:00",
  "attendeeEmails": ["team@planly.com"],
  "meetingLink": "https://meet.google.com/abc-defg-hij",
  "status": "scheduled"
}
```

> 📖 For full API documentation, see [API.md](docs/API.md)

---

## 🎨 Design Philosophy

Planly is designed with love and attention to detail:

- 💕 **Beautiful gradients** - Customizable color themes
- 🎯 **Intuitive UX** - Everything is where you expect it
- ⚡ **Fast & responsive** - Native SwiftUI performance
- 🌙 **Modern iOS design** - Following Apple's HIG
- ✨ **Delightful animations** - Smooth transitions and feedback
- ♿ **Accessible** - Adaptive font sizes and clear navigation
- 🎨 **Consistent** - Unified design language throughout

---

## 🗺️ Roadmap

- [x] ✅ Task management with priorities
- [x] ✅ Project management with progress tracking
- [x] ✅ Meeting scheduler with attendees
- [x] ✅ Smart templates (tasks, projects, meetings)
- [x] 🔐 User authentication
- [x] 🎨 Multiple color themes
- [x] 📊 Analytics dashboard
- [x] 🔔 Local notifications
- [x] 📅 Calendar view


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

- [ ] Meeting attendees must be registered users
- [ ] Template creation limited to predefined templates
- [ ] Timezone handling needs improvement for global users

> Found a bug? [Open an issue](https://github.com/anthiktsvl/planly-ios-app/issues) 🐛

---

## 📝 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

---

## 👩‍💻 Author

**Anthi Ktsvl**

- 💼 GitHub: [@anthiktsvl](https://github.com/anthiktsvl)
- 📧 Email: your-email@example.com
- 🌟 Made with passion for productivity

---

## 💖 Acknowledgments

- Thanks to the SwiftUI community for inspiration
- Icons by [SF Symbols](https://developer.apple.com/sf-symbols/)
- Color gradients inspired by modern iOS design trends
- Template system inspired by productivity best practices

---

<div align="center">

### ⭐ If you like Planly, give it a star! ⭐

Made with 💕 and lots of ☕

**Happy Planning!** ✨

---

**Version 1.0.0** • Built with Swift & Node.js • May 2026

</div>
