import Anthropic from '@anthropic-ai/sdk';
import { Category } from '@prisma/client';

const anthropic = new Anthropic({
  apiKey: process.env.CLAUDE_API_KEY || '',
});

export interface ParsedExpense {
  amount: number;
  category: Category;
  description?: string;
}

const CATEGORY_MAPPING: Record<string, Category> = {
  food: 'food',
  meal: 'food',
  restaurant: 'food',
  groceries: 'food',
  transport: 'transport',
  taxi: 'transport',
  uber: 'transport',
  bus: 'transport',
  train: 'transport',
  shopping: 'shopping',
  purchase: 'shopping',
  buy: 'shopping',
  entertainment: 'entertainment',
  movie: 'entertainment',
  game: 'entertainment',
  bills: 'bills',
  bill: 'bills',
  utility: 'bills',
  other: 'other',
};

export const parseVoiceInput = async (text: string): Promise<ParsedExpense> => {
  try {
    const prompt = `Parse the following expense input and extract the amount, category, and optional description. 
Return ONLY a valid JSON object with this exact structure: {"amount": number, "category": "food"|"transport"|"shopping"|"entertainment"|"bills"|"other", "description": string or null}

Input: "${text}"

Rules:
- Amount must be a positive number (extract numeric value, ignore currency symbols)
- Category must be one of: food, transport, shopping, entertainment, bills, other
- Description is optional, can be null or empty string
- If category is unclear, use "other"
- Return ONLY the JSON object, no other text

Example inputs and outputs:
- "₹500 food" -> {"amount": 500, "category": "food", "description": null}
- "100 rupees for taxi" -> {"amount": 100, "category": "transport", "description": "taxi"}
- "2000 shopping clothes" -> {"amount": 2000, "category": "shopping", "description": "clothes"}`;

    const message = await anthropic.messages.create({
      model: 'claude-3-5-sonnet-20241022',
      max_tokens: 1024,
      messages: [
        {
          role: 'user',
          content: prompt,
        },
      ],
    });

    const content = message.content[0];
    if (content.type !== 'text') {
      throw new Error('Unexpected response type from Claude API');
    }

    const responseText = content.text.trim();
    
    // Extract JSON from response (handle cases where there might be markdown code blocks)
    let jsonText = responseText;
    if (responseText.startsWith('```')) {
      jsonText = responseText.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
    }

    const parsed = JSON.parse(jsonText) as ParsedExpense;

    // Validate and normalize category
    const normalizedCategory = normalizeCategory(parsed.category);
    
    // Validate amount
    if (!parsed.amount || parsed.amount <= 0) {
      throw new Error('Invalid amount extracted');
    }

    return {
      amount: parsed.amount,
      category: normalizedCategory,
      description: parsed.description || undefined,
    };
  } catch (error) {
    console.error('Claude parsing error:', error);
    
    // Fallback: try simple regex parsing
    return fallbackParse(text);
  }
};

const normalizeCategory = (category: string): Category => {
  const lower = category.toLowerCase().trim();
  
  // Direct match
  if (CATEGORY_MAPPING[lower]) {
    return CATEGORY_MAPPING[lower];
  }

  // Partial match
  for (const [key, value] of Object.entries(CATEGORY_MAPPING)) {
    if (lower.includes(key)) {
      return value;
    }
  }

  return 'other';
};

const fallbackParse = (text: string): ParsedExpense => {
  // Simple regex fallback
  const amountMatch = text.match(/[\d.]+/);
  const amount = amountMatch ? parseFloat(amountMatch[0]) : 0;

  let category: Category = 'other';
  const lowerText = text.toLowerCase();
  
  if (lowerText.match(/\b(food|meal|restaurant|groceries|eat)\b/)) {
    category = 'food';
  } else if (lowerText.match(/\b(transport|taxi|uber|bus|train|travel)\b/)) {
    category = 'transport';
  } else if (lowerText.match(/\b(shopping|purchase|buy|shop)\b/)) {
    category = 'shopping';
  } else if (lowerText.match(/\b(entertainment|movie|game|fun)\b/)) {
    category = 'entertainment';
  } else if (lowerText.match(/\b(bill|bills|utility)\b/)) {
    category = 'bills';
  }

  return {
    amount: amount || 0,
    category,
    description: text.trim(),
  };
};
