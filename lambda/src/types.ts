import { z } from 'zod';

export const coffeeOrderSchema = z.object({
  personName: z.string(),
  coffeeType: z.enum(['Flat White', 'Latte', 'Black', 'Iced']),
  milkType: z.enum(['Oat', 'Soy', 'Almond', 'Rice']),
});

export type CoffeeOrder = z.infer<typeof coffeeOrderSchema>;

export const coffeeOrderUpdateSchema = z.object({
  personName: z.string().optional(),
  coffeeType: z.enum(['Flat White', 'Latte', 'Black', 'Iced']).optional(),
  milkType: z.enum(['Oat', 'Soy', 'Almond', 'Rice']).optional(),
});

export type CoffeeOrderUpdate = z.infer<typeof coffeeOrderUpdateSchema>;
