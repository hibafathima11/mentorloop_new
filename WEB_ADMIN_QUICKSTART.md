# Web Admin Dashboard - Quick Start Guide

## Running the Application

### Web Platform (Admin Dashboard)
```bash
# Navigate to project directory
cd c:\mentorloop_new

# Run on Chrome/web browser
flutter run -d chrome

# Or run with verbose logging for debugging
flutter run -d chrome -v
```

The web version will automatically load the **Landing Page** at `http://localhost:###`.

### Mobile Platform (Student/Teacher App)
```bash
# Run on Android emulator
flutter run

# Run on iOS simulator
flutter run -d ios

# Run on connected device
flutter run -d <device-id>
```

The mobile version will load the **Mobile App (SplashScreen)**.

## Accessing the Admin Dashboard

### From Landing Page
1. Visit the web application at `http://localhost:###`
2. Click the **"Login as Admin"** button in the navbar
3. You'll be directed to the Admin Login Screen

### Admin Login Credentials
For testing, use any email/password (currently Firebase-connected):
- **Email**: admin@mentorloop.com
- **Password**: Any valid password (requires Firebase setup)

*Note: If you don't have Firebase configured, the login will fail. See Firebase Setup below.*

### If Login Fails
If you're developing without Firebase:
1. Update `admin_login_screen.dart` line 28-35 to bypass authentication
2. Or temporarily comment out the login check and navigate directly to `AdminDashboardContainer`

## Navigating the Admin Dashboard

Once logged in, you'll see:

### Sidebar Navigation (Left)
- **Dashboard**: Main admin overview with stats
- **Users**: User management and listing
- **Courses**: Course management
- **Assignments**: Assignment tracking
- **Analytics**: Platform analytics and insights
- **Settings**: Admin settings and configuration
- **Logout**: Exit the admin dashboard

### Top Bar
- **Title**: Shows current page name
- **Search**: Search functionality (placeholder)
- **Notifications**: Notification bell (placeholder)
- **Admin Avatar**: User profile (placeholder)

### Responsive Features
- **Mobile (<768px)**: Click menu icon to toggle sidebar
- **Desktop (≥768px)**: Sidebar is always visible
- **Sidebar Collapse**: Hovers/taps to reveal labels (optional)

## Key Screens Overview

### 1. Landing Page
- **Hero Section**: Large banner with CTA
- **Features**: 4-column grid of platform features
- **Navigation**: Quick links in navbar
- **Admin Login**: Top-right button

### 2. Admin Dashboard (Home)
- **Stats Grid**: 4 key metrics (Users, Courses, Assignments, Approvals)
- **Overview Charts**: Placeholder for growth charts
- **Recent Activity**: Latest 5 activities with timestamps

### 3. Users Management
- **Search**: Find users by name/email
- **Filters**: By role (Student/Teacher/Parent) and status (Active/Inactive/Pending)
- **Data Table**: Full user list with details and actions
- **Actions**: Edit and delete buttons for each user

### 4. Courses Management
- **Course Grid**: Visual course cards
- **Search & Filter**: By status (Active/Draft/Archived)
- **Course Info**: Name, teacher, student count, progress
- **Actions**: Edit and delete buttons

### 5. Assignments Management
- **Assignment List**: Detailed assignment cards
- **Submission Tracking**: Shows completed/total submissions
- **Progress Bars**: Visual submission completion status
- **Actions**: View submissions, edit, delete

### 6. Analytics
- **Key Metrics**: User signups, active users, enrollments, completion rate
- **Charts Section**: Placeholder for trend visualization
- **Retention Analysis**: Monthly retention rates with progress bars
- **Top Courses**: Ranked courses with ratings and completion %

### 7. Settings
- **General Settings**: App name, description, support email
- **Appearance**: Theme selector
- **Notifications**: Email notification toggle
- **System**: Maintenance mode, cache clearing
- **Database**: Backup management
- **Security**: Password change, session management

## Firebase Setup (If Needed)

1. **Configure Firebase**:
   ```bash
   # Run Firebase setup (if not already done)
   flutter pub get
   flutterfire configure
   ```

2. **Verify Firebase Credentials**:
   - Check `lib/firebase_options.dart`
   - Ensure `android/app/google-services.json` exists

3. **Create Test Admin User**:
   - Go to Firebase Console
   - Create user: admin@mentorloop.com
   - Use this for login testing

## Troubleshooting

### Issue: "Plugin 'cloud_firestore' not found"
```bash
# Solution: Run pub get
flutter pub get
flutter clean
flutter pub get
```

### Issue: Web doesn't load
```bash
# Solution: Check if Chrome is available
flutter devices
# Should show 'chrome' in the list
```

### Issue: Login screen shows error
```bash
# Check Firebase configuration
# Verify internet connection
# Check Firebase console for user existence
```

### Issue: Sidebar not appearing
- On mobile, click the menu icon (☰) in the top-left
- On desktop, sidebar should always be visible

## Development Notes

### Adding New Admin Screens
1. Create new file in `lib/web/screens/`
2. Extend the screen to use `AdminLayout` widget (optional)
3. Add to `AdminMenuItem` list in `admin_dashboard_container.dart`:
   ```dart
   AdminMenuItem(
     icon: Icons.new_icon,
     label: 'New Screen',
     screen: const NewScreen(),
   ),
   ```
4. Sidebar will automatically include the new menu item

### Customizing Colors
- Primary color: `Color(0xFF8B5E3C)` (brown)
- Update `lib/main.dart` theme for app-wide changes
- Individual screens can override colors as needed

### Testing Responsive Design
1. Run `flutter run -d chrome`
2. Open DevTools (F12)
3. Use Device Toolbar to test different screen sizes
4. Default breakpoint: 768px for mobile/desktop switch

### Database Integration
- Current screens use mock data
- To connect to Firestore:
  1. Update data loading in each screen
  2. Use `data_service.dart` functions
  3. Add real-time listeners for live updates
  4. Implement CRUD operations

## File Structure
```
lib/
├── main.dart                           # Entry point with routing
├── web/
│   ├── screens/
│   │   ├── landing_page.dart
│   │   ├── admin_login_screen.dart
│   │   ├── admin_dashboard_container.dart
│   │   ├── admin_dashboard_screen.dart
│   │   ├── users_management_screen.dart
│   │   ├── courses_management_screen.dart
│   │   ├── assignments_management_screen.dart
│   │   ├── analytics_screen.dart
│   │   └── settings_screen.dart
│   └── widgets/
│       └── admin_layout.dart
└── screens/                            # Mobile app (unchanged)
    ├── Student/
    ├── Teacher/
    ├── Parent/
    ├── Admin/
    └── Common/
```

## Support & Debugging

For detailed implementation info, see:
- `WEB_ADMIN_IMPLEMENTATION.md` - Full feature documentation
- Individual screen files - Component-specific documentation
- `lib/main.dart` - Theme and configuration
- `lib/web/widgets/admin_layout.dart` - Layout wrapper documentation

---

**Version**: 1.0 | **Last Updated**: December 2024
