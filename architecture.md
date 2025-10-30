# Aura - E-Commerce App Architecture

## Project Overview
Aura is a premium e-commerce mobile app targeting tech-savvy women in India (18-40 years), focusing on modern and ethnic fashion with exceptional UX through smooth animations and microinteractions.

## Design Philosophy
- **Aesthetic**: Clean, modern, elegant with ample white space
- **Color Palette**: 
  - Primary: Dusty Rose (#D8A7B1)
  - Secondary: Off-white (#FDFDFD)
  - Accent: Gold (#BFA181)
  - Text: Charcoal (#343434)
- **Typography**: Playfair Display (headings) + Inter (body)
- **Key Differentiator**: Smooth, purposeful animations and microinteractions

## Technical Stack
- **Framework**: Flutter (latest)
- **State Management**: Provider
- **Navigation**: Flutter Navigator
- **Storage**: Local Storage (shared_preferences)
- **Animations**: Flutter's built-in animation framework + Lottie

## App Architecture (MVP - 10-12 files)

### Data Models (`lib/models/`)
1. **user.dart** - User profile, addresses, preferences
2. **product.dart** - Product details, images, pricing, ratings
3. **cart_item.dart** - Cart items with quantity
4. **order.dart** - Order history and tracking
5. **address.dart** - Shipping addresses

### Services (`lib/services/`)
1. **user_service.dart** - User management and authentication
2. **product_service.dart** - Product catalog, search, filtering
3. **cart_service.dart** - Cart operations
4. **order_service.dart** - Order management
5. **storage_service.dart** - Local storage operations

### Screens (`lib/screens/`)
1. **splash_screen.dart** - Animated splash
2. **onboarding_screen.dart** - 3-screen carousel
3. **auth_screen.dart** - Login/signup
4. **main_screen.dart** - Bottom nav wrapper
5. **home_screen.dart** - Home with banners, categories, collections
6. **product_list_screen.dart** - Grid/list view with filters
7. **product_detail_screen.dart** - Product details with hero animation
8. **cart_screen.dart** - Shopping cart
9. **checkout_screen.dart** - Multi-step checkout
10. **profile_screen.dart** - User profile and settings

### Widgets (`lib/widgets/`)
- **animated_button.dart** - Stateful animated buttons
- **product_card.dart** - Reusable product card with animations
- **filter_panel.dart** - Slide-in filter drawer

### Constants (`lib/constants/`)
- **app_constants.dart** - Categories, colors, sizes

## Implementation Plan

### Phase 1: Foundation
1. Update theme with Aura color palette
2. Create all data models with toJson/fromJson
3. Set up service classes with local storage
4. Add sample product data

### Phase 2: Authentication & Onboarding
5. Build splash screen with animation
6. Create onboarding carousel
7. Implement auth screen (email/password, guest mode)

### Phase 3: Core Shopping Experience
8. Build main navigation structure
9. Implement home screen with animated sections
10. Create product listing with grid/list toggle
11. Build product detail screen with hero animation
12. Implement search and filter functionality

### Phase 4: Cart & Checkout
13. Create shopping cart with slide-in animation
14. Build checkout flow with progress indicator
15. Implement order confirmation

### Phase 5: Profile & Polish
16. Create profile screen with order history
17. Add wishlist functionality
18. Polish all animations and transitions
19. Test and debug

### Phase 6: Final Validation
20. Run compile_project to fix all Dart errors

## Key Features

### Animations & Microinteractions
- Hero transitions for product images
- Staggered list animations
- Stateful button animations (idle/loading/success)
- Pull-to-refresh with custom animation
- Swipe to dismiss gestures
- Bottom nav with bounce/scale animations
- Smooth filter panel transitions
- Add-to-cart flying icon animation

### User Experience
- Guest checkout option
- Multiple saved addresses
- Real-time search suggestions
- Persistent cart across sessions
- Order tracking
- Wishlist management

## Sample Data Strategy
All sample data will be stored in local storage via service classes, including:
- 20+ sample products across categories (Dresses, Sarees, Handbags, Jewelry, etc.)
- Sample user with order history
- Pre-configured addresses

## Categories
- Dresses
- Sarees
- Handbags
- Jewelry
- Footwear
- Ethnic Wear
