-- =====================================================
-- MEAL TEMPLATE SEED DATA
-- Inserts seed user + nutrition plan first, then meal templates
-- =====================================================

-- 1. Seed user (skip if already exists)
INSERT IGNORE INTO `user` (username, email, password_hash, date_of_birth, gender, height_cm, current_weight_kg, target_weight_kg, date_joined, fitness_level, role, onboarding_completed)
VALUES ('seed_user', 'seed@gymplan.dev', '$2a$10$dummyHashForSeedUserOnly000000000000000000000000000000', '1995-06-15', 'MALE', 175.0, 80.0, 75.0, CURDATE(), 'INTERMEDIATE', 'USER', true);

-- 2. Seed nutrition plan for that user (skip if already exists)
INSERT IGNORE INTO nutrition_plan (user_id, goal_id, plan_name, daily_calorie_target, protein_percentage, carbs_percentage, fats_percentage, cheat_meals_per_week, algorithm_version, version, auto_adjust_enabled, is_active, created_at, updated_at)
VALUES (
    (SELECT user_id FROM `user` WHERE username = 'seed_user' LIMIT 1),
    (SELECT goal_id FROM goal WHERE goal_name = 'Build Muscle' LIMIT 1),
    'Seed Balanced Plan', 2200, 30.0, 45.0, 25.0, 1,
    'RULE_BASED_V1', 1, false, true, NOW(), NOW()
);

