//
//  EducationCenterView.swift
//  CKD Care
//
//  Created by Sandun Sahiru on 2025-03-06.
//

import SwiftUI

// MARK: - Education Center View
struct EducationCenterView: View {
    // MARK: - Properties
    @State private var searchText = ""
    @State private var selectedCategory: ArticleCategory = .all
    @State private var showingArticleDetail = false
    @State private var selectedArticle: EducationArticle?
    @State private var articles: [EducationArticle] = []
    @State private var bookmarkedArticles: Set<UUID> = []
    @State private var showingBookmarksOnly = false
    
    // MARK: - Body
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header section
                headerSection
                
                // Search bar
                searchBar
                
                // Category selector
                categorySelector
                
                // Featured article
                if let featured = featuredArticle {
                    featuredArticleCard(featured)
                        .padding(.bottom, 10)
                }
                
                // Article list
                articlesSection
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .navigationTitle("Learn")
        .background(Color(UIColor.systemBackground))
        .sheet(isPresented: $showingArticleDetail) {
            if let article = selectedArticle {
                ArticleDetailView(article: article, isBookmarked: bookmarkedArticles.contains(article.id)) { id in
                    toggleBookmark(id)
                }
            }
        }
        .onAppear {
            loadSampleArticles()
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Education Center")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Learn about CKD and kidney health")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Bookmarks button
            Button(action: {
                withAnimation {
                    showingBookmarksOnly.toggle()
                }
            }) {
                Image(systemName: showingBookmarksOnly ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 22))
                    .foregroundColor(showingBookmarksOnly ? .blue : .primary)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.top, 20)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search articles...", text: $searchText)
                .font(.subheadline)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(10)
    }
    
    // MARK: - Category Selector
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(ArticleCategory.allCases, id: \.self) { category in
                    categoryButton(category)
                }
            }
            .padding(.vertical, 5)
        }
    }
    
    private func categoryButton(_ category: ArticleCategory) -> some View {
        Button(action: {
            withAnimation {
                selectedCategory = category
            }
        }) {
            Text(category.name)
                .font(.subheadline)
                .fontWeight(selectedCategory == category ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    selectedCategory == category
                    ? Color.blue.opacity(0.2)
                    : Color(UIColor.secondarySystemBackground)
                )
                .foregroundColor(selectedCategory == category ? .blue : .primary)
                .cornerRadius(20)
        }
    }
    
    // MARK: - Featured Article Card
    private func featuredArticleCard(_ article: EducationArticle) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Featured Article")
                .font(.headline)
                .fontWeight(.bold)
            
            Button(action: {
                selectedArticle = article
                showingArticleDetail = true
            }) {
                VStack(alignment: .leading, spacing: 12) {
                    // Article image
                    ZStack(alignment: .topTrailing) {
                        Image(article.imageURL)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(10)
                        
                        Button(action: {
                            toggleBookmark(article.id)
                        }) {
                            Image(systemName: bookmarkedArticles.contains(article.id) ? "bookmark.fill" : "bookmark")
                                .foregroundColor(.white)
                                .padding(8)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                                .padding(10)
                        }
                    }
                    
                    // Category badge
                    Text(article.category)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(5)
                    
                    // Article title and summary
                    Text(article.title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(article.summary)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(3)
                    
                    // Article meta info
                    HStack {
                        // Read time
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(article.readTime) min read")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Text("Read more")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 10)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(20)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Articles Section
    private var articlesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text(sectionTitle)
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if filteredArticles.count > 0 {
                    Text("\(filteredArticles.count) articles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if filteredArticles.isEmpty {
                emptyStateView
            } else {
                ForEach(filteredArticles) { article in
                    articleRow(article)
                }
            }
        }
    }
    
    private var sectionTitle: String {
        if !searchText.isEmpty {
            return "Search Results"
        } else if showingBookmarksOnly {
            return "Bookmarked Articles"
        } else if selectedCategory != .all {
            return selectedCategory.name
        } else {
            return "All Articles"
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: emptyStateIcon)
                .font(.system(size: 50))
                .foregroundColor(.secondary.opacity(0.5))
                .padding(.vertical, 20)
            
            Text(emptyStateMessage)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if showingBookmarksOnly {
                Button(action: {
                    showingBookmarksOnly = false
                }) {
                    Text("Browse All Articles")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 10)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var emptyStateIcon: String {
        if !searchText.isEmpty {
            return "magnifyingglass"
        } else if showingBookmarksOnly {
            return "bookmark.slash"
        } else {
            return "doc.text"
        }
    }
    
    private var emptyStateMessage: String {
        if !searchText.isEmpty {
            return "No articles found for '\(searchText)'\nTry a different search term"
        } else if showingBookmarksOnly {
            return "You haven't bookmarked any articles yet"
        } else {
            return "No articles in this category"
        }
    }
    
    private func articleRow(_ article: EducationArticle) -> some View {
        Button(action: {
            selectedArticle = article
            showingArticleDetail = true
        }) {
            HStack(alignment: .top, spacing: 16) {
                // Article thumbnail
                Image(article.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Article details
                VStack(alignment: .leading, spacing: 4) {
                    // Category and bookmark
                    HStack {
                        Text(article.category)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Button(action: {
                            toggleBookmark(article.id)
                        }) {
                            Image(systemName: bookmarkedArticles.contains(article.id) ? "bookmark.fill" : "bookmark")
                                .foregroundColor(bookmarkedArticles.contains(article.id) ? .blue : .gray)
                                .font(.caption)
                        }
                    }
                    
                    // Title
                    Text(article.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    // Summary
                    Text(article.summary)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    // Read time
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("\(article.readTime) min read")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Computed Properties
    private var featuredArticle: EducationArticle? {
        // Return a featured article that isn't filtered by current selection
        articles.first(where: { $0.isFeatured })
    }
    
    private var filteredArticles: [EducationArticle] {
        var result = articles
        
        // Filter by bookmark status if needed
        if showingBookmarksOnly {
            result = result.filter { bookmarkedArticles.contains($0.id) }
        }
        
        // Filter by category
        if selectedCategory != .all {
            result = result.filter { $0.categoryType == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.lowercased().contains(searchText.lowercased()) ||
                $0.summary.lowercased().contains(searchText.lowercased()) ||
                $0.category.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Remove featured article from regular list to avoid duplication
        if let featured = featuredArticle {
            result = result.filter { $0.id != featured.id }
        }
        
        return result
    }
    
    // MARK: - Helper Methods
    
    private func toggleBookmark(_ id: UUID) {
        if bookmarkedArticles.contains(id) {
            bookmarkedArticles.remove(id)
        } else {
            bookmarkedArticles.insert(id)
        }
    }
    
    // MARK: - Sample Data
    
    private func loadSampleArticles() {
        articles = [
            EducationArticle(
                title: "Understanding Kidney Function & CKD Early Signs",
                summary: "Learn how your kidneys work and how to identify early warning signs of kidney disease.",
                imageURL: "article-kidney-function",
                category: "Education",
                readTime: 5,
                content: sampleArticleContent1,
                categoryType: .basics,
                isFeatured: true
            ),
            EducationArticle(
                title: "The Importance of eGFR and What Your Numbers Mean",
                summary: "Your eGFR is a key indicator of kidney health. Find out what your test results mean.",
                imageURL: "article-egfr",
                category: "Testing",
                readTime: 4,
                content: sampleArticleContent2,
                categoryType: .testing
            ),
            EducationArticle(
                title: "CKD-Friendly Diet: Foods to Enjoy and Avoid",
                summary: "Proper nutrition plays a crucial role in managing CKD. Learn what foods are recommended for kidney health.",
                imageURL: "article-ckd-diet",
                category: "Nutrition",
                readTime: 7,
                content: sampleArticleContent3,
                categoryType: .nutrition
            ),
            EducationArticle(
                title: "Managing Blood Pressure for Kidney Health",
                summary: "High blood pressure is both a cause and complication of kidney disease. Learn effective management strategies.",
                imageURL: "article-blood-pressure",
                category: "Management",
                readTime: 5,
                content: sampleArticleContent4,
                categoryType: .management
            ),
            EducationArticle(
                title: "Understanding the Five Stages of CKD",
                summary: "Chronic kidney disease progresses through five stages. Learn what to expect at each stage.",
                imageURL: "article-ckd-stages",
                category: "Education",
                readTime: 6,
                content: sampleArticleContent5,
                categoryType: .basics
            ),
            EducationArticle(
                title: "Medications to Avoid with Kidney Disease",
                summary: "Some common medications can harm your kidneys. Know which ones to avoid or use with caution.",
                imageURL: "article-medications",
                category: "Medication",
                readTime: 4,
                content: sampleArticleContent6,
                categoryType: .medication
            ),
            EducationArticle(
                title: "The Connection Between Diabetes and CKD",
                summary: "Diabetes is the leading cause of kidney disease. Learn how to manage both conditions effectively.",
                imageURL: "article-diabetes-ckd",
                category: "Comorbidities",
                readTime: 5,
                content: sampleArticleContent7,
                categoryType: .comorbidities
            ),
            EducationArticle(
                title: "Staying Active with CKD: Exercise Guidelines",
                summary: "Physical activity is beneficial for kidney patients. Find out the best types of exercise for CKD.",
                imageURL: "article-exercise",
                category: "Lifestyle",
                readTime: 4,
                content: sampleArticleContent8,
                categoryType: .lifestyle
            ),
            EducationArticle(
                title: "Understanding Creatinine and BUN Test Results",
                summary: "These common blood tests measure kidney function. Learn how to interpret your results.",
                imageURL: "article-creatinine",
                category: "Testing",
                readTime: 3,
                content: sampleArticleContent9,
                categoryType: .testing
            ),
            EducationArticle(
                title: "Salt and CKD: Finding the Right Balance",
                summary: "Sodium management is crucial for kidney patients. Learn practical tips to reduce salt intake.",
                imageURL: "article-salt",
                category: "Nutrition",
                readTime: 5,
                content: sampleArticleContent10,
                categoryType: .nutrition
            )
        ]
    }
    
    // Sample article content
    private let sampleArticleContent1 = """
    # Understanding Kidney Function & CKD Early Signs
    
    Your kidneys are remarkable organs that perform several vital functions to keep your body healthy. Each about the size of your fist, these bean-shaped organs work around the clock to filter waste from your blood, regulate electrolyte levels, control blood pressure, stimulate red blood cell production, and activate vitamin D for healthy bones.
    
    ## How Healthy Kidneys Function
    
    In healthy kidneys, about 200 quarts of blood are filtered through millions of tiny structures called nephrons every 24 hours. These nephrons contain tiny blood vessels (glomeruli) that filter waste and excess water, which eventually becomes urine. The filtered blood returns to your body to deliver essential nutrients and oxygen to tissues and organs.
    
    The kidneys maintain a delicate balance of chemicals in your blood, including:
    - Sodium and potassium for nerve and muscle function
    - Calcium and phosphorus for bone health
    - Bicarbonate for controlling acidity
    
    They also produce important hormones that regulate blood pressure, stimulate bone marrow to make red blood cells, and help metabolize vitamin D for calcium absorption.
    
    ## Early Signs of Chronic Kidney Disease
    
    CKD often develops slowly over time, and symptoms may not appear until significant kidney function is lost. This is why it's often called a "silent disease." However, being aware of early warning signs can lead to earlier detection and treatment.
    
    Common early signs include:
    
    ### 1. Changes in Urination
    - More frequent urination, especially at night
    - Decreased urine output
    - Foamy or bubbly urine (indicating protein)
    - Blood in urine
    - Difficulty urinating
    
    ### 2. Swelling
    - Puffiness around the eyes, especially in the morning
    - Swollen feet, ankles, hands, or face
    - Unexplained weight gain from fluid retention
    
    ### 3. Fatigue and Weakness
    - Decreased energy levels
    - Requiring more rest than usual
    - Difficulty concentrating
    
    ### 4. Shortness of Breath
    - Trouble catching your breath
    - Feeling winded after minimal activity
    
    ### 5. Other Potential Indicators
    - Metallic taste in the mouth
    - Ammonia breath
    - Poor appetite
    - Nausea and vomiting
    - Itchy skin
    - Muscle cramps
    
    ## Risk Factors for CKD
    
    Certain factors increase your risk of developing kidney disease:
    
    - Diabetes (both Type 1 and Type 2)
    - High blood pressure
    - Heart disease
    - Family history of kidney disease
    - Obesity
    - Age over 60
    - Being of African, Hispanic, Native American, or Asian descent
    - History of acute kidney injury
    - Chronic use of certain medications (NSAIDs like ibuprofen)
    
    ## When to See a Doctor
    
    If you notice any of the above symptoms or have risk factors for kidney disease, it's important to consult with your healthcare provider. Early detection through simple blood and urine tests can help slow or prevent progression to more serious kidney damage.
    
    Remember, many kidney diseases can be treated effectively when caught early. Regular checkups, especially if you have diabetes or high blood pressure, are crucial for monitoring kidney health.
    """
    
    private let sampleArticleContent2 = """
    # The Importance of eGFR and What Your Numbers Mean
    
    Estimated Glomerular Filtration Rate (eGFR) is one of the most important measures of kidney function. This simple blood test helps doctors determine how well your kidneys are filtering waste from your blood, and it's essential for diagnosing and staging chronic kidney disease (CKD).
    
    ## What is eGFR?
    
    Your eGFR is a calculation that estimates how much blood passes through the glomeruli (tiny filters in your kidneys) each minute. It's measured in milliliters per minute per 1.73 m² (mL/min/1.73 m²), which represents the standard body surface area.
    
    The test works by measuring creatinine levels in your blood. Creatinine is a waste product from muscle metabolism that healthy kidneys filter out efficiently. When kidneys aren't functioning properly, creatinine builds up in the bloodstream.
    
    ## Understanding Your eGFR Results
    
    eGFR values typically range as follows:
    
    - **90 or higher**: Normal kidney function (though other signs of kidney damage may be present)
    - **60-89**: Mildly reduced kidney function
    - **45-59**: Mild to moderately reduced kidney function
    - **30-44**: Moderately to severely reduced kidney function
    - **15-29**: Severely reduced kidney function
    - **Less than 15**: Kidney failure (dialysis or transplant may be needed)
    
    According to clinical guidelines, CKD is defined as having an eGFR below 60 mL/min/1.73 m² for three months or more, or having evidence of kidney damage (such as protein in the urine) even with a normal eGFR.
    
    ## Factors That Can Affect Your eGFR Reading
    
    It's important to understand that several factors can influence your eGFR result:
    
    - **Age**: eGFR naturally declines as you age, by about 1 mL/min per year after age 40
    - **Gender**: The standard eGFR calculation adjusts for gender differences
    - **Race**: Some equations have traditionally adjusted for race, though newer approaches are moving away from this
    - **Body size**: Very muscular or very thin people may have results that don't accurately reflect their kidney function
    - **Pregnancy**: Can temporarily affect eGFR results
    - **Acute illness**: Can cause temporary changes in kidney function
    - **Diet**: High protein intake before the test can affect results
    - **Medications**: Some drugs can temporarily affect creatinine levels
    
    ## Monitoring Your eGFR Over Time
    
    A single eGFR measurement provides valuable information, but tracking changes over time is even more informative. Your healthcare provider will typically:
    
    - Establish your baseline eGFR
    - Monitor trends to see if kidney function is stable, improving, or declining
    - Adjust the frequency of testing based on your CKD stage and rate of progression
    
    ## What to Do If Your eGFR Is Low
    
    If your eGFR indicates reduced kidney function, your healthcare provider may recommend:
    
    1. **Additional testing** to confirm the diagnosis and identify the cause
    2. **Blood pressure management**, as hypertension can both cause and result from kidney disease
    3. **Blood sugar control** if you have diabetes
    4. **Medication adjustments** to protect kidney function and treat complications
    5. **Dietary modifications** to reduce the workload on your kidneys
    6. **Regular monitoring** to track kidney function over time
    
    ## The Importance of Regular Testing
    
    Since CKD often progresses without symptoms in the early stages, regular eGFR testing is crucial, especially if you have risk factors such as:
    
    - Diabetes
    - High blood pressure
    - Heart disease
    - Family history of kidney disease
    - Advanced age
    
    Most experts recommend annual kidney function testing for people with these risk factors. Early detection through regular eGFR monitoring allows for interventions that can slow progression and prevent complications.
    
    Remember, knowing your eGFR number empowers you to take an active role in managing your kidney health and overall wellbeing.
    """
    
    private let sampleArticleContent3 = """
    # CKD-Friendly Diet: Foods to Enjoy and Avoid
    
    Nutrition plays a crucial role in managing chronic kidney disease (CKD). The right dietary choices can help slow disease progression, prevent complications, and improve quality of life. This guide provides practical advice on foods to enjoy and those to limit or avoid based on your individual needs.
    
    ## Understanding the CKD Diet
    
    A kidney-friendly diet typically focuses on controlling intake of several nutrients:
    
    - **Sodium**: Affects fluid balance and blood pressure
    - **Potassium**: Crucial for heart and muscle function
    - **Phosphorus**: Important for bone health
    - **Protein**: Necessary but creates waste products kidneys must filter
    - **Fluids**: May need careful management in advanced CKD
    
    Your specific dietary needs will depend on your CKD stage, lab results, medications, and overall health. Always work with your healthcare team to develop a personalized eating plan.
    
    ## Foods to Enjoy
    
    ### Low-Sodium Options
    - Fresh or frozen vegetables (without added salt)
    - Fresh fruits
    - Fresh meat, poultry, and fish (not pre-seasoned)
    - Eggs
    - Low-sodium dairy
    - Unsalted herbs and spices for flavor
    - Homemade foods where you control the salt
    
    ### Lower-Potassium Foods
    - Apples, berries, pears, peaches, pineapple
    - Green beans, carrots, cabbage, lettuce
    - White rice, noodles, bread (not whole grain)
    - Chicken, turkey, fish
    - Olive oil, coconut oil
    
    ### Lower-Phosphorus Choices
    - Fresh fruits
    - Fresh vegetables
    - White bread and pasta
    - Rice milk (unfortified)
    - Homemade desserts with allowed ingredients
    
    ### Protein Considerations
    - Egg whites (lower in phosphorus than yolks)
    - Fish
    - Skinless chicken or turkey
    - Lean cuts of meat in controlled portions
    
    ## Foods to Limit or Avoid
    
    ### High-Sodium Foods
    - Processed foods
    - Canned soups and vegetables
    - Deli meats and cured meats
    - Fast food
    - Salty snacks (chips, pretzels, crackers)
    - Condiments and sauces
    - Salt substitutes (often high in potassium)
    
    ### High-Potassium Foods
    - Bananas, oranges, avocados
    - Tomatoes, potatoes, sweet potatoes
    - Spinach, kale, and other dark leafy greens
    - Beans and legumes
    - Nuts and seeds
    - Whole grains
    - Dairy products
    
    ### High-Phosphorus Foods
    - Dairy products (milk, cheese, yogurt)
    - Processed foods with phosphate additives
    - Whole grain products
    - Nuts and seeds
    - Dark sodas and some flavored waters
    - Chocolate
    - Beer and ale
    
    ### Other Foods to Use Cautiously
    - Alcohol (consult your doctor about safe limits)
    - Caffeine
    - Herbal supplements (many can interact with medications or affect kidneys)
    
    ## Practical Tips for Kidney-Friendly Eating
    
    1. **Read food labels carefully** - Look for hidden sodium, potassium, and phosphorus
    2. **Watch for phosphate additives** - Ingredients with "phos" in the name
    3. **Cook from scratch** - Gives you control over ingredients
    4. **Use alternative seasonings** - Herbs, spices, lemon juice, vinegar
    5. **Leach high-potassium vegetables** - Soak and boil to reduce potassium content
    6. **Plan ahead for social occasions** - Check menus or bring kidney-friendly dishes
    7. **Stay hydrated appropriately** - Follow your doctor's fluid recommendations
    
    ## Meal Planning Strategies
    
    Sample meal ideas that are generally kidney-friendly (adjust based on your specific requirements):
    
    ### Breakfast
    - Egg whites with low-sodium herbs and toast
    - Cream of rice with apple and cinnamon
    - Pancakes with berries and small amount of maple syrup
    
    ### Lunch
    - Chicken sandwich on white bread with lettuce and olive oil
    - Pasta salad with cucumber, bell peppers, and vinaigrette
    - Rice bowl with fish and permitted vegetables
    
    ### Dinner
    - Roasted chicken with rice and green beans
    - Beef stir-fry with permitted vegetables and white rice
    - Pasta with olive oil, garlic, and controlled amounts of permitted vegetables
    
    ### Snacks
    - Apple or pear slices
    - Rice cakes
    - Unsalted popcorn (in moderation)
    - Carrots with small amount of hummus
    
    Remember, dietary needs often change as CKD progresses. Regular monitoring of blood work and ongoing consultation with your healthcare team will help guide adjustments to your eating plan over time.
    """
    
    private let sampleArticleContent4 = """
    # Managing Blood Pressure for Kidney Health
    
    High blood pressure (hypertension) and kidney disease are closely connected in a relationship that works both ways. Hypertension is both a leading cause of kidney disease and a common complication that develops as kidney function declines. Understanding and managing this connection is crucial for protecting your kidney health.
    
    ## The Connection Between Blood Pressure and Kidneys
    
    Your kidneys and blood pressure have a symbiotic relationship:
    
    - **How kidneys regulate blood pressure**: Healthy kidneys help control blood pressure by:
      - Filtering excess fluid from blood
      - Producing hormones that regulate blood pressure
      - Balancing sodium and other electrolytes
    
    - **How high blood pressure damages kidneys**: Hypertension can:
      - Damage blood vessels throughout the body, including those in the kidneys
      - Put stress on the filtering units (nephrons)
      - Accelerate kidney function decline
      - Lead to scarring and hardening of kidney tissue
    
    ## Blood Pressure Targets for Kidney Patients
    
    Current clinical guidelines generally recommend the following targets for people with kidney disease:
    
    - For most adults with CKD: below 130/80 mmHg
    - For those with significant protein in the urine (proteinuria): below 125/75 mmHg may be recommended
    
    However, individualized targets should be set with your healthcare provider based on your unique situation, including age, other medical conditions, and medication tolerance.
    
    ## Strategies for Blood Pressure Management
    
    Managing blood pressure effectively typically involves a combination of approaches:
    
    ### Medication Strategies
    
    Most people with CKD require medication to control blood pressure. Common types include:
    
    - **ACE inhibitors and ARBs**: These medications not only lower blood pressure but also help protect kidney function. Names often end in "-pril" (like lisinopril) or "-sartan" (like losartan).
    
    - **Diuretics**: Help reduce fluid retention and lower blood pressure. Your doctor may select specific types based on your kidney function.
    
    - **Calcium channel blockers**: Relax blood vessels and reduce blood pressure.
    
    - **Beta-blockers**: Reduce the heart's workload and lower blood pressure.
    
    It's essential to:
    - Take medications exactly as prescribed
    - Never stop medications without consulting your doctor
    - Report side effects promptly
    - Keep all medical appointments for monitoring
    
    ### Dietary Approaches
    
    Several dietary strategies can help manage blood pressure:
    
    - **Reduce sodium intake**: Aim for less than 2,000 mg per day
      - Avoid processed foods
      - Cook at home with fresh ingredients
      - Use herbs and spices instead of salt
      - Read food labels carefully
    
    - **Consider the DASH diet**: This eating plan is proven to lower blood pressure
      - Rich in fruits, vegetables, whole grains
      - Low in saturated fat and cholesterol
      - Includes lean proteins and low-fat dairy
      - May need modification for CKD (work with a renal dietitian)
    
    - **Monitor potassium intake**: Based on your lab values and CKD stage, you may need to either limit or increase potassium-rich foods
    
    - **Stay hydrated appropriately**: Follow your doctor's fluid intake recommendations
    
    ### Lifestyle Modifications
    
    Several lifestyle changes can significantly impact blood pressure:
    
    - **Maintain healthy weight**: Even modest weight loss can lower blood pressure
      
    - **Regular physical activity**: Aim for 150 minutes per week of moderate activity
      - Always consult your healthcare provider before starting an exercise program
      - Start slowly and increase gradually
      - Consider walking, swimming, or cycling
    
    - **Limit alcohol consumption**: No more than one drink daily for women or two for men
    
    - **Stop smoking**: Tobacco use worsens kidney disease and raises blood pressure
    
    - **Manage stress**: Practice relaxation techniques like deep breathing, meditation, or yoga
    
    ## Monitoring Your Blood Pressure
    
    Regular monitoring is crucial for effective management:
    
    ### At-Home Monitoring
    
    - Use a validated home blood pressure monitor
    - Measure at the same times each day
    - Take readings while seated with back supported and feet flat
    - Record readings in a log or smartphone app
    - Bring your monitor to appointments to verify accuracy
    
    ### When to Seek Medical Attention
    
    Contact your healthcare provider if:
    - Your blood pressure consistently exceeds your target
    - You experience very high readings (above 180/120 mmHg)
    - You have symptoms like severe headache, vision changes, chest pain, or difficulty breathing
    
    ## The Impact of Controlled Blood Pressure
    
    Successfully managing hypertension provides significant benefits:
    
    - Slows progression of kidney disease
    - Reduces risk of cardiovascular complications
    - Decreases likelihood of requiring dialysis or transplant
    - Improves overall quality of life and energy levels
    
    Remember that blood pressure management is a journey, not a one-time fix. Working closely with your healthcare team, monitoring regularly, and maintaining healthy habits all contribute to successful blood pressure control and better kidney outcomes.
    """
    
    private let sampleArticleContent5 = """
    # Understanding the Five Stages of CKD
    
    Chronic Kidney Disease (CKD) is classified into five stages based on how well your kidneys filter waste and extra fluid from your blood. Understanding these stages can help you work with your healthcare team to manage your condition effectively and potentially slow disease progression.
    
    ## How CKD Stages Are Determined
    
    CKD staging is primarily based on your estimated glomerular filtration rate (eGFR), which measures kidney function. Your healthcare provider may also consider other factors, including:
    
    - Presence of protein in your urine (albuminuria/proteinuria)
    - Underlying cause of kidney disease
    - Abnormalities in kidney structure
    - Presence of other complications
    
    ## The Five Stages Explained
    
    ### Stage 1: Kidney Damage with Normal Function
    - **eGFR: 90 mL/min/1.73m² or higher**
    - **What's happening**: There's evidence of kidney damage (such as protein in the urine or structural abnormalities), but kidney function remains normal.
    - **Symptoms**: Usually none; CKD is typically detected during routine testing or evaluation for another condition.
    - **Management focus**: Identifying and treating the underlying cause, controlling blood pressure, managing blood sugar if diabetic, and making lifestyle modifications.
    
    ### Stage 2: Mild Decrease in Kidney Function
    - **eGFR: 60-89 mL/min/1.73m²**
    - **What's happening**: Slight decrease in kidney function with continued evidence of kidney damage.
    - **Symptoms**: Typically still no noticeable symptoms.
    - **Management focus**: Similar to Stage 1, with continued effort to treat underlying causes and prevent progression.
    
    ### Stage 3: Moderate Decrease in Kidney Function
    - **Stage 3A: eGFR 45-59 mL/min/1.73m²**
    - **Stage 3B: eGFR 30-44 mL/min/1.73m²**
    - **What's happening**: Kidneys are not filtering blood efficiently, allowing waste products to build up.
    - **Symptoms**: Some people may begin to notice symptoms, such as:
      - Swelling in hands, feet, or ankles
      - Changes in urination
      - Back pain
      - Early fatigue
    - **Management focus**: More intensive monitoring of kidney function, managing complications like anemia and bone health issues, dietary adjustments, and medication reviews.
    
    ### Stage 4: Severe Decrease in Kidney Function
    - **eGFR: 15-29 mL/min/1.73m²**
    - **What's happening**: Severe reduction in kidney function with significant build-up of waste products.
    - **Symptoms**: More noticeable symptoms, potentially including:
      - Fatigue and weakness
      - Decreased appetite
      - Sleep problems
      - Difficulty concentrating
      - Numbness or tingling in toes or fingers
      - Muscle cramps
    - **Management focus**: Preparation for kidney replacement therapy (dialysis or transplant), intensive management of complications, and careful medication adjustments.
    
    ### Stage 5: Kidney Failure
    - **eGFR: Less than 15 mL/min/1.73m²**
    - **What's happening**: Kidneys can no longer keep up with waste and fluid clearance.
    - **Symptoms**: May include all previous symptoms plus:
      - Severe fatigue
      - Nausea and vomiting
      - Shortness of breath
      - Metallic taste in mouth
      - Itching
      - Decreased mental sharpness
    - **Management focus**: Implementation of kidney replacement therapy (unless conservative management is chosen), continued symptom management, and nutritional support.
    
    ## Disease Progression and Monitoring
    
    ### Rate of Progression
    The rate at which CKD progresses varies significantly between individuals and depends on many factors:
    
    - Underlying cause of kidney disease
    - Effectiveness of treatment
    - Presence of other health conditions
    - Adherence to treatment plans
    - Genetic factors
    
    Some people remain stable at early stages for many years, while others progress more rapidly.
    
    ### Monitoring Recommendations
    
    Typical monitoring includes:
    
    **Stage 1-2:**
    - eGFR and urine albumin: Annually
    - Blood pressure: At each medical visit
    - Review of medications: Annually
    
    **Stage 3:**
    - eGFR and urine albumin: Every 6 months
    - Blood pressure: Every 3-6 months
    - Electrolytes and other blood work: Every 6-12 months
    - Vitamin D, calcium, phosphorus: Annually
    
    **Stage 4-5:**
    - eGFR and comprehensive blood work: Every 3 months
    - Blood pressure: Monthly or more frequently
    - Assessment for complications: Every 3-6 months
    
    ## Living Well at Each Stage
    
    Regardless of your CKD stage, these strategies can help you manage your condition:
    
    - **Follow your treatment plan** carefully
    - **Monitor and control blood pressure** and blood sugar
    - **Adopt a kidney-friendly diet** as advised by your healthcare team
    - **Stay physically active** as appropriate for your condition
    - **Avoid nephrotoxic substances** including certain medications and supplements
    - **Manage stress** through healthy coping mechanisms
    - **Attend all scheduled medical appointments**
    - **Build a support network** of family, friends, and healthcare professionals
    
    ## When to Seek Additional Care
    
    Contact your healthcare provider promptly if you experience:
    - Significant changes in urination patterns
    - Unexplained weight gain or swelling
    - Increased fatigue or weakness
    - Confusion or difficulty concentrating
    - Severe nausea or vomiting
    - Chest pain or severe shortness of breath
    
    Remember that CKD management is highly individualized. Work closely with your healthcare team to develop the best approach for your specific situation at each stage of the disease.
    """
    
    private let sampleArticleContent6 = """
    # Medications to Avoid with Kidney Disease
    
    When you have chronic kidney disease (CKD), your kidneys cannot filter medications from your blood as effectively as healthy kidneys. This means some medications may build up in your system or further damage your kidneys. Understanding which medications require caution is an important part of managing your kidney health.
    
    ## Why Medication Awareness Matters
    
    CKD changes how your body processes medications in several ways:
    
    - Reduced filtering of drugs from the bloodstream
    - Changes in the way drugs bind to proteins in blood
    - Altered metabolism of medications in the liver
    - Changes in how drugs are absorbed
    - Increased sensitivity to certain medication effects
    
    These changes mean that standard doses of some medications may be too high for you, certain drugs may need to be avoided entirely, and medication schedules may need adjustment.
    
    ## Common Medications That Can Affect Kidney Function
    
    ### Over-the-Counter Pain Relievers
    
    **NSAIDs (Non-Steroidal Anti-Inflammatory Drugs)**
    - Examples: ibuprofen (Advil, Motrin), naproxen (Aleve), aspirin (high-dose)
    - Potential impact: Can reduce blood flow to the kidneys and cause further damage
    - Alternative options: Acetaminophen (Tylenol) is generally safer for kidneys when used as directed
    
    ### Prescription Medications
    
    **Certain Antibiotics**
    - Examples: aminoglycosides (gentamicin), some cephalosporins, sulfonamides
    - Potential impact: May cause direct kidney damage, especially with prolonged use
    - Management: Your doctor may adjust dosing or choose alternate antibiotics
    
    **Some Blood Pressure Medications**
    - While ACE inhibitors and ARBs are commonly prescribed to protect kidney function, they require careful monitoring
    - These medications may need dosage adjustments based on your kidney function
    - Never start or stop these medications without medical guidance
    
    **Certain Diabetes Medications**
    - Examples: some sulfonylureas, specific formulations of metformin
    - Potential impact: May build up in the system or become less effective
    - Management: Your healthcare provider may adjust medication types or doses
    
    **Contrast Dyes Used in Imaging Tests**
    - Used in certain X-rays, CT scans, and angiograms
    - Potential impact: Can cause contrast-induced nephropathy in vulnerable individuals
    - Prevention: Inform all providers about your kidney disease before any imaging procedures
    
    ### Supplements and Herbal Products
    
    **Herbal Supplements**
    - Examples: aristolochic acid, thunder god vine, licorice root, and some Chinese herbal products
    - Potential impact: Some contain compounds directly toxic to kidneys
    - Recommendation: Consult with your healthcare provider before taking any herbal supplements
    
    **Nutritional Supplements**
    - High-dose vitamin C, creatine supplements
    - Potential impact: May increase kidney stone risk or create other kidney issues
    - Recommendation: Discuss all supplements with your healthcare provider
    
    ## Working With Your Healthcare Team
    
    ### Important Steps to Take
    
    1. **Create a complete medication list**
       - Include all prescription medications, over-the-counter drugs, vitamins, and supplements
       - Update this list regularly and bring to all appointments
    
    2. **Use one pharmacy if possible**
       - Helps track all your medications and identify potential interactions
    
    3. **Inform all healthcare providers about your kidney disease**
       - Including dentists, specialists, and emergency providers
       - Consider wearing a medical alert bracelet
    
    4. **Ask about kidney safety before taking any new medication**
       - "Is this medication safe for someone with my level of kidney function?"
       - "Does the dosage need to be adjusted for my eGFR?"
    
    5. **Never adjust medications on your own**
       - Even if you experience side effects, consult your provider before making changes
    
    ### Questions to Ask Your Healthcare Provider
    
    - "Which of my current medications need dosage adjustments due to my kidney function?"
    - "What pain relievers are safest for me to use?"
    - "Are there any medications I'm taking that could be replaced with kidney-friendlier alternatives?"
    - "How often should my kidney function be monitored while taking these medications?"
    
    ## Medication Management Tips
    
    - **Use pill organizers** to ensure proper medication adherence
    - **Set alarms** as reminders for medication times
    - **Keep a medication journal** noting any side effects or concerns
    - **Have regular medication reviews** with your healthcare provider or pharmacist
    - **Don't stop prescribed medications** without medical advice, even if you feel better
    
    ## Special Considerations
    
    ### During Illness
    When you're sick with conditions like fever, vomiting, or diarrhea:
    - You may need temporary adjustments to certain medications
    - Contact your healthcare provider if you cannot keep medications down
    - Be especially cautious with NSAIDs during illness
    
    ### Hospital Stays
    Before any procedure or hospital admission:
    - Provide your complete medication list to hospital staff
    - Remind all providers about your kidney disease
    - Ask specifically about contrast dyes if imaging is required
    
    Remember, medication management is a critical part of kidney care. Being proactive and informed about your medications can help protect your remaining kidney function and prevent complications.
    """
    
    private let sampleArticleContent7 = """
    # The Connection Between Diabetes and CKD
    
    Diabetes and chronic kidney disease (CKD) are closely linked conditions that significantly impact each other. Diabetes is the leading cause of kidney failure worldwide, accounting for approximately 44% of new cases. Understanding this connection can help you take steps to protect your kidney health if you have diabetes, or manage both conditions if you're already diagnosed with diabetic kidney disease.
    
    ## How Diabetes Affects the Kidneys
    
    ### The Physiology
    
    Diabetes can damage your kidneys through several mechanisms:
    
    1. **High blood sugar levels** damage blood vessels throughout the body, including the millions of tiny filtering units (nephrons) in your kidneys
       
    2. **Damaged blood vessels in the kidneys** cannot effectively filter waste from your blood
    
    3. **Increased pressure in kidney filters** forces them to work harder, eventually leading to scarring and loss of function
    
    4. **Damaged nerves** (diabetic neuropathy) can affect bladder function, potentially causing urinary tract infections that may damage kidneys
    
    5. **Inflammation** triggered by metabolic changes further damages kidney tissue
    
    This damage typically develops slowly over many years, which is why long-standing, poorly controlled diabetes presents the greatest risk.
    
    ## Risk Factors for Diabetic Kidney Disease
    
    Not everyone with diabetes develops kidney disease. Factors that increase your risk include:
    
    - **Duration of diabetes**: Risk increases with longer duration
    - **Poor blood sugar control**: Consistently high blood sugar accelerates damage
    - **High blood pressure**: Compounds the effects of diabetes on kidneys
    - **Smoking**: Worsens blood vessel damage
    - **Obesity**: Increases inflammation and kidney strain
    - **Family history**: Genetic factors influence susceptibility
    - **Age**: Risk increases with age
    - **Ethnicity**: Higher rates in African Americans, Native Americans, and Hispanics
    
    ## Detecting Kidney Problems in Diabetes
    
    ### Regular Screening is Essential
    
    The American Diabetes Association recommends:
    - Annual screening for protein in urine (albumin/creatinine ratio)
    - Annual blood test for kidney function (eGFR)
    - Regular blood pressure monitoring
    
    ### Early Warning Signs
    
    Early diabetic kidney disease rarely causes symptoms. By the time symptoms appear, significant damage may have occurred. This makes regular screening crucial. Possible early signs include:
    
    - Elevated protein in urine (may not be noticeable without testing)
    - Slightly elevated blood pressure
    - Mild swelling in ankles or feet
    - Minor changes in urination patterns
    
    ## Managing Diabetes to Protect Kidney Health
    
    ### Blood Sugar Management
    
    - **Target HbA1c**: Generally aim for less than 7% for most adults (individualized targets may vary)
    - **Regular glucose monitoring**: Follow your healthcare provider's recommendations
    - **Medication adherence**: Take diabetes medications as prescribed
    - **Lifestyle factors**: Healthy eating, physical activity, and stress management
    
    ### Blood Pressure Control
    
    - **Target**: Generally below 130/80 mmHg for most people with diabetes and kidney disease
    - **Medications**: ACE inhibitors or ARBs are often prescribed as they protect kidneys
    - **Regular monitoring**: Check blood pressure at home if recommended
    - **Lifestyle support**: Low-sodium diet, regular exercise, maintaining healthy weight
    
    ### Additional Protective Strategies
    
    - **Dietary adjustments**: Work with a dietitian to balance diabetes and kidney-friendly eating
    - **Avoid nephrotoxic substances**: Certain medications, including some over-the-counter pain relievers
    - **Treat urinary tract infections promptly**: To prevent kidney infection
    - **Hydration**: Appropriate fluid intake based on your specific situation
    - **Regular exercise**: Improves insulin sensitivity and blood pressure
    - **Smoking cessation**: Critical for blood vessel health
    
    ## Managing Both Conditions Together
    
    When you have both diabetes and CKD, management becomes more complex:
    
    ### Medication Considerations
    
    - Some diabetes medications require adjustment or avoidance with reduced kidney function
    - Your healthcare provider may need to adjust dosages as kidney function changes
    - Metformin, a common diabetes medication, requires special consideration with reduced kidney function
    
    ### Dietary Balancing Act
    
    Balancing dietary needs for both conditions can be challenging:
    
    - **Carbohydrate management** for diabetes control
    - **Protein adjustments** based on CKD stage
    - **Potassium and phosphorus restrictions** may be needed in advanced CKD
    - **Sodium limitation** important for both conditions
    
    Working with a renal dietitian is highly recommended to develop an eating plan that addresses both conditions.
    
    ### Healthcare Team Coordination
    
    Management typically involves multiple specialists:
    
    - **Primary care physician**: Coordinates overall care
    - **Endocrinologist**: Specializes in diabetes management
    - **Nephrologist**: Specializes in kidney disease
    - **Certified diabetes educator**: Provides education and support
    - **Renal dietitian**: Helps with dietary planning
    
    Ensure all providers communicate with each other about your care plan.
    
    ## Long-term Outlook and New Advances
    
    ### Prognosis
    
    With proper management, many people successfully manage both diabetes and kidney disease for years. Even if kidney disease progresses, dialysis and transplantation offer life-sustaining options.
    
    ### Promising Developments
    
    Recent advances offer new hope:
    
    - **SGLT-2 inhibitors**: Newer diabetes medications shown to protect kidney function
    - **GLP-1 receptor agonists**: May offer kidney benefits beyond blood sugar control
    - **Improved dialysis technologies**: For those who need kidney replacement therapy
    - **Artificial kidney research**: Working toward improved replacement options
    
    ## Taking Control of Your Health
    
    Living with diabetes and kidney disease requires commitment to self-care:
    
    1. **Become educated** about both conditions
    2. **Actively participate** in healthcare decisions
    3. **Monitor your numbers** (blood sugar, blood pressure, kidney function)
    4. **Take medications as prescribed**
    5. **Keep all medical appointments**
    6. **Make recommended lifestyle changes**
    7. **Seek support** from healthcare providers, family, and support groups
    
    Remember that while the connection between diabetes and kidney disease is strong, proactive management can significantly slow progression and maintain quality of life.
    """
    
    private let sampleArticleContent8 = """
    # Staying Active with CKD: Exercise Guidelines
    
    Regular physical activity offers numerous benefits for people with chronic kidney disease (CKD), including improved heart health, better blood pressure control, enhanced mood, and increased energy. However, exercise needs to be approached thoughtfully when you have kidney disease. This guide provides practical advice for staying active safely with CKD.
    
    ## Benefits of Exercise for Kidney Patients
    
    Regular physical activity provides specific benefits for people with kidney disease:
    
    - **Improved cardiovascular health**: Reduces risk of heart disease, which is common in CKD
    - **Better blood pressure control**: Helps manage hypertension, a key factor in kidney disease progression
    - **Enhanced muscle function**: Combats muscle wasting that can occur with CKD
    - **Better blood sugar control**: Important for those with diabetes and CKD
    - **Improved sleep quality**: Addresses insomnia common in kidney disease
    - **Weight management**: Helps maintain healthy weight without taxing kidneys
    - **Reduced inflammation**: May help slow kidney disease progression
    - **Improved mental health**: Reduces depression and anxiety common with chronic illness
    - **Better quality of life**: Increases energy and ability to perform daily activities
    
    ## Types of Exercise to Consider
    
    A well-rounded exercise program should include:
    
    ### Aerobic Exercise
    
    **Benefits**: Improves heart and lung function, helps control blood pressure and blood sugar
    **Examples**:
    - Walking
    - Swimming or water aerobics (especially good for reducing joint stress)
    - Stationary cycling
    - Low-impact aerobic classes
    - Light jogging (if approved by your doctor)
    
    **How much**: Aim for 150 minutes weekly of moderate activity (30 minutes, 5 days/week), starting with shorter sessions and gradually increasing
    
    ### Strength Training
    
    **Benefits**: Preserves muscle mass, improves functional strength, enhances metabolism
    **Examples**:
    - Resistance bands
    - Light weights
    - Body weight exercises (modified push-ups, gentle squats)
    - Weight machines with lighter settings
    
    **How much**: 2-3 sessions weekly on non-consecutive days, focusing on major muscle groups
    
    ### Flexibility and Balance
    
    **Benefits**: Reduces injury risk, improves mobility, prevents falls
    **Examples**:
    - Gentle stretching
    - Modified yoga
    - Tai chi
    - Simple balance exercises
    
    **How much**: Daily stretching and 2-3 balance sessions weekly
    
    ## Special Considerations for Different CKD Stages
    
    ### Early CKD (Stages 1-3)
    
    Most exercise types are generally safe with medical clearance. Focus on:
    - Building exercise habits that can continue if disease progresses
    - Emphasizing cardiovascular fitness
    - Monitoring blood pressure response to exercise
    
    ### Advanced CKD (Stages 4-5, Non-Dialysis)
    
    - Lower intensity exercise may be necessary
    - More frequent rest periods
    - Greater focus on preserving strength and daily function
    - Extra attention to hydration status
    
    ### Dialysis Patients
    
    - Timing matters: exercise is generally better tolerated on non-dialysis days
    - Seated exercises can be done during hemodialysis treatment (if facility permits)
    - Protecting vascular access sites during exercise is crucial
    - Addressing anemia and fatigue may require modified approaches
    
    ### Transplant Recipients
    
    - Follow specific guidelines from transplant team
    - Generally can resume most activities after full recovery
    - Protecting the transplanted kidney during contact sports is important
    - Immunosuppression may require avoiding crowded gyms during peak infection seasons
    
    ## Getting Started Safely
    
    ### Before Beginning an Exercise Program
    
    1. **Consult your healthcare team**
       - Get specific recommendations based on your condition
       - Discuss any exercise restrictions
       - Consider a referral to physical therapy for a personalized program
    
    2. **Undergo appropriate screening**
       - Your doctor may recommend cardiac stress testing if you have multiple risk factors
       - Baseline assessment of physical function may be helpful
    
    3. **Set realistic goals**
       - Start with what you can manage, even if it's just 5-10 minutes
       - Plan for gradual progression
       - Focus on consistency rather than intensity initially
    
    ### Safety Precautions
    
    - **Start slowly** and progress gradually
    - **Warm up and cool down** properly (5-10 minutes each)
    - **Stay hydrated** following fluid guidelines from your healthcare team
    - **Monitor your response** to exercise:
      - Track blood pressure before and after if recommended
      - Note any unusual symptoms
      - Watch for excessive fatigue that doesn't resolve with rest
    - **Avoid exercise in extreme temperatures**
    - **Wear appropriate footwear** to prevent injury
    
    ## Warning Signs to Watch For
    
    Stop exercising and contact your healthcare provider if you experience:
    
    - Chest pain or pressure
    - Severe shortness of breath
    - Dizziness or lightheadedness
    - Irregular heartbeat
    - Unusual or severe joint pain
    - Extreme fatigue that doesn't improve with rest
    - Nausea or vomiting during or after exercise
    - Swelling that worsens during activity
    
    ## Overcoming Common Barriers
    
    ### Fatigue
    - Exercise at the time of day when your energy is highest
    - Start with very short sessions and gradually increase
    - Consider seated exercises on low-energy days
    
    ### Muscle Cramps
    - Ensure proper warm-up
    - Discuss mineral imbalances with your healthcare team
    - Consider gentle stretching programs like tai chi
    
    ### Fear of Injury
    - Work with a physical therapist initially
    - Join kidney-friendly exercise programs if available
    - Use proper form and appropriate intensity
    
    ### Motivation Challenges
    - Set small, achievable goals
    - Find an exercise buddy or support group
    - Track progress to see improvements
    - Choose activities you enjoy
    - Remember that some exercise is always better than none
    
    ## Sample Starter Workout
    
    **Warm-Up (5 minutes)**
    - Gentle marching in place
    - Shoulder rolls
    - Knee lifts
    - Ankle circles
    
    **Main Activity (Start with 5-10 minutes, gradually increase)**
    - Walking at a comfortable pace
    - Seated or standing arm exercises with light weights or resistance bands
    - Chair squats (standing up and sitting down slowly)
    
    **Cool-Down (5 minutes)**
    - Slow walking
    - Gentle stretches for major muscle groups
    - Deep breathing
    
    Remember that any movement is beneficial. Even if you can only do a few minutes at first, this is a positive step toward better health. With consistency and gradual progression, most people with CKD can enjoy the numerous benefits of regular physical activity.
    """
    
    private let sampleArticleContent9 = """
    # Understanding Creatinine and BUN Test Results
    
    Blood tests for kidney function are essential tools for diagnosing and monitoring kidney disease. Two of the most common are blood urea nitrogen (BUN) and creatinine tests. Understanding what these values mean can help you take an active role in managing your kidney health.
    
    ## What These Tests Measure
    
    ### Creatinine
    
    Creatinine is a waste product produced by your muscles during normal activity. Healthy kidneys filter creatinine efficiently from your blood into your urine. When kidney function declines, creatinine builds up in your bloodstream.
    
    Key facts about creatinine:
    - It's produced at a relatively steady rate
    - Levels primarily depend on muscle mass and kidney function
    - Not significantly affected by diet
    - Makes it a reliable indicator of kidney function
    
    ### Blood Urea Nitrogen (BUN)
    
    BUN measures the amount of urea nitrogen in your blood. Urea is another waste product created when protein breaks down in your body. Like creatinine, it's normally filtered out by your kidneys.
    
    Key facts about BUN:
    - More variable than creatinine
    - Affected by protein intake, hydration status, and certain medications
    - Can be elevated due to factors other than kidney disease
    - Often interpreted alongside creatinine for a more complete picture
    
    ## Normal Ranges and What They Mean
    
    ### Typical Reference Ranges
    
    **Creatinine:**
    - Adult males: 0.7 to 1.3 mg/dL (62 to 115 μmol/L)
    - Adult females: 0.6 to 1.1 mg/dL (53 to 97 μmol/L)
    - Ranges may vary slightly between laboratories
    
    **BUN:**
    - Adults: 7 to 20 mg/dL (2.5 to 7.1 mmol/L)
    - Ranges may vary slightly between laboratories
    
    ### Understanding Elevated Levels
    
    **Elevated Creatinine:**
    - Mild elevation (1.3-2.0 mg/dL): May indicate early kidney dysfunction
    - Moderate elevation (2.0-5.0 mg/dL): Suggests significant kidney impairment
    - Severe elevation (>5.0 mg/dL): Often indicates severe kidney disease
    
    **Elevated BUN:**
    - Mild elevation (21-40 mg/dL): May indicate early kidney issues or non-kidney causes
    - Moderate elevation (41-80 mg/dL): Suggests significant kidney impairment
    - Severe elevation (>80 mg/dL): Usually indicates severe kidney dysfunction
    
    ### The BUN-to-Creatinine Ratio
    
    The ratio between these two values can provide additional insights:
    - Normal ratio: 10:1 to 20:1
    - Ratio >20:1: May suggest dehydration, high protein diet, or certain medications
    - Ratio <10:1: May indicate liver disease, malnutrition, or pregnancy
    
    ## Factors That Can Affect Test Results
    
    ### Non-Kidney Factors Affecting Creatinine
    
    - **Muscle mass**: More muscle produces more creatinine (why men typically have higher levels)
    - **Age**: Muscle mass decreases with age, potentially masking kidney issues in elderly
    - **Diet**: Eating large amounts of cooked meat may temporarily increase levels
    - **Certain medications**: Some drugs can affect creatinine without changing kidney function
    - **Vigorous exercise**: Can cause temporary elevations
    
    ### Non-Kidney Factors Affecting BUN
    
    - **Protein intake**: High-protein diets can raise BUN
    - **Hydration status**: Dehydration can significantly increase BUN
    - **Gastrointestinal bleeding**: Blood in digestive tract can raise BUN
    - **Medications**: Including corticosteroids, antibiotics, and diuretics
    - **Heart failure**: Can reduce blood flow to kidneys
    - **Liver disease**: Can impair urea production
    
    ## Beyond the Basic Numbers
    
    ### eGFR: The Calculated Kidney Function
    
    Estimated glomerular filtration rate (eGFR) is calculated using your creatinine level along with factors like:
    - Age
    - Gender
    - Race (in some equations)
    - Body size (in some equations)
    
    eGFR provides a more accurate assessment of kidney function than creatinine alone and is used to determine CKD stages:
    - Stage 1: eGFR ≥90 mL/min/1.73m² (with evidence of kidney damage)
    - Stage 2: eGFR 60-89 mL/min/1.73m² (with evidence of kidney damage)
    - Stage 3a: eGFR 45-59 mL/min/1.73m²
    - Stage 3b: eGFR 30-44 mL/min/1.73m²
    - Stage 4: eGFR 15-29 mL/min/1.73m²
    - Stage 5: eGFR <15 mL/min/1.73m² (kidney failure)
    
    ### Other Kidney Function Tests
    
    For a complete picture, your doctor may order additional tests:
    - **Urine albumin-to-creatinine ratio**: Measures protein leakage into urine
    - **Cystatin C**: An alternative marker for kidney function
    - **Complete metabolic panel**: Checks electrolytes, acid-base balance, and more
    - **24-hour urine collection**: Provides precise measurement of kidney filtration
    
    ## Monitoring Changes Over Time
    
    The trend in your test results is often more important than a single measurement:
    - **Stability**: Even elevated values that remain stable may indicate controlled disease
    - **Rising levels**: May signal disease progression requiring intervention
    - **Declining levels**: Can indicate improvement in kidney function
    
    ### What to Track
    
    Keep a record of:
    - Your test values and dates
    - Normal ranges from your lab
    - eGFR calculations
    - Any significant changes in diet, medication, or hydration around testing time
    
    ## When to Be Concerned
    
    ### Red Flags That Warrant Medical Attention
    
    - **Sudden increase in creatinine** (>0.3 mg/dL from baseline)
    - **Creatinine that doubles** from baseline
    - **Rapid decline in eGFR** (>3 mL/min/1.73m² per year)
    - **New onset of protein in urine** with elevated creatinine
    - **Symptoms** along with abnormal lab values:
      - Swelling in feet or ankles
      - Fatigue or weakness
      - Changes in urination
      - Persistent nausea
    
    ## Questions to Ask Your Healthcare Provider
    
    When discussing your kidney function tests, consider asking:
    
    - "What do my creatinine and BUN values indicate about my kidney health?"
    - "Has there been any significant change since my last test?"
    - "What is my eGFR, and what CKD stage does it correspond to?"
    - "How often should I have these tests repeated?"
    - "Are there any lifestyle changes I should make based on these results?"
    - "Should I adjust my diet or fluid intake?"
    - "Are any of my medications affecting these test results?"
    - "Do I need to see a kidney specialist (nephrologist)?"
    
    ## Taking Control of Your Kidney Health
    
    Understanding your kidney function tests empowers you to participate actively in your healthcare. Here are steps you can take:
    
    ### Keep a Health Journal
    
    Track your:
    - Test results over time
    - Blood pressure readings
    - Medications and dosages
    - Diet and fluid intake
    - Symptoms or changes in how you feel
    
    ### Make Informed Lifestyle Choices
    
    - **Stay hydrated appropriately**: Follow your doctor's fluid recommendations
    - **Follow kidney-friendly dietary guidelines**: Especially regarding sodium, potassium, phosphorus, and protein
    - **Control blood pressure and blood sugar**: Two major factors in kidney health
    - **Exercise regularly**: As appropriate for your condition
    - **Avoid nephrotoxic substances**: Including certain over-the-counter pain medications
    
    ### Partner with Your Healthcare Team
    
    - Prepare questions before appointments
    - Bring your health journal to discussions
    - Consider bringing a family member or friend for support
    - Follow up on referrals to specialists if recommended
    
    Remember that kidney function tests are valuable tools for monitoring your health, but they're just one part of your overall healthcare picture. Work with your healthcare team to interpret these results in the context of your unique medical situation.
    """
    
    private let sampleArticleContent10 = """
    # Salt and CKD: Finding the Right Balance
    
    Managing sodium (salt) intake is a critical aspect of kidney health, especially for those with chronic kidney disease (CKD). The right balance can help control blood pressure, reduce fluid retention, and slow CKD progression. This guide explains why salt matters for kidney patients and offers practical strategies for maintaining a kidney-friendly sodium intake.
    
    ## Why Sodium Matters for Kidney Health
    
    ### The Kidney-Sodium Connection
    
    Healthy kidneys regulate sodium balance by:
    - Filtering sodium from the blood
    - Retaining what the body needs
    - Excreting excess sodium through urine
    
    When kidneys are damaged, this delicate balance is disrupted:
    - Sodium retention increases
    - Fluid builds up in tissues
    - Blood pressure rises
    - Extra strain is placed on the heart and blood vessels
    - Kidney damage may accelerate
    
    ### Common Consequences of High Sodium in CKD
    
    - **Fluid retention and edema**: Swelling in ankles, feet, hands, or around the eyes
    - **Increased blood pressure**: Further damaging blood vessels in the kidneys
    - **Greater thirst**: Leading to increased fluid intake that kidneys cannot process efficiently
    - **Shortness of breath**: From fluid in the lungs
    - **Heart complications**: Including heart failure from chronic volume overload
    
    ## How Much Sodium is Appropriate?
    
    ### General Guidelines
    
    - **For most CKD patients**: 2,000 mg per day (about 1 teaspoon of table salt)
    - **For those with severe CKD, heart failure, or significant edema**: 1,500 mg or less per day
    
    These are general recommendations. Your healthcare provider may suggest different targets based on your:
    - CKD stage
    - Blood pressure
    - Medication regimen
    - Other health conditions
    - Individual response to sodium
    
    ## Where Sodium Hides in Your Diet
    
    ### Major Sources of Dietary Sodium
    
    Many people are surprised to learn that most dietary sodium doesn't come from the salt shaker:
    
    - **Processed and packaged foods**: 70% of dietary sodium
      - Canned soups and vegetables
      - Frozen dinners
      - Processed meats (deli meats, bacon, sausage)
      - Fast food and restaurant meals
      - Snack foods (chips, pretzels, crackers)
      - Bread and baked goods
    
    - **Natural sources**: About 15% of dietary sodium
      - Dairy products
      - Meat and shellfish
      - Some vegetables like celery and beets
    
    - **Salt added during cooking and at the table**: About 15% of dietary sodium
    
    ### Surprising High-Sodium Foods
    
    Some foods contain unexpectedly high sodium amounts:
    - Cottage cheese (400-900 mg per cup)
    - Breakfast cereals (up to 300 mg per serving)
    - Vegetable juices (up to 700 mg per cup)
    - Sports drinks (up to 200 mg per bottle)
    - Some medications (antacids, pain relievers)
    
    ## Practical Strategies for Reducing Sodium
    
    ### Reading Food Labels
    
    Become an expert at identifying sodium on food labels:
    - Look for "Sodium" on the Nutrition Facts panel
    - Check the % Daily Value (DV)
      - 5% DV or less is low
      - 20% DV or more is high
    - Watch for these high-sodium ingredients:
      - Salt
      - Sodium chloride
      - Monosodium glutamate (MSG)
      - Sodium bicarbonate (baking soda)
      - Sodium nitrite or nitrate
      - Disodium phosphate
    
    ### Cooking and Food Preparation
    
    - **Cook at home more often**: Gives you control over sodium content
    - **Rinse canned foods**: Can reduce sodium content by up to 40%
    - **Use fresh ingredients**: Fresh vegetables, fruits, and unprocessed meats
    - **Cook from scratch**: Avoid prepared mixes and sauces
    - **Measure salt in recipes**: Gradually reduce amounts used
    - **Drain and rinse canned beans**: Reduces sodium by up to 40%
    
    ### Flavor Without Salt
    
    Explore these salt alternatives:
    - **Herbs and spices**: Basil, oregano, thyme, pepper, paprika
    - **Citrus**: Lemon or lime juice and zest
    - **Vinegars**: Balsamic, red wine, rice vinegar
    - **Aromatics**: Garlic, onions, ginger
    - **Heat**: Chili peppers, cayenne, hot sauce (check labels)
    - **Low-sodium seasonings**: Mrs. Dash, salt-free herb blends
    
    ### Eating Out Strategies
    
    - **Research menus in advance**: Many restaurants post nutritional information online
    - **Special requests**: Ask for:
      - No added salt during preparation
      - Sauces and dressings on the side
      - Steamed vegetables without salt
    - **Choose wisely**: 
      - Grilled, broiled, or roasted items
      - Fresh salads with oil and vinegar
      - Items marked "heart-healthy" or "low-sodium"
    - **Portion control**: Restaurant portions often contain an entire day's sodium allowance
    
    ## Managing the Transition to Lower Sodium
    
    ### Adjusting Your Taste Buds
    
    Taste preferences for salt can change over time:
    - **Gradual reduction**: Slowly decrease sodium to allow taste buds to adjust
    - **3-week adjustment period**: Most people adapt to lower sodium in about 21 days
    - **Enhanced sensitivity**: Many people report food tastes too salty after adjustment
    
    ### Practical Tips for Success
    
    - **Start with one meal**: Begin with breakfast, typically lowest in sodium
    - **Prioritize biggest sources**: Focus first on foods providing the most sodium in your diet
    - **Keep a food diary**: Track sodium intake to identify patterns and opportunities
    - **Create a support system**: Engage family members in reduced-sodium eating
    - **Celebrate small wins**: Acknowledge progress in developing new habits
    
    ## Balancing Sodium with Other Nutrients
    
    ### The Sodium-Potassium Balance
    
    Potassium helps counteract sodium's effects on blood pressure, but CKD can affect potassium handling:
    - **For early CKD**: Adequate potassium may be beneficial
    - **For advanced CKD**: Potassium restriction may be necessary
    - **Always follow medical guidance**: Don't change potassium intake without consulting your healthcare team
    
    ### Other Mineral Considerations
    
    - **Phosphorus**: Often restricted in CKD
    - **Calcium**: May require supplements depending on CKD stage
    - **Magnesium**: Levels should be monitored
    
    ## Monitoring Your Progress
    
    ### Signs of Success
    
    Indicators that your sodium management is working:
    - Decreased blood pressure
    - Reduced swelling
    - Improved breathing
    - Less thirst
    - Better control of body weight
    - Improved lab values
    
    ### When to Seek Adjustments
    
    Contact your healthcare provider if:
    - You struggle to maintain recommended limits
    - You experience persistent swelling despite following guidelines
    - You feel excessively restricted by your diet
    - You have questions about specific foods or beverages
    
    ## Putting It All Together: Sample Meal Plan
    
    ### Low-Sodium Day (Approximately 2,000 mg)
    
    **Breakfast**
    - Oatmeal made with milk, topped with berries and cinnamon
    - Hard-boiled egg
    - Fresh fruit
    
    **Lunch**
    - Homemade chicken salad with herbs, lemon juice, and olive oil
    - Fresh vegetables with homemade herb dip
    - Unsalted rice cakes
    
    **Snack**
    - Apple with thin spread of unsalted nut butter
    - Homemade unsalted popcorn with herbs
    
    **Dinner**
    - Herb-roasted fish or chicken
    - Steamed vegetables with lemon juice and pepper
    - Rice pilaf made with low-sodium broth and herbs
    - Green salad with oil and vinegar dressing
    
    Remember that finding the right sodium balance is an ongoing process that requires attention and adjustment. Working closely with your healthcare team, particularly a renal dietitian, can help you develop a sustainable approach to sodium management that protects your kidney function while still allowing you to enjoy delicious and satisfying meals.
    """
    
    // MARK: - Article Detail View
    struct ArticleDetailView: View {
        let article: EducationArticle
        let isBookmarked: Bool
        let onBookmarkToggle: (UUID) -> Void
        
        @Environment(\.presentationMode) var presentationMode
        @State private var scrollOffset: CGFloat = 0
        @State private var textSize: CGFloat = 16
        
        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Article header image
                    Image(article.imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()
                    
                    // Article content
                    VStack(alignment: .leading, spacing: 16) {
                        // Category badge
                        Text(article.category)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(5)
                        
                        // Title
                        Text(article.title)
                            .font(.system(.title, design: .serif))
                            .fontWeight(.bold)
                            .lineSpacing(4)
                        
                        // Meta info
                        HStack(spacing: 12) {
                            // Read time
                            HStack(spacing: 4) {
                                Image(systemName: "clock")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Text("\(article.readTime) min read")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            // Text size controls
                            HStack(spacing: 12) {
                                Button(action: {
                                    if textSize > 14 {
                                        textSize -= 2
                                    }
                                }) {
                                    Image(systemName: "textformat.size.smaller")
                                        .foregroundColor(.primary)
                                }
                                
                                Button(action: {
                                    if textSize < 22 {
                                        textSize += 2
                                    }
                                }) {
                                    Image(systemName: "textformat.size.larger")
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Markdown content
                        MarkdownText(article.content)
                            .font(.system(size: textSize))
                            .lineSpacing(textSize * 0.3)
                            .padding(.bottom, 40)
                    }
                    .padding(20)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onBookmarkToggle(article.id)
                    }) {
                        Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 18))
                            .foregroundColor(isBookmarked ? .blue : .primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        // Share the article
                        let activityItems = [article.title, article.summary]
                        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                        
                        // Present the activity view controller
                        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18))
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
    
    // A simple markdown renderer component
    struct MarkdownText: View {
        let markdownText: String
        
        init(_ markdownText: String) {
            self.markdownText = markdownText
        }
        
        var body: some View {
            Text(try! AttributedString(markdown: markdownText))
        }
    }
    
    // MARK: - Supporting Models
    
    // Article categories
    enum ArticleCategory: String, CaseIterable {
        case all = "All"
        case basics = "Basics"
        case nutrition = "Nutrition"
        case medication = "Medication"
        case lifestyle = "Lifestyle"
        case testing = "Testing"
        case management = "Management"
        case comorbidities = "Comorbidities"
        
        var name: String {
            return rawValue
        }
    }
    
    // Education article model
    struct EducationArticle: Identifiable {
        var id = UUID()
        var title: String
        var summary: String
        var imageURL: String
        var category: String
        var readTime: Int // in minutes
        var content: String
        var categoryType: ArticleCategory
        var isFeatured: Bool = false
    }
    
    // MARK: - Previews
    struct EducationCenterView_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                EducationCenterView()
            }
            .preferredColorScheme(.light)
            
            NavigationView {
                EducationCenterView()
            }
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark Mode")
        }
    }
}
