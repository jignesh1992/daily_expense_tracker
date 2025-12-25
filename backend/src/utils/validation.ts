import { Category } from '@prisma/client';
import { ValidationError } from './errors';

const VALID_CATEGORIES: Category[] = [
  'food',
  'transport',
  'shopping',
  'entertainment',
  'bills',
  'other',
];

export const validateExpense = (data: {
  amount?: number;
  category?: string;
  date?: string | Date;
}): void => {
  if (data.amount !== undefined) {
    if (typeof data.amount !== 'number' || data.amount <= 0) {
      throw new ValidationError('Amount must be a positive number');
    }
  }

  if (data.category !== undefined) {
    if (!VALID_CATEGORIES.includes(data.category as Category)) {
      throw new ValidationError(
        `Category must be one of: ${VALID_CATEGORIES.join(', ')}`
      );
    }
  }

  if (data.date !== undefined) {
    const date = typeof data.date === 'string' ? new Date(data.date) : data.date;
    if (isNaN(date.getTime())) {
      throw new ValidationError('Invalid date format');
    }
  }
};

export const validateDateRange = (startDate: string, endDate: string): void => {
  const start = new Date(startDate);
  const end = new Date(endDate);

  if (isNaN(start.getTime()) || isNaN(end.getTime())) {
    throw new ValidationError('Invalid date range format');
  }

  if (start > end) {
    throw new ValidationError('Start date must be before end date');
  }
};