-- 3. Meal templates referencing the seed nutrition plan via subquery
INSERT IGNORE INTO meal_template (nutrition_plan_id, meal_name, meal_type, description, calories, proteinG, carbsG, fatsG, recipe_instructions) VALUES
-- ===== BREAKFAST =====
((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Classic Oatmeal & Eggs', 'BREAKFAST', 'A hearty breakfast combining slow-digesting oats with protein-rich eggs for sustained energy.', 450, 30.0, 45.0, 15.0,
 'Ingredients:\n- 80g rolled oats\n- 3 whole eggs\n- 1 banana\n- 1 tbsp honey\n- Pinch of cinnamon\n\nInstructions:\n1. Cook oats with water or milk until creamy\n2. Scramble or fry eggs to your preference\n3. Top oats with sliced banana, honey, and cinnamon\n4. Serve eggs on the side'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Greek Yogurt Protein Bowl', 'BREAKFAST', 'A quick, high-protein breakfast bowl loaded with antioxidants and healthy fats.', 400, 35.0, 40.0, 12.0,
 'Ingredients:\n- 200g Greek yogurt (0% fat)\n- 30g granola\n- 1 scoop whey protein\n- 100g mixed berries\n- 15g almonds\n- 1 tsp chia seeds\n\nInstructions:\n1. Mix protein powder into Greek yogurt\n2. Top with granola, berries, almonds, and chia seeds\n3. Drizzle with a little honey if desired'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Avocado Toast & Turkey', 'BREAKFAST', 'Modern classic breakfast with wholesome fats and lean protein from turkey slices.', 420, 28.0, 35.0, 18.0,
 'Ingredients:\n- 2 slices whole grain bread\n- 1/2 ripe avocado\n- 100g turkey breast slices\n- 1 egg (poached or fried)\n- Cherry tomatoes\n- Salt, pepper, red pepper flakes\n\nInstructions:\n1. Toast bread until golden\n2. Mash avocado and spread on toast\n3. Layer turkey slices on top\n4. Add poached/fried egg\n5. Season with salt, pepper, and red pepper flakes\n6. Serve with cherry tomatoes on the side'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Protein Pancakes', 'BREAKFAST', 'Fluffy pancakes packed with protein - perfect pre-workout fuel.', 480, 32.0, 50.0, 14.0,
 'Ingredients:\n- 80g oat flour\n- 1 scoop protein powder (vanilla)\n- 2 eggs\n- 100ml milk\n- 1 banana (mashed)\n- 1 tsp baking powder\n- 15g peanut butter\n- Fresh berries\n\nInstructions:\n1. Blend oat flour, protein powder, eggs, milk, banana, and baking powder\n2. Cook on non-stick pan over medium heat\n3. Flip when bubbles appear\n4. Stack and top with peanut butter and berries'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Egg & Veggie Scramble', 'BREAKFAST', 'A vegetable-loaded egg scramble providing vitamins, minerals, and quality protein.', 380, 28.0, 20.0, 22.0,
 'Ingredients:\n- 4 eggs\n- 50g spinach\n- 50g bell peppers (diced)\n- 30g mushrooms (sliced)\n- 30g onion (diced)\n- 30g feta cheese\n- 1 tsp olive oil\n\nInstructions:\n1. Heat olive oil in pan over medium heat\n2. Saute onion and peppers for 2-3 minutes\n3. Add mushrooms and cook 2 minutes\n4. Add spinach, cook until wilted\n5. Pour in beaten eggs, stir gently\n6. Crumble feta on top and serve'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Overnight Protein Oats', 'BREAKFAST', 'No-cook prep-ahead breakfast - grab from the fridge and go.', 430, 30.0, 48.0, 12.0,
 'Ingredients:\n- 70g rolled oats\n- 200ml almond milk\n- 1 scoop protein powder (chocolate)\n- 1 tbsp chia seeds\n- 1 tbsp cocoa powder\n- 1/2 banana (sliced)\n- 10g dark chocolate chips\n\nInstructions:\n1. Mix oats, milk, protein powder, chia seeds, and cocoa in a jar\n2. Stir well, seal, and refrigerate overnight\n3. In the morning top with banana slices and chocolate chips\n4. Eat cold or microwave 1-2 minutes'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Smoothie Power Bowl', 'BREAKFAST', 'A thick, blended smoothie bowl with toppings for a refreshing high-protein breakfast.', 440, 32.0, 50.0, 10.0,
 'Ingredients:\n- 1 scoop protein powder (vanilla)\n- 1 frozen banana\n- 100g frozen mixed berries\n- 100ml almond milk\n- 20g granola\n- 10g coconut flakes\n- 1 tbsp pumpkin seeds\n\nInstructions:\n1. Blend protein powder, banana, berries, and milk until thick\n2. Pour into a bowl\n3. Top with granola, coconut flakes, and pumpkin seeds\n4. Eat immediately with a spoon'),

-- ===== LUNCH =====
((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Grilled Chicken & Quinoa Bowl', 'LUNCH', 'A balanced, macro-friendly bowl with lean protein, complex carbs, and fiber-rich vegetables.', 550, 42.0, 50.0, 16.0,
 'Ingredients:\n- 150g chicken breast\n- 80g quinoa (dry)\n- 100g broccoli\n- 50g cherry tomatoes\n- 1/2 avocado\n- Lemon juice, garlic, paprika\n\nInstructions:\n1. Season chicken with garlic, paprika, salt, and pepper\n2. Grill chicken 6-7 minutes per side until cooked through\n3. Cook quinoa in water for 15 minutes\n4. Steam broccoli until tender-crisp\n5. Slice chicken and arrange over quinoa\n6. Add tomatoes and avocado slices\n7. Drizzle with lemon juice'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Tuna & Brown Rice Plate', 'LUNCH', 'Simple yet effective meal with omega-3 rich tuna and slow-release carbohydrates.', 500, 40.0, 52.0, 12.0,
 'Ingredients:\n- 150g canned tuna (in water, drained)\n- 80g brown rice (dry)\n- 100g mixed salad greens\n- 50g cucumber\n- 50g corn kernels\n- 1 tbsp olive oil\n- Lemon, salt, pepper\n\nInstructions:\n1. Cook brown rice according to package\n2. Drain tuna and mix with lemon juice and olive oil\n3. Arrange salad greens on plate\n4. Add rice, tuna, cucumber, and corn\n5. Season to taste'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Turkey Wrap with Veggies', 'LUNCH', 'Portable, protein-packed wrap ideal for busy days - great for meal prep.', 480, 38.0, 42.0, 16.0,
 'Ingredients:\n- 1 large whole wheat tortilla\n- 120g turkey breast (sliced)\n- 30g hummus\n- 50g lettuce\n- 50g tomato (sliced)\n- 30g cucumber (sliced)\n- 30g shredded carrot\n\nInstructions:\n1. Spread hummus evenly on tortilla\n2. Layer turkey slices over hummus\n3. Add lettuce, tomato, cucumber, and carrot\n4. Roll tightly and cut in half\n5. Wrap in foil for on-the-go meals'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Salmon & Sweet Potato', 'LUNCH', 'A nutrient-dense plate with omega-3-rich salmon and complex carbs from sweet potato.', 580, 38.0, 48.0, 22.0,
 'Ingredients:\n- 150g salmon fillet\n- 200g sweet potato\n- 100g asparagus\n- 1 tbsp olive oil\n- Lemon, garlic, dill\n\nInstructions:\n1. Preheat oven to 200C (400F)\n2. Cube sweet potato, toss with olive oil, and roast 25 minutes\n3. Season salmon with garlic, dill, and lemon\n4. Bake salmon for 12-15 minutes\n5. Steam or roast asparagus\n6. Plate everything together'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Chicken Stir-Fry Noodles', 'LUNCH', 'Asian-inspired stir-fry with lean chicken, colorful vegetables, and whole grain noodles.', 520, 40.0, 55.0, 14.0,
 'Ingredients:\n- 150g chicken breast (sliced thin)\n- 80g whole wheat noodles\n- 50g bell peppers (mixed colors)\n- 50g broccoli\n- 30g carrot (julienned)\n- 2 tbsp soy sauce (low sodium)\n- 1 tsp sesame oil\n- 1 clove garlic, ginger\n\nInstructions:\n1. Cook noodles according to package, drain\n2. Heat sesame oil in wok over high heat\n3. Stir-fry chicken with garlic and ginger 4-5 minutes\n4. Add vegetables, cook 3-4 minutes\n5. Add noodles and soy sauce\n6. Toss everything together and serve'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Beef & Black Bean Bowl', 'LUNCH', 'High-protein Tex-Mex style bowl with lean beef and fiber-rich black beans.', 560, 44.0, 48.0, 18.0,
 'Ingredients:\n- 130g lean ground beef (95% lean)\n- 80g black beans (canned, drained)\n- 80g brown rice (dry)\n- 50g corn\n- 30g diced tomatoes\n- 20g cheddar cheese\n- Cumin, chili powder, lime\n\nInstructions:\n1. Cook rice according to package\n2. Brown ground beef with cumin and chili powder\n3. Warm black beans and corn\n4. Build bowl: rice, beef, beans, corn, tomatoes\n5. Top with cheese and a squeeze of lime'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Lentil & Chickpea Buddha Bowl', 'LUNCH', 'Plant-based powerhouse bowl with legumes, roasted veggies, and tahini dressing.', 510, 28.0, 60.0, 16.0,
 'Ingredients:\n- 80g green lentils (dry)\n- 80g chickpeas (canned, drained)\n- 100g roasted sweet potato cubes\n- 50g baby spinach\n- 50g cucumber\n- 1 tbsp tahini\n- Lemon juice, garlic\n\nInstructions:\n1. Cook lentils in salted water 20-25 minutes\n2. Roast sweet potato cubes at 200C for 20 minutes\n3. Make dressing: mix tahini, lemon juice, garlic, and water\n4. Arrange spinach, lentils, chickpeas, sweet potato, cucumber in a bowl\n5. Drizzle with tahini dressing'),

-- ===== DINNER =====
((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Baked Chicken Breast & Veggies', 'DINNER', 'A lean, clean dinner with perfectly seasoned chicken and roasted seasonal vegetables.', 480, 42.0, 30.0, 18.0,
 'Ingredients:\n- 180g chicken breast\n- 100g broccoli\n- 100g zucchini\n- 50g bell pepper\n- 1 tbsp olive oil\n- Italian seasoning, garlic powder\n\nInstructions:\n1. Preheat oven to 200C (400F)\n2. Season chicken with Italian seasoning, garlic powder, salt, pepper\n3. Cut vegetables into even pieces\n4. Toss veggies in olive oil and seasoning\n5. Bake chicken and veggies on sheet pan for 25 minutes\n6. Let chicken rest 5 minutes before slicing'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Grilled Salmon with Steamed Rice', 'DINNER', 'Heart-healthy salmon rich in omega-3s paired with jasmine rice and green beans.', 540, 38.0, 45.0, 20.0,
 'Ingredients:\n- 160g salmon fillet\n- 80g jasmine rice (dry)\n- 100g green beans\n- 1 tsp olive oil\n- Lemon, fresh dill, capers\n\nInstructions:\n1. Cook rice according to package\n2. Season salmon with salt, pepper, and dill\n3. Grill or pan-sear salmon 4-5 min per side\n4. Steam green beans until tender-crisp\n5. Plate rice, salmon, and beans\n6. Garnish with lemon wedge and capers'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Lean Beef Steak & Potatoes', 'DINNER', 'Classic steak dinner with roasted baby potatoes and a side salad - great post-workout.', 600, 45.0, 45.0, 22.0,
 'Ingredients:\n- 180g sirloin steak (lean)\n- 200g baby potatoes\n- 50g mixed salad greens\n- 30g cherry tomatoes\n- 1 tbsp olive oil\n- Rosemary, garlic, salt, pepper\n\nInstructions:\n1. Boil or roast baby potatoes with rosemary until golden (25 min at 200C)\n2. Season steak generously with salt, pepper, and garlic\n3. Sear steak in hot pan 3-4 min per side (medium-rare)\n4. Rest steak for 5 minutes\n5. Serve with potatoes and a simple side salad'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Shrimp & Zucchini Noodles', 'DINNER', 'Low-carb, high-protein dinner using spiralized zucchini as a pasta alternative.', 380, 35.0, 18.0, 18.0,
 'Ingredients:\n- 180g shrimp (peeled, deveined)\n- 2 medium zucchini (spiralized)\n- 50g cherry tomatoes (halved)\n- 2 cloves garlic (minced)\n- 1 tbsp olive oil\n- 30g parmesan cheese\n- Fresh basil, red pepper flakes\n\nInstructions:\n1. Heat olive oil in pan, saute garlic 30 seconds\n2. Cook shrimp 2-3 min per side until pink\n3. Remove shrimp, add zucchini noodles and tomatoes\n4. Cook 2-3 minutes until just tender\n5. Return shrimp to pan, toss together\n6. Top with parmesan, basil, and red pepper flakes'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Turkey Meatballs with Pasta', 'DINNER', 'Lean turkey meatballs in marinara sauce over whole grain pasta - comfort food made healthy.', 560, 40.0, 55.0, 16.0,
 'Ingredients:\n- 150g ground turkey\n- 80g whole wheat pasta\n- 100ml marinara sauce\n- 1 egg (for binding)\n- 20g breadcrumbs\n- Italian herbs, garlic\n- 20g parmesan\n\nInstructions:\n1. Mix ground turkey with egg, breadcrumbs, garlic, Italian herbs\n2. Form into 6-8 meatballs\n3. Bake meatballs at 190C for 20 minutes\n4. Cook pasta according to package\n5. Warm marinara sauce, add meatballs\n6. Serve meatballs and sauce over pasta\n7. Top with grated parmesan'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Tofu & Vegetable Curry', 'DINNER', 'A flavorful plant-based dinner with creamy coconut curry and protein-rich tofu.', 470, 24.0, 42.0, 22.0,
 'Ingredients:\n- 200g firm tofu (pressed, cubed)\n- 100ml light coconut milk\n- 80g brown rice (dry)\n- 100g mixed vegetables (peppers, peas, carrots)\n- 2 tbsp curry paste (red or yellow)\n- 1 tbsp coconut oil\n- Fresh cilantro, lime\n\nInstructions:\n1. Cook rice according to package\n2. Press and cube tofu, pan-fry until golden\n3. Saute curry paste in coconut oil 1 minute\n4. Add coconut milk and vegetables, simmer 10 minutes\n5. Add tofu, cook 5 more minutes\n6. Serve curry over rice\n7. Garnish with cilantro and lime wedge'),

((SELECT nutrition_plan_id FROM nutrition_plan WHERE plan_name = 'Seed Balanced Plan' LIMIT 1),
 'Herb-Crusted Cod with Quinoa', 'DINNER', 'Light yet satisfying white fish dinner with herbed crust and fluffy quinoa pilaf.', 450, 38.0, 40.0, 14.0,
 'Ingredients:\n- 170g cod fillet\n- 80g quinoa (dry)\n- 100g spinach\n- 30g breadcrumbs\n- Fresh parsley, dill\n- 1 tbsp olive oil\n- Lemon, garlic\n\nInstructions:\n1. Cook quinoa in vegetable broth for 15 minutes\n2. Mix breadcrumbs with chopped herbs, garlic, and olive oil\n3. Press herb mixture onto cod fillet\n4. Bake at 200C for 15-18 minutes until flaky\n5. Saute spinach with garlic until wilted\n6. Plate quinoa, spinach, and cod\n7. Squeeze fresh lemon over fish');
