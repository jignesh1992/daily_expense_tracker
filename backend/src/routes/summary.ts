import { Router, Request, Response } from 'express';
import { verifyToken, AuthRequest } from '../middleware/auth';
import { getDailySummary, getWeeklySummary, getMonthlySummary } from '../services/summary';

const router = Router();

router.use(verifyToken);

// Daily summary
router.get('/daily', async (req: AuthRequest, res: Response) => {
  try {
    const dateParam = req.query.date as string;
    const date = dateParam ? new Date(dateParam) : new Date();

    const summary = await getDailySummary(req.user!.userId, date);
    res.json(summary);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

// Weekly summary
router.get('/weekly', async (req: AuthRequest, res: Response) => {
  try {
    const startDateParam = req.query.startDate as string;
    const endDateParam = req.query.endDate as string;

    let startDate: Date;
    let endDate: Date;

    if (startDateParam && endDateParam) {
      startDate = new Date(startDateParam);
      endDate = new Date(endDateParam);
    } else {
      // Default to current week
      const now = new Date();
      const dayOfWeek = now.getDay();
      startDate = new Date(now);
      startDate.setDate(now.getDate() - dayOfWeek);
      startDate.setHours(0, 0, 0, 0);
      
      endDate = new Date(startDate);
      endDate.setDate(startDate.getDate() + 6);
      endDate.setHours(23, 59, 59, 999);
    }

    const summary = await getWeeklySummary(req.user!.userId, startDate, endDate);
    res.json(summary);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

// Monthly summary
router.get('/monthly', async (req: AuthRequest, res: Response) => {
  try {
    const yearParam = req.query.year as string;
    const monthParam = req.query.month as string;

    const now = new Date();
    const year = yearParam ? parseInt(yearParam) : now.getFullYear();
    const month = monthParam ? parseInt(monthParam) : now.getMonth() + 1;

    const summary = await getMonthlySummary(req.user!.userId, year, month);
    res.json(summary);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

export default router;
