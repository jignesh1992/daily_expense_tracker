import { Router, Request, Response } from 'express';
import { verifyToken } from '../middleware/auth';

const router = Router();

router.post('/verify', verifyToken, async (req: any, res: Response) => {
  res.json({
    success: true,
    user: {
      uid: req.user.uid,
      email: req.user.email,
      userId: req.user.userId,
    },
  });
});

export default router;
