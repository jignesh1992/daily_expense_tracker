import { Router, Request, Response } from 'express';
import { verifyToken, AuthRequest } from '../middleware/auth';
import { prisma } from '../config/database';
import { validateExpense } from '../utils/validation';
import { NotFoundError } from '../utils/errors';

const router = Router();

// All routes require authentication
router.use(verifyToken);

// Create expense
router.post('/', async (req: AuthRequest, res: Response) => {
  try {
    const { amount, category, description, date } = req.body;

    validateExpense({ amount, category, date: date || new Date() });

    const expense = await prisma.expense.create({
      data: {
        userId: req.user!.userId,
        amount,
        category,
        description,
        date: date ? new Date(date) : new Date(),
      },
    });

    res.status(201).json(expense);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

// Get all expenses with filters
router.get('/', async (req: AuthRequest, res: Response) => {
  try {
    const { date, category, startDate, endDate } = req.query;

    const where: any = {
      userId: req.user!.userId,
    };

    if (date) {
      const filterDate = new Date(date as string);
      const startOfDay = new Date(filterDate);
      startOfDay.setHours(0, 0, 0, 0);
      const endOfDay = new Date(filterDate);
      endOfDay.setHours(23, 59, 59, 999);
      
      where.date = {
        gte: startOfDay,
        lte: endOfDay,
      };
    } else if (startDate && endDate) {
      where.date = {
        gte: new Date(startDate as string),
        lte: new Date(endDate as string),
      };
    }

    if (category) {
      where.category = category;
    }

    const expenses = await prisma.expense.findMany({
      where,
      orderBy: {
        date: 'desc',
      },
    });

    res.json(expenses);
  } catch (error: any) {
    res.status(400).json({ error: error.message });
  }
});

// Get single expense
router.get('/:id', async (req: AuthRequest, res: Response) => {
  try {
    const expense = await prisma.expense.findFirst({
      where: {
        id: req.params.id,
        userId: req.user!.userId,
      },
    });

    if (!expense) {
      throw new NotFoundError('Expense');
    }

    res.json(expense);
  } catch (error: any) {
    if (error instanceof NotFoundError) {
      res.status(404).json({ error: error.message });
    } else {
      res.status(400).json({ error: error.message });
    }
  }
});

// Update expense
router.put('/:id', async (req: AuthRequest, res: Response) => {
  try {
    const { amount, category, description, date } = req.body;

    const existing = await prisma.expense.findFirst({
      where: {
        id: req.params.id,
        userId: req.user!.userId,
      },
    });

    if (!existing) {
      throw new NotFoundError('Expense');
    }

    validateExpense({ amount, category, date });

    const expense = await prisma.expense.update({
      where: { id: req.params.id },
      data: {
        ...(amount !== undefined && { amount }),
        ...(category !== undefined && { category }),
        ...(description !== undefined && { description }),
        ...(date !== undefined && { date: new Date(date) }),
      },
    });

    res.json(expense);
  } catch (error: any) {
    if (error instanceof NotFoundError) {
      res.status(404).json({ error: error.message });
    } else {
      res.status(400).json({ error: error.message });
    }
  }
});

// Delete expense
router.delete('/:id', async (req: AuthRequest, res: Response) => {
  try {
    const expense = await prisma.expense.findFirst({
      where: {
        id: req.params.id,
        userId: req.user!.userId,
      },
    });

    if (!expense) {
      throw new NotFoundError('Expense');
    }

    await prisma.expense.delete({
      where: { id: req.params.id },
    });

    res.status(204).send();
  } catch (error: any) {
    if (error instanceof NotFoundError) {
      res.status(404).json({ error: error.message });
    } else {
      res.status(400).json({ error: error.message });
    }
  }
});

export default router;
