# Job Finder AI - Flutter App

A modern dark-themed Flutter job search application with filtering, saving, and application tracking features.

## Features

### 🎯 Core Functionality
- **Jobs Screen**: Browse available jobs with filtering capabilities
- **Job Detail Screen**: View detailed job information with apply functionality
- **Saved Jobs Screen**: Track saved and applied jobs with status indicators
- **Filter System**: Search by keywords, location, skills, and experience level

### 🎨 Design
- **Dark Theme**: Modern dark UI following the reference design
- **Yellow Accents**: Primary action color matching the design requirements
- **Responsive Cards**: Job cards with company logos, metadata, and actions
- **Status Indicators**: Visual feedback for saved and applied job states

### 🛠 Technical Features
- **State Management**: Provider pattern for app-wide state
- **API Integration**: Ready for backend integration with fallback to mock data
- **External Links**: URL launcher for job application links
- **Filtering**: Real-time search and multi-criteria filtering
- **In-Memory Storage**: Saved and applied jobs tracking (resets on app restart)

## App Structure

```
lib/
├── main.dart                   # App entry point
├── models/
│   └── job_model.dart         # Job data model
├── services/
│   └── api_service.dart       # API service with mock data
├── providers/
│   └── job_provider.dart      # State management
├── screens/
│   ├── jobs_screen.dart       # Main job listing
│   ├── job_detail_screen.dart # Job detail view
│   └── saved_jobs_screen.dart # Saved/Applied jobs
├── widgets/
│   ├── job_card.dart          # Reusable job card
│   └── filter_drawer.dart     # Filter drawer
└── theme/
    └── app_theme.dart         # Dark theme configuration
```

## How to Use

### 1. Main Jobs Screen
- **View Jobs**: Browse the list of available jobs
- **Filter**: Tap the filter icon to open the left drawer
- **Save Jobs**: Tap the bookmark icon on any job card
- **Apply**: Tap the "Apply" button to open the application process
- **View Details**: Tap on a job card to see full details

### 2. Filter Drawer
- **Search**: Enter keywords to search job titles and descriptions
- **Location**: Filter by location (e.g., "Remote", "San Francisco")
- **Experience Level**: Choose from Entry, Mid, or Senior level
- **Skills**: Select multiple skills from the available options
- **Apply Filters**: Tap "Search Jobs" to apply all filters
- **Clear**: Use "Clear All" to reset all filters

### 3. Job Detail Screen
- **View Information**: See complete job details, requirements, and company info
- **Save Job**: Bookmark the job for later
- **Apply**: Tap "Apply Now" to open the external application link
- **Application Tracking**: Confirm if you applied to track the job status

### 4. Saved Jobs Screen
- **Saved Tab**: View all bookmarked jobs
- **Applied Tab**: Track jobs you've applied for with status indicators
- **Status Tracking**: See "Applied", "Accepted", or "Rejected" status

## Backend Integration

### API Configuration
Update the `baseUrl` in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-aws-endpoint.com';
```

### Available Endpoints
The app is ready to integrate with these backend endpoints:
- `GET /jobs/` - Get jobs with query parameters
- `GET /jobs/{id}` - Get single job details
- `GET /` - Health check

### Mock Data
When the backend is not available, the app automatically falls back to mock data for demonstration purposes.

## Running the App

1. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

2. **Run the App**:
   ```bash
   flutter run
   ```

3. **Build for Release**:
   ```bash
   flutter build apk  # for Android
   flutter build ios  # for iOS
   ```

## Key Components

### JobProvider
Manages app state including:
- Job listings and filtering
- Saved and applied jobs
- Search and filter criteria
- Loading states and error handling

### Job Model
Represents job data with properties:
- Basic info (title, description, company)
- Metadata (salary, location, category)
- Skills and keywords
- Application link

### API Service
Handles backend communication:
- Fetches jobs with filtering
- Gets individual job details
- Provides mock data fallback
- Error handling and retries

## Customization

### Theme Colors
Modify colors in `lib/theme/app_theme.dart`:
```dart
static const Color primaryYellow = Color(0xFFFFD700);
static const Color darkBackground = Color(0xFF121212);
// ... more colors
```

### Mock Data
Add more sample jobs in `api_service.dart`:
```dart
static List<Job> getMockJobs() {
  return [
    Job(/* your job data */),
    // Add more jobs here
  ];
}
```

### Skills List
Update available skills in `job_provider.dart`:
```dart
List<String> get availableSkills => [
  'Flutter', 'React', 'Python',
  // Add more skills
];
```

## Backend API Integration

**Important**: To connect with your backend, update the base URL in `lib/services/api_service.dart`:

```dart
static const String baseUrl = 'https://your-aws-endpoint.com';
```

The app supports all the backend endpoints mentioned in your API documentation:
- Search with query parameters (q, location, skills, category, limit, skip)
- Single job retrieval
- Proper error handling and fallback to mock data

---

**Note**: This app matches the design references you provided and includes all the functionality specified in your requirements. The app will automatically use mock data when the backend is not available for testing purposes.
