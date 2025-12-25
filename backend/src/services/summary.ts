import { PrismaClient, Category } from '@prisma/client';
import { prisma } from '../config/database';

export interface CategoryBreakdown {
  category: Category;
  amount: number;
  count: number;
}

export interface DailySummary {
  date: string;
  total: number;
  count: number;
  breakdown: CategoryBreakdown[];
}

export interface WeeklySummary {
  week: string;
  startDate: string;
  endDate: string;
  total: number;
  count: number;
  breakdown: CategoryBreakdown[];
  dailyTotals: { date: string; total: number }[];
}

export interface MonthlySummary {
  month: string;
  year: number;
  total: number;
  count: number;
  breakdown: CategoryBreakdown[];
  dailyTotals: { date: string; total: number }[];
}

export const getDailySummary = async (
  userId: string,
  date: Date
): Promise<DailySummary> => {
  const startOfDay = new Date(date);
  startOfDay.setHours(0, 0, 0, 0);
  
  const endOfDay = new Date(date);
  endOfDay.setHours(23, 59, 59, 999);

  const expenses = await prisma.expense.findMany({
    where: {
      userId,
      date: {
        gte: startOfDay,
        lte: endOfDay,
      },
    },
  });

  const total = expenses.reduce((sum, exp) => sum + exp.amount, 0);
  
  const breakdownMap = new Map<Category, { amount: number; count: number }>();
  
  expenses.forEach((exp) => {
    const existing = breakdownMap.get(exp.category) || { amount: 0, count: 0 };
    breakdownMap.set(exp.category, {
      amount: existing.amount + exp.amount,
      count: existing.count + 1,
    });
  });

  const breakdown: CategoryBreakdown[] = Array.from(breakdownMap.entries()).map(
    ([category, data]) => ({
      category,
      amount: data.amount,
      count: data.count,
    })
  );

  return {
    date: date.toISOString().split('T')[0],
    total,
    count: expenses.length,
    breakdown,
  };
};

export const getWeeklySummary = async (
  userId: string,
  startDate: Date,
  endDate: Date
): Promise<WeeklySummary> => {
  const expenses = await prisma.expense.findMany({
    where: {
      userId,
      date: {
        gte: startDate,
        lte: endDate,
      },
    },
    orderBy: {
      date: 'asc',
    },
  });

  const total = expenses.reduce((sum, exp) => sum + exp.amount, 0);

  const breakdownMap = new Map<Category, { amount: number; count: number }>();
  const dailyTotalsMap = new Map<string, number>();

  expenses.forEach((exp) => {
    // Category breakdown
    const existing = breakdownMap.get(exp.category) || { amount: 0, count: 0 };
    breakdownMap.set(exp.category, {
      amount: existing.amount + exp.amount,
      count: existing.count + 1,
    });

    // Daily totals
    const dateKey = exp.date.toISOString().split('T')[0];
    dailyTotalsMap.set(dateKey, (dailyTotalsMap.get(dateKey) || 0) + exp.amount);
  });

  const breakdown: CategoryBreakdown[] = Array.from(breakdownMap.entries()).map(
    ([category, data]) => ({
      category,
      amount: data.amount,
      count: data.count,
    })
  );

  const dailyTotals = Array.from(dailyTotalsMap.entries()).map(([date, total]) => ({
    date,
    total,
  }));

  return {
    week: `${startDate.toISOString().split('T')[0]} to ${endDate.toISOString().split('T')[0]}`,
    startDate: startDate.toISOString().split('T')[0],
    endDate: endDate.toISOString().split('T')[0],
    total,
    count: expenses.length,
    breakdown,
    dailyTotals,
  };
};

export const getMonthlySummary = async (
  userId: string,
  year: number,
  month: number
): Promise<MonthlySummary> => {
  const startDate = new Date(year, month - 1, 1);
  const endDate = new Date(year, month, 0, 23, 59, 59, 999);

  const expenses = await prisma.expense.findMany({
    where: {
      userId,
      date: {
        gte: startDate,
        lte: endDate,
      },
    },
    orderBy: {
      date: 'asc',
    },
  });

  const total = expenses.reduce((sum, exp) => sum + exp.amount, 0);

  const breakdownMap = new Map<Category, { amount: number; count: number }>();
  const dailyTotalsMap = new Map<string, number>();

  expenses.forEach((exp) => {
    // Category breakdown
    const existing = breakdownMap.get(exp.category) || { amount: 0, count: 0 };
    breakdownMap.set(exp.category, {
      amount: existing.amount + exp.amount,
      count: existing.count + 1,
    });

    // Daily totals
    const dateKey = exp.date.toISOString().split('T')[0];
    dailyTotalsMap.set(dateKey, (dailyTotalsMap.get(dateKey) || 0) + exp.amount);
  });

  const breakdown: CategoryBreakdown[] = Array.from(breakdownMap.entries()).map(
    ([category, data]) => ({
      category,
      amount: data.amount,
      count: data.count,
    })
  );

  const dailyTotals = Array.from(dailyTotalsMap.entries()).map(([date, total]) => ({
    date,
    total,
  }));

  const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  return {
    month: monthNames[month - 1],
    year,
    total,
    count: expenses.length,
    breakdown,
    dailyTotals,
  };
};
