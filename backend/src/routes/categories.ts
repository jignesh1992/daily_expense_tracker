import { Router, Request, Response } from 'express';
import { Category } from '@prisma/client';

const router = Router();

router.get('/', async (req: Request, res: Response) => {
  const categories: Category[] = [
    'food',
    'transport',
    'shopping',
    'entertainment',
    'bills',
    'other',
  ];

  res.json(categories);
});

export default router;
