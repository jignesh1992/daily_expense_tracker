# Pocketa Expense Tracker

A comprehensive daily expense tracking application with voice input support, built with Flutter (frontend) and Node.js/Express (backend).

## Features

- 🎤 **Voice Input**: Record expenses using voice commands
- 📱 **Cross-Platform**: iOS and Android support
- 🔄 **Offline-First**: Works offline with automatic sync
- 📊 **Analytics**: Daily, weekly, and monthly summaries
- 🔐 **Authentication**: Firebase Authentication
- 🎨 **Modern UI**: Beautiful Material Design 3 interface

## Project Structure

```
daily_expense_tracker/
├── frontend/              # Flutter app
│   ├── lib/
│   │   ├── models/        # Data models
│   │   ├── providers/     # Riverpod state management
│   │   ├── screens/       # UI screens
│   │   ├── services/      # API & local services
│   │   ├── widgets/       # Reusable widgets
│   │   └── utils/         # Utilities & constants
│   ├── ios/               # iOS-specific code
│   ├── android/           # Android-specific code
│   └── pubspec.yaml       # Flutter dependencies
├── backend/               # Node.js + Express API
│   ├── src/
│   │   ├── routes/        # API routes
│   │   ├── services/     # Business logic
│   │   ├── middleware/    # Express middleware
│   │   └── config/        # Configuration files
│   ├── prisma/            # Database schema
│   └── package.json       # Node.js dependencies
└── README.md
```

## Prerequisites

- Node.js 18+ and npm
- Flutter 3.0+
- PostgreSQL database
- Firebase project
- Claude API key (for voice parsing)

## Backend Setup

1. Navigate to backend directory:
```bash
cd backend
```

2. Install dependencies:
```bash
npm install
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Set up database:
```bash
# Generate Prisma client
npm run prisma:generate

# Run migrations
npm run prisma:migrate
```

5. Start development server:
```bash
npm run dev
```

The API will be available at `http://localhost:3000`

## Frontend Setup

1. Navigate to frontend directory:
```bash
cd frontend
```

2. Install dependencies:
```bash
flutter pub get
```

3. Configure Firebase:
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`

4. Run the app:
```bash
flutter run
```

## Environment Variables

### Backend (.env)
```
DATABASE_URL=postgresql://user:password@localhost:5432/expense_tracker
PORT=3000
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
CLAUDE_API_KEY=your-claude-api-key
CORS_ORIGIN=http://localhost:3000
```

### Frontend
Set `API_BASE_URL` when building:
```bash
flutter build apk --dart-define=API_BASE_URL=https://your-api-url.com
```

## API Endpoints

### Authentication
- `POST /api/auth/verify` - Verify Firebase token

### Expenses
- `POST /api/expenses` - Create expense
- `GET /api/expenses` - List expenses (with filters)
- `GET /api/expenses/:id` - Get single expense
- `PUT /api/expenses/:id` - Update expense
- `DELETE /api/expenses/:id` - Delete expense

### Summary
- `GET /api/summary/daily` - Daily summary
- `GET /api/summary/weekly` - Weekly summary
- `GET /api/summary/monthly` - Monthly summary

### Voice
- `POST /api/voice/parse` - Parse voice input

### Categories
- `GET /api/categories` - List all categories

## Deployment

### Backend (Railway)
1. Connect your GitHub repository to Railway
2. Set environment variables in Railway dashboard
3. Railway will automatically deploy on push

### Frontend
1. Build for iOS:
```bash
flutter build ios
```

2. Build for Android:
```bash
flutter build apk
```

## Testing

### Backend
```bash
cd backend
npm test
```

### Frontend
```bash
cd frontend
flutter test
```

## Voice Input Format

Supported formats:
- "₹500 food"
- "100 rupees for taxi"
- "2000 shopping clothes"

The app uses Claude API to parse natural language into structured expense data.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License
