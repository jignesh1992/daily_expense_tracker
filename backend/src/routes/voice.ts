import { Router, Request, Response } from 'express';
import { verifyToken } from '../middleware/auth';
import { parseVoiceInput } from '../services/claude';

const router = Router();

router.use(verifyToken);

router.post('/parse', async (req: Request, res: Response) => {
  try {
    const { text } = req.body;

    if (!text || typeof text !== 'string') {
      res.status(400).json({ error: 'Text input is required' });
      return;
    }

    const parsed = await parseVoiceInput(text);
    res.json(parsed);
  } catch (error: any) {
    console.error('Voice parsing error:', error);
    res.status(500).json({ 
      error: 'Failed to parse voice input',
      message: error.message 
    });
  }
});

export default router;
