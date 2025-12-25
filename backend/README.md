# Backend API - Pocketa Expense Tracker

Node.js + Express + TypeScript backend API for the expense tracker application.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your values
```

3. Set up database:
```bash
npm run prisma:generate
npm run prisma:migrate
```

4. Start development server:
```bash
npm run dev
```

## API Documentation

### Authentication

All protected routes require a Firebase ID token in the Authorization header:
```
Authorization: Bearer <firebase-id-token>
```

### Endpoints

#### POST /api/auth/verify
Verify Firebase token and create/get user.

**Response:**
```json
{
  "success": true,
  "user": {
    "uid": "firebase-uid",
    "email": "user@example.com",
    "userId": "database-user-id"
  }
}
```

#### POST /api/expenses
Create a new expense.

**Request Body:**
```json
{
  "amount": 100,
  "category": "food",
  "description": "Lunch",
  "date": "2024-01-01T00:00:00.000Z"
}
```

**Response:**
```json
{
  "id": "expense-id",
  "userId": "user-id",
  "amount": 100,
  "category": "food",
  "description": "Lunch",
  "date": "2024-01-01T00:00:00.000Z",
  "createdAt": "2024-01-01T00:00:00.000Z",
  "updatedAt": "2024-01-01T00:00:00.000Z"
}
```

#### GET /api/expenses
Get all expenses with optional filters.

**Query Parameters:**
- `date` - Filter by specific date (ISO string)
- `category` - Filter by category
- `startDate` - Start date for range filter
- `endDate` - End date for range filter

#### GET /api/summary/daily
Get daily summary.

**Query Parameters:**
- `date` - Date to get summary for (default: today)

**Response:**
```json
{
  "date": "2024-01-01",
  "total": 500,
  "count": 3,
  "breakdown": [
    {
      "category": "food",
      "amount": 300,
      "count": 2
    }
  ]
}
```

#### POST /api/voice/parse
Parse voice input text.

**Request Body:**
```json
{
  "text": "₹500 food"
}
```

**Response:**
```json
{
  "amount": 500,
  "category": "food",
  "description": null
}
```

## Database Schema

### User
- `id` (String, Primary Key)
- `firebaseUid` (String, Unique)
- `email` (String)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

### Expense
- `id` (String, Primary Key)
- `userId` (String, Foreign Key)
- `amount` (Float)
- `category` (Category Enum)
- `description` (String, Optional)
- `date` (DateTime)
- `createdAt` (DateTime)
- `updatedAt` (DateTime)

### Category Enum
- food
- transport
- shopping
- entertainment
- bills
- other

## Error Handling

All errors follow this format:
```json
{
  "error": "Error message",
  "name": "ErrorType"
}
```

Common status codes:
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (invalid/missing token)
- `404` - Not Found
- `500` - Internal Server Error

## Testing

Run tests:
```bash
npm test
```

Watch mode:
```bash
npm run test:watch
```

## Deployment

### Railway

1. Connect your repository to Railway
2. Add environment variables in Railway dashboard
3. Railway will automatically detect the Node.js app and deploy

The `Procfile` specifies the start command for production.

## Development

- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript to JavaScript
- `npm start` - Start production server
- `npm run prisma:studio` - Open Prisma Studio (database GUI)
