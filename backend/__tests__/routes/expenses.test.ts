import request from 'supertest';
import express from 'express';
import expenseRoutes from '../../src/routes/expenses';
import { verifyToken } from '../../src/middleware/auth';

// Mock auth middleware
jest.mock('../../src/middleware/auth', () => ({
  verifyToken: (req: any, res: any, next: any) => {
    req.user = { userId: 'test-user-id' };
    next();
  },
}));

const app = express();
app.use(express.json());
app.use('/api/expenses', expenseRoutes);

describe('Expense Routes', () => {
  describe('POST /api/expenses', () => {
    it('should create an expense', async () => {
      const expenseData = {
        amount: 100,
        category: 'food',
        description: 'Test expense',
      };

      const response = await request(app)
        .post('/api/expenses')
        .send(expenseData);

      expect(response.status).toBe(201);
      expect(response.body).toHaveProperty('id');
      expect(response.body.amount).toBe(100);
    });

    it('should reject invalid amount', async () => {
      const response = await request(app)
        .post('/api/expenses')
        .send({ amount: -10, category: 'food' });

      expect(response.status).toBe(400);
    });
  });

  describe('GET /api/expenses', () => {
    it('should get all expenses', async () => {
      const response = await request(app).get('/api/expenses');

      expect(response.status).toBe(200);
      expect(Array.isArray(response.body)).toBe(true);
    });
  });
});
