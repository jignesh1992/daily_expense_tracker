import { Request, Response, NextFunction } from 'express';
import { firebaseAdmin } from '../config/firebase';
import { prisma } from '../config/database';

export interface AuthRequest extends Request {
  user?: {
    uid: string;
    email: string;
    userId: string;
  };
}

export const verifyToken = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      res.status(401).json({ error: 'Unauthorized: No token provided' });
      return;
    }

    const token = authHeader.split('Bearer ')[1];
    
    const decodedToken = await firebaseAdmin.auth().verifyIdToken(token);
    
    // Get or create user in database
    let user = await prisma.user.findUnique({
      where: { firebaseUid: decodedToken.uid },
    });

    if (!user) {
      user = await prisma.user.create({
        data: {
          firebaseUid: decodedToken.uid,
          email: decodedToken.email || '',
        },
      });
    }

    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email || '',
      userId: user.id,
    };

    next();
  } catch (error) {
    console.error('Token verification error:', error);
    res.status(401).json({ error: 'Unauthorized: Invalid token' });
  }
};
