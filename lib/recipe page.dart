
import 'dart:async';
import 'package:fitnessapp/database_handler.dart';
import 'package:fitnessapp/payUserModel.dart';
import 'package:fitnessapp/user_repo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {

  Map<String, dynamic>? paymentIntentData;

  Database? _database;
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController(text: '+923');
  TextEditingController emailController = TextEditingController();
  @override
  int selectedIndex = 0; // Default to "All"
  TextEditingController searchController = TextEditingController();

  // Adding category to each recipe
  List<Map<String, String>> allRecipes = [
    {
      'name': 'Quinoa and Chickpea Salad',
      'image': 'assets/images/quiona.jpg',
      'ingredients': 'Quinoa, Chickpeas, Cucumber, Tomatoes, Red Onion, Parsley',
      'recipe': 'Cook quinoa and let it cool. Mix with chickpeas, chopped cucumber, tomatoes, red onion, and parsley. Dress with olive oil, lemon juice, salt, and pepper.',
      'category': 'Salad',
      'videoUrl': 'https://youtu.be/GnugYR9xS24?si=bw2JdAkpaGqnxHUc',
      'calories': '1 serving 270',

      // Add your video URL here

    },
    {
      'name': 'Greek salad',
      'image': 'assets/images/grreek.jpg',
      'ingredients': 'Tomatoes, Cucumbers, Onions, Feta Cheese, Olives',
      'recipe': 'Mix chopped tomatoes, cucumbers, onions, feta cheese, and olives. Dress with olive oil and oregano.',
      'category': 'Salad',
      'videoUrl': 'https://youtu.be/j7rU-1-s7NM?si=NIYbCVpkySjEyN6M',
      'calories': '1 serving 270 ',
    },
    {
      'name': 'Avocado and Black Bean Salad',
      'image': 'assets/images/avoda.jpg',
      'ingredients': 'Avocado, Black Beans, Corn, Red Bell Pepper, Lime Juice, Cilantro',
      'recipe': 'Mix diced avocado, black beans, corn, diced red bell pepper, lime juice, and chopped cilantro.',
      'category': 'Salad',
      'videoUrl': 'https://youtu.be/i8Cne9rkazI?si=pSoFV_lgxVrSre0d',
      'calories': '1 serving 200',

    },
    {
      'name': 'Spinach and Strawberry Salad',
      'image': 'assets/images/strawberry salad.jpg',
      'ingredients': 'Spinach, Strawberries, Almonds, Goat Cheese, Balsamic Vinaigrette',
      'recipe': 'Toss spinach, sliced strawberries, almonds, and crumbled goat cheese. Dress with balsamic vinaigrette.',
      'category': 'Salad',
      'videoUrl': 'https://youtu.be/IuaZNSru84Q?si=xhoCYBahouUM73Bw',
      'calories': '1 serving 180 ',
    },
    {
      'name': 'Asian Chicken Salad',
      'image': 'assets/images/asian.jpg',
      'ingredients': 'Chicken Breast, Mixed Greens, Red Cabbage, Carrot, Red Bell Pepper, Green Onions, Cilantro, Almonds, Sesame Seeds',
      'recipe': 'Mix shredded chicken, mixed greens, shredded red cabbage, julienned carrot, sliced red bell pepper, green onions, chopped cilantro, toasted almonds, and sesame seeds. Dress with a mixture of soy sauce, rice vinegar, sesame oil, honey, lime juice, garlic, and ginger.',
      'category': 'Salad',
      'videoUrl': 'https://youtu.be/d9W2jg92ZYc?si=7oFp7U6AQvJF5UtE',
      'calories': '1 serving (approximately 2 cups) 350',

    },
    {
      'name': 'Mediterranean Farro Salad',
      'image': 'assets/images/meditarrian.jpg',
      'ingredients': 'Farro, Cucumber, Cherry Tomatoes, Red Onion, Kalamata Olives, Feta Cheese, Parsley, Mint',
      'recipe': 'Mix cooked farro, diced cucumber, halved cherry tomatoes, chopped red onion, pitted and halved Kalamata olives, crumbled feta cheese, chopped parsley, and mint. Dress with olive oil, lemon juice, red wine vinegar, garlic, oregano, salt, and pepper.',
      'category': 'Salad',
      'videoUrl': 'https://youtu.be/92WHv-rgrZQ?si=wR01wu98O8XQ96iF',
      'calories': '1 serving (approximately 2 cups) 350',

    },
    {
      'name': 'Sushi',
      'image': 'assets/images/sushi.jpg',
      'ingredients': 'Rice, Nori, Fish, Avocado, Cucumber',
      'recipe': 'Roll cooked rice, fish, avocado, and cucumber in nori sheets. Serve with soy sauce, wasabi, and pickled ginger.',
      'category': 'Meal',
      'videoUrl': 'https://youtu.be/OWVjync6peU?si=sRZJUMmD_24SQL0N',
      'calories': '1 serving (approximately 1 cup) 250',
    },
    {
      'name': 'Chow Mein',
      'image': 'assets/images/chow mein.jpg',
      'ingredients': 'Noodles, Chicken, Cabbage, Carrot, Soy Sauce, Garlic, Ginger',
      'recipe': 'Stir-fry chicken with garlic and ginger. Add vegetables and cooked noodles. Toss with soy sauce.',
      'category': 'Meal',
      'videoUrl': 'https://youtu.be/4wC-_4xqnlk?si=279xMRZHVjWa51tP',
      'calories': 'Approximately 300-350 kcal per serving',
    },
    {
      'name': 'Noodles',
      'image': 'assets/images/noodles.jpg',
      'ingredients': 'Noodles, Vegetables, Soy Sauce, Garlic, Ginger, Sesame Oil',
      'recipe': 'Stir-fry vegetables with garlic and ginger. Add cooked noodles and toss with soy sauce and sesame oil.',
      'category': 'Meal',
      'videoUrl': 'https://youtu.be/EquybCEvZLM?si=DmjVGdX1FH9X46-D',
      'calories': '193 per serving',

    },
    {
      'name': 'Macaroni',
      'image': 'assets/images/macronie.jpg',
      'ingredients': 'Macaroni, Cheese, Milk, Butter',
      'recipe': 'Cook macaroni. Make cheese sauce with cheese, milk, and butter. Mix macaroni with cheese sauce.',
      'category': 'Meal',
      'videoUrl': 'https://youtu.be/CRFTkpfs1Wc?si=RZIRf4cVQX4NdJv9',
      'calories': '1 serving 350',
    },
    {
      'name': 'Chicken Biryani',
      'image': 'assets/images/biryani.jpg',
      'ingredients': 'Chicken, Basmati Rice, Yogurt, Spices, Onions, Tomatoes',
      'recipe': 'Cook chicken with spices, onions, and tomatoes. Layer with cooked rice and bake.',
      'category': 'Meal',
      'videoUrl': 'https://youtu.be/40VJanswaAQ?si=-dPNouRpF7uJS33d',
      'calories': '1 serving 250',
    },
    {
      'name': 'Qorma',
      'image': 'assets/images/qorma.jpg',
      'ingredients': 'Meat, Yogurt, Cumin, Coriander, Turmeric, Garam Masala, Red Chili Powder, Cinnamon, Cardamom, Cloves, Bay Leaves, Onions, Tomatoes',
      'recipe': 'Cook meat with yogurt, spices (cumin, coriander, turmeric, garam masala, red chili powder, cinnamon, cardamom, cloves, bay leaves), onions, and tomatoes until tender.',
      'category': 'Meal',
      'videoUrl': 'https://youtu.be/9jOH3TEB-NI?si=V0idh2QobLCXWwbQ',
      'calories': '1 serving 270',

    },
    {
      'name': 'Zarda',
      'image': 'assets/images/zarda.jpg',
      'ingredients': 'Basmati Rice, Sugar, Food Coloring, Nuts, Raisins, Cardamom',
      'recipe': 'Cook rice with sugar, food coloring, nuts, raisins, and cardamom.',
      'category': 'Meal',
      'videoUrl': 'https://youtu.be/gUrWTVTtPH8?si=w567ZU3Vx3x3xi0Z',
      'calories': '200 per serving',
    },
    {
      'name': 'Chicken Curry',
      'image': 'assets/images/curry.jpg',
      'ingredients': 'Chicken, Onions, Tomatoes, Garlic, Ginger, Spices, Yogurt',
      'recipe': 'Cook onions until golden. Add garlic, ginger, and spices. Add chicken and cook until browned. Add tomatoes and yogurt. Simmer until chicken is cooked through.',
      'category': 'Meal', 'videoUrl': 'https://youtu.be/WRYOVVexMhU?si=DGavK7F8ghlLuAva',
      'calories': '300 per serving',
    },
    {
      'name': 'Green Smoothie',
      'ingredients': 'Spinach, Banana, Pineapple, Almond Milk',
      'image': 'assets/images/green smothie.jpg',
      'recipe': 'Blend spinach, banana, pineapple, and almond milk until smooth.',
      'category': 'Blends',
      'videoUrl': 'https://youtu.be/YGmQR8yCT_0?si=aExLKbL2T80A9RYm',
      'calories': '1 serving 150',
    },
    {
      'name': 'Mango Lassi',
      'ingredients': 'Mango, Yogurt, Honey, Cardamom',
      'image': 'assets/images/mango lassi.jpg',
      'recipe': 'Blend mango, yogurt, honey, and a pinch of cardamom until creamy.',
      'category': 'Blends',
      'videoUrl': 'https://youtu.be/xqir4h6rYJw?si=KT-U29EAFD8uXRd0',
      'calories': '1 serving 100',
    },
    {
      'name': 'Tropical Fruit Smoothie',
      'ingredients': 'Pineapple, Mango, Papaya, Coconut Water',
      'image': 'assets/images/tropical.jpg',
      'recipe': 'Blend pineapple, mango, papaya, and coconut water until smooth.',
      'category': 'Blends',
      'videoUrl': 'https://youtu.be/-CDrJx-8l94?si=iBgVi99P3-DpKSUA',
      'calories': '1 serving 150',
    },
    {
      'name': 'Berry Blast Smoothie',
      'ingredients': 'Mixed Berries, Greek Yogurt, Orange Juice, Honey',
      'image': 'assets/images/berry blast.jpg',
      'recipe': 'Blend mixed berries, Greek yogurt, orange juice, and honey until well combined.',
      'category': 'Blends',
      'videoUrl': 'https://youtu.be/SHaWNkVn8-8?si=_SNAZ6ZUsLoVOwKY',
      'calories': '200 per serving',
    },
    {
      'name': 'Banana Berry Smoothie',
      'ingredients': 'Banana, Mixed Berries, Spinach, Almond Milk',
      'image': 'assets/images/banan berry.jpg',
      'recipe': 'Blend banana, mixed berries, spinach, and almond milk until creamy.',
      'category': 'Blends',
      'videoUrl': 'https://youtu.be/Ns0TVWVvkyU?si=Sy-OUsqzgB9sGCkU',
      'calories': '200 per serving',
    },
    {
      'name': 'Pineapple Coconut Smoothie',
      'ingredients': 'Pineapple, Coconut Milk, Banana, Honey',
      'image': 'assets/images/pineapple.jpg',
      'recipe': 'Blend pineapple, coconut milk, banana, and honey until smooth.',
      'category': 'Blends',
      'videoUrl': 'https://youtu.be/cQC8IOVn6Pg?si=DdKy3O5e7j2TMYeb',
      'calories': '1 serving 200',
    },
    {
      'name': 'Chocolate Peanut Butter Smoothie',
      'ingredients': 'Banana, Peanut Butter, Cocoa Powder, Almond Milk, Honey',
      'image': 'assets/images/chocolate.jpg',
      'recipe': 'Blend banana, peanut butter, cocoa powder, almond milk, and honey until creamy.',
      'category': 'Blends',
      'videoUrl': 'https://youtu.be/QrIpXPNadvI?si=vgLpGIyJutLIhGW-',
      'calories': '1 serving 250',
    },
    {
      'name': 'Apple Pie Smoothie',
      'ingredients': 'Apple, Rolled Oats, Yogurt, Cinnamon, Honey, Almond Milk',
      'image': 'assets/images/apple pie.jpg',
      'recipe': 'Blend apple, rolled oats, yogurt, cinnamon, honey, and almond milk until smooth.',
      'category': 'Blends',
       'videoUrl': 'https://youtu.be/6dtnxgZCK5M?si=Gw3J5Gk8pyJJBrHn',
      'calories': '1 serving 150',
    },
    {
      'name': 'Detox Green Smoothie',
      'ingredients': 'Kale, Cucumber, Green Apple, Lemon, Ginger, Coconut Water',
      'image': 'assets/images/detox.jpg',
      'recipe': 'Blend kale, cucumber, green apple, lemon, ginger, and coconut water until smooth.',
      'category': 'Blends',
      'videoUrl': 'https://youtu.be/SEBXR5jcYps?si=Xugfnaozn1TROPQE',
      'calories': '350 per serving',
    },

    {
      'name': 'Greek Yogurt Parfait',
      'ingredients': 'Greek Yogurt, Granola, Mixed Berries, Honey',
      'image': 'assets/images/Parfait.jpg',
      'recipe': 'Layer Greek yogurt, granola, and mixed berries in a glass. Drizzle with honey.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/5zm9OyyCz7I?si=UVs4UVjiR_LGqn_C',
      'calories': '1 serving 100',
    },
    {
      'name': 'Trail Mix',
      'ingredients': 'Mixed Nuts, Dried Fruits, Dark Chocolate Chips, Coconut Flakes',
      'image': 'assets/images/trail.jpg',
      'recipe': 'Mix mixed nuts, dried fruits, dark chocolate chips, and coconut flakes in a bowl. Serve in portioned bags.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/rGYg8wciFOA?si=rwxl4F3QntVIcES1',
      'calories': '1 serving 260',
    },

    {
      'name': 'Veggie Chips',
      'ingredients': 'Sweet Potatoes, Beets, Parsnips, Olive Oil, Salt',
      'image': 'assets/images/vedggie.jpeg',
      'recipe': 'Slice sweet potatoes, beets, and parsnips thinly. Toss with olive oil and salt. Bake until crispy.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/zJE-xClYq1I?si=WVFMZCX7LEAgYAoC',
      'calories': '1 serving 350',

    },
    // Additional snack recipes
    {
      'name': 'Fruit Kabobs',
      'ingredients': 'Strawberries, Pineapple Chunks, Grapes, Melon Balls, Wooden Skewers',
      'image': 'assets/images/fruit.jpg',
      'recipe': 'Thread strawberries, pineapple chunks, grapes, and melon balls onto wooden skewers. Serve chilled.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/SwC2q8qo6GQ?si=x0rKh4o-6o6QQC20',
      'calories': '1 serving 250',

    },
    {
      'name': 'Cheese and Crackers',
      'ingredients': 'Assorted Cheese, Crackers, Grapes',
      'image': 'assets/images/chiess.jpg',
      'recipe': 'Arrange assorted cheese and crackers on a platter. Serve with grapes on the side.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/maF1MX0-kKQ?si=vxaRUDf5rSnfuk7X',
      'calories': '1 serving 250',

    },
    {
      'name': 'Popcorn',
      'ingredients': 'Popcorn Kernels, Olive Oil, Salt',
      'image': 'assets/images/popcorn.jpg',
      'recipe': 'Pop popcorn kernels in olive oil. Season with salt to taste.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/5FTbhoYunxI?si=kRRLPp1BehfNVVrn',
      'calories': '1 serving 200',
    },
    {
      'name': 'Energy Balls',
      'ingredients': 'Dates, Almonds, Rolled Oats, Cocoa Powder, Honey',
      'image': 'assets/images/energy.jpg',
      'recipe': 'Blend dates, almonds, rolled oats, cocoa powder, and honey in a food processor. Roll into balls and refrigerate.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/1noPmYc_DxI?si=3HPOWeW0uK-EtuSk',
      'calories': '1 ball 100',

    },
    {
      'name': 'Chocolate Chip Cookies',
      'ingredients': 'Flour, Butter, Sugar, Brown Sugar, Eggs, Vanilla Extract, Baking Soda, Salt, Chocolate Chips',
      'image': 'assets/images/chocolatechip.jpg',
      'recipe': 'Cream together butter, sugar, and brown sugar. Add eggs and vanilla extract. Mix in flour, baking soda, and salt. Fold in chocolate chips. Bake at 350°F for 10-12 minutes.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/YEZPxhMneOc?si=iGA3mI6wG2CDbXdf',
      'calories': '1 cookie 80',
    },
    {
      'name': 'Classic Brownies',
      'ingredients': 'Butter, Sugar, Eggs, Vanilla Extract, Flour, Cocoa Powder, Salt, Chocolate Chips',
      'image': 'assets/images/brownie.jpg',
      'recipe': 'Melt butter and mix with sugar, eggs, and vanilla extract. Stir in flour, cocoa powder, and salt. Fold in chocolate chips. Bake at 350°F for 20-25 minutes.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/PM8mETfXNeU?si=AH93qXUHRv9RFGTs',
      'calories': '1 slice 150',
    },

    {
      'name': 'Apple Pie',
      'ingredients': 'Apples, Sugar, Flour, Cinnamon, Nutmeg, Butter, Pie Crust',
      'image': 'assets/images/apple piee.jpg',
      'recipe': 'Peel and slice apples. Mix with sugar, flour, cinnamon, and nutmeg. Line a pie dish with pie crust. Fill with apple mixture. Dot with butter. Cover with another pie crust. Bake at 375°F for 45-50 minutes.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/KbyahTnzbKA?si=bvzCgvbWFiybVJ0L',
      'calories': '1 serving 250',


    },
    {
      'name': 'Banana Bread',
      'ingredients': 'Bananas, Flour, Sugar, Butter, Eggs, Baking Soda, Salt, Vanilla Extract',
      'image': 'assets/images/bread.jpg',
      'recipe': 'Mash bananas and mix with melted butter, sugar, eggs, and vanilla extract. Stir in flour, baking soda, and salt. Bake in a loaf pan at 350°F for 60-65 minutes.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/2eTFhB5SNuY?si=mKDlZk7DK7DRKBgn',
      'calories': '1 serving 200',
    },
    {
      'name': 'Strawberry Shortcake',
      'ingredients': 'Strawberries, Sugar, Flour, Baking Powder, Salt, Butter, Milk, Whipped Cream',
      'image': 'assets/images/shortcake.jpg',
      'recipe': 'Mix sliced strawberries with sugar and let sit. Mix flour, baking powder, and salt. Cut in butter. Stir in milk. Drop spoonfuls onto a baking sheet. Bake at 425°F for 12-15 minutes. Serve with strawberries and whipped cream.',
      'category': 'Snacks',
      'videoUrl': 'https://youtu.be/dRdinLuopTo?si=0p4KR1Oh6kyTAK5i',
      'calories': '1 serving 200',

    },
    // Additional sweet recipes
    {
      'name': 'Vanilla Cupcakes',
      'ingredients': 'Flour, Sugar, Butter, Eggs, Vanilla Extract, Baking Powder, Salt, Milk, Frosting',
      'image': 'assets/images/vanilla.jpg',
      'recipe': 'Cream together butter and sugar. Beat in eggs and vanilla extract. Mix in flour, baking powder, and salt. Gradually add milk. Pour batter into cupcake liners. Bake at 350°F for 18-20 minutes. Frost once cooled.',
      'category': 'Snacks', 'videoUrl': 'https://youtu.be/uU7eOlSL6Hk?si=bJ8BTXeMQcbylTpY','calories': '1 slice 150',},
    {
      'name': 'Chocolate Cake',
      'ingredients': 'Flour, Sugar, Cocoa Powder, Baking Powder, Baking Soda, Salt, Eggs, Milk, Vegetable Oil, Vanilla Extract, Hot Water, Frosting',
      'image': 'assets/images/cake.jpg',
      'recipe': 'Mix dry ingredients. Add eggs, milk, oil, and vanilla extract. Beat until smooth. Stir in hot water. Pour into greased pans. Bake at 350°F for 30-35 minutes. Frost once cooled.',
      'category': 'Snacks', 'videoUrl': 'https://youtu.be/RfhNAs597nM?si=3T0uKwx9yfSbLCUz','calories': '1 slice 200',},

    {
      'name': 'Chocolate Truffles',
      'ingredients': 'Chocolate Chips, Heavy Cream, Butter, Cocoa Powder, Nuts or Sprinkles (optional)',
      'image': 'assets/images/trffles.jpg',
      'recipe': 'Heat cream and pour over chocolate chips and butter. Stir until smooth. Chill until firm. Roll into balls and coat in cocoa powder or chopped nuts. Chill until set.',
      'category': 'Snacks', 'videoUrl': 'https://youtu.be/ckmDgIYsb8Q?si=VUaj7gKhvHXLuBGC','calories': '1 serving 50',},


  ];

  List<Map<String, String>> filteredRecipes = [];
  List<String> containerTitles = ['All', 'Salad', 'Meal', 'Blends', 'Snacks'];



  @override
  void initState() {
    super.initState();
    filteredRecipes = allRecipes;
  }

  void selectContainer(int index) {
    setState(() {
      selectedIndex = index;
      // Reset search
      searchController.clear();
      if (index == 0) {
        filteredRecipes = allRecipes;
      } else {
        filteredRecipes = filterRecipesByCategory(containerTitles[index]);
      }
    });
  }

  List<Map<String, String>> filterRecipesByCategory(String category) {
    return allRecipes.where((recipe) => recipe['category'] == category)
        .toList();
  }

  void searchRecipes(String query) {
    setState(() {
      if (query.isEmpty) {
        // If the search query is empty, reset the filtered recipes based on the selected category
        if (selectedIndex == 0) {
          filteredRecipes = allRecipes; // Show all recipes in "All" category
        } else {
          filteredRecipes = filterRecipesByCategory(
              containerTitles[selectedIndex]); // Show recipes in the selected category
        }
      } else {
        // If the search query is not empty, filter recipes based on name and category
        if (selectedIndex == 0) {
          // If in "All" category, filter all recipes by name and category
          filteredRecipes = allRecipes.where((recipe) =>
          recipe['name']!.toLowerCase().contains(query.toLowerCase()) ||
              recipe['category']!.toLowerCase().contains(query.toLowerCase())
          ).toList();
        } else {
          // If in a specific category, filter recipes in that category by name only
          filteredRecipes =
              filterRecipesByCategory(containerTitles[selectedIndex]).where((
                  recipe) =>
                  recipe['name']!.toLowerCase().contains(query.toLowerCase())
              ).toList();
        }
      }
    });
  }


  void showRecipeDialog(BuildContext context, Map<String, String> recipe) {
    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView( // Wrap with SingleChildScrollView
          clipBehavior: Clip.none, // Set clipBehavior to Clip.none
          child: AlertDialog(
            contentPadding: EdgeInsets.zero,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(8.0),
                  color: Colors.purple,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recipe Details', style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(recipe['image'] ?? ''),
                      SizedBox(height: 10),
                      Text('Ingredients:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(recipe['ingredients'] ?? ''),
                      SizedBox(height: 10),
                      Text('Recipe:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(recipe['recipe'] ?? ''),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () async {
                          showUserForm(context, recipe);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.purple[300],
                          // Text color of the button
                          foregroundColor: Colors.white,
                        ),
                        child: Text('See Video'),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.bottomCenter,
                  padding: EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
                  child: Text(
                    'Calories: ${recipe['calories']} kcal',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                      fontSize: 11.0,

                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    double containerWidth = (MediaQuery
        .of(context)
        .size
        .width - 90) / 5;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        title: Text(
          'Food Recipe',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(containerTitles.length, (index) {
                      return GestureDetector(
                        onTap: () => selectContainer(index),
                        child: Container(
                          width: containerWidth,
                          height: 50.0,
                          margin: EdgeInsets.only(right: 10.0),
                          decoration: BoxDecoration(
                            color: selectedIndex == index
                                ? Colors.purple
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              containerTitles[index],
                              style: TextStyle(
                                color: selectedIndex == index
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14, // Adjust font size for better fitting
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(height: 20.0),
                TextField(
                  controller: searchController,
                  onChanged: searchRecipes,
                  decoration: InputDecoration(
                    hintText: 'Search Recipes',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.0),
              children: filteredRecipes.isNotEmpty
                  ? filteredRecipes.map((recipe) {
                return Container(
                  margin: EdgeInsets.only(bottom: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          recipe['image'] ?? '',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipe['name'] ?? '',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0,
                                ),
                              ),
                              SizedBox(height: 5),
                              ElevatedButton(
                                onPressed: () =>
                                    showRecipeDialog(context, recipe),
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                child: Text('See Recipe'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList()
                  : [Center(child: Text('No recipes found'))],
            ),
          ),
        ],
      ),
    );
  }

  void showUserForm(BuildContext context, Map<String, String> recipe) {
    final _formKey = GlobalKey<FormState>();
    AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 40.0),
                child: Form(
                  key: _formKey,
                  autovalidateMode: _autoValidateMode,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.cancel_outlined),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(
                            fontSize: 18.0, // Set the font size for the label text
                          ),
                          hintText: 'example@gmail.com',
                          hintStyle: TextStyle(
                            fontSize: 16.0, // Set the font size for the hint text
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 16.0, // Set the font size for the input text
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$')
                              .hasMatch(value)) {
                            return 'Please enter a valid Gmail address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          // Set autovalidate mode to always when submitting the form
                          setState(() {
                            _autoValidateMode = AutovalidateMode.always;
                          });

                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop();
                            showInternetConnectionDialog(context, recipe);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.purple[500],
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Submit'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
//paid user dalog
  void showInternetConnectionDialog(BuildContext context,   Map<String, String> recipe) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            'Make sure you have an internet connection',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                insert_payusers();
                getFrompayusers();
                launchVideo(recipe['videoUrl']!);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void launchVideo(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Could not launch the video.'),
      ));
    }
  }



  Future<Database?> openDB() async {
    _database = await DatabaseHandler().openDB();

    return _database;
  }

  Future<void> insert_payusers() async {
    _database = await openDB();
    UserRepo userRepo = new UserRepo();
    userRepo.createpayTable(_database);

    payUserModel userModel = new payUserModel(
      emailController.text.toString(),
    );
    await _database?.insert('PAIDUSER', userModel.toMap());

    await _database?.close();
  }

  Future<void> getFrompayusers() async {
    _database = await openDB();
    UserRepo userRepo = new UserRepo();
    await userRepo.getpayusers(_database);

    await _database?.close();
  }


}