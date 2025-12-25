import { parseVoiceInput } from '../../src/services/claude';

describe('Claude Service', () => {
  describe('parseVoiceInput', () => {
    it('should parse simple expense input', async () => {
      const result = await parseVoiceInput('₹500 food');
      
      expect(result).toHaveProperty('amount');
      expect(result).toHaveProperty('category');
      expect(result.amount).toBeGreaterThan(0);
      expect(['food', 'transport', 'shopping', 'entertainment', 'bills', 'other']).toContain(result.category);
    });

    it('should handle fallback parsing', async () => {
      // Mock Claude API failure
      process.env.CLAUDE_API_KEY = '';
      
      const result = await parseVoiceInput('100 rupees for taxi');
      
      expect(result).toHaveProperty('amount');
      expect(result).toHaveProperty('category');
    });
  });
});
