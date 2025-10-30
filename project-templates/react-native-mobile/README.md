# React Native Mobile App Template

## Stack Overview

- **Frontend**: React Native with TypeScript (Expo)
- **Backend**: **NOT INCLUDED** - Pair with fullstack template (Next.js + Node.js/FastAPI + Supabase/MongoDB)
- **Testing**: Mobile MCP (iOS/Android automation), Jest (unit tests)
- **MCPs**: Mobile MCP (project), Backend-specific MCPs (configured separately)

## ⚠️ Important: Backend Architecture

**This template is FRONTEND ONLY (mobile app). You MUST pair it with a backend template.**

### Recommended Backend Stacks

**Option 1: Next.js + Node.js + Supabase** (Most Popular)
- Full authentication (email, OAuth, magic link)
- Real-time subscriptions
- File storage
- PostgreSQL database

**Option 2: Next.js + FastAPI + Supabase** (ML/AI Projects)
- Python backend for ML/data processing
- Same Supabase features as Option 1
- Great for AI-powered mobile apps

**Option 3: Next.js + Node.js + MongoDB** (Document-Heavy Apps)
- Flexible schema
- Good for content-driven apps

### Project Structure

```
my-mobile-app/                 # Mobile frontend (this template)
  └── src/
      ├── components/
      ├── screens/
      ├── navigation/
      └── services/api.ts       # Calls backend API

my-mobile-backend/             # Backend (separate template)
  ├── backend/                 # API server
  ├── frontend/                # Admin dashboard (Next.js)
  └── .mcp.json                # Backend MCPs (Supabase/MongoDB + API Server)
```

**Both projects can use the same database** - Mobile app calls backend API endpoints.

## Quick Start

### Prerequisites

- Node.js 18+ and npm
- Expo CLI (`npm install -g expo-cli`)
- iOS Simulator (Mac) or Android Emulator
- Claude Code with Mobile MCP
- **A backend project** (create one of the fullstack templates first)

### Initial Setup

1. **Create backend project first**:
   ```bash
   # From mydevwf directory
   npm run create-project nextjs-nodejs-supabase my-mobile-backend
   cd ../my-mobile-backend

   # Set up backend (follow backend README)
   npm install
   supabase start
   npm run dev:backend  # Backend runs on http://localhost:3000
   ```

2. **Create mobile project**:
   ```bash
   # From mydevwf directory
   npm run create-project react-native-mobile my-mobile-app
   cd ../my-mobile-app
   ```

3. **Install dependencies**:
   ```bash
   npm install
   ```

4. **Configure API endpoint**:
   ```bash
   # Create .env file
   echo "API_BASE_URL=http://localhost:3000" > .env

   # For real device testing, use your computer's IP
   # echo "API_BASE_URL=http://192.168.1.100:3000" > .env
   ```

5. **Start Expo development server**:
   ```bash
   npm start
   ```

6. **Run on device/simulator**:
   ```bash
   # iOS (Mac only)
   npm run ios

   # Android
   npm run android

   # Expo Go app (scan QR code)
   # Download Expo Go from App Store / Play Store
   ```

7. **Verify MCPs**:
   ```bash
   # In Claude Code (at mobile project directory)
   /mcp
   # Should show: mobile-mcp (and backend MCPs if working on fullstack)
   ```

### Development Workflow

Follow the BMad enhanced development workflow:

1. **Planning Phase** (Web UI recommended):
   - Use PM agent to create PRD
   - Use Architect agent to design mobile app architecture
   - Use UX Expert for mobile UI/UX specifications
   - Save documents to `docs/` directory

2. **Development Phase** (Claude Code):
   ```bash
   # Create story
   /BMad/agents/sm

   # Implement story
   /BMad/agents/dev
   /BMad/tasks/execute-checklist docs/stories/{story-file}.md
   ```

3. **QA Phase**:
   ```bash
   /BMad/agents/qa
   *review docs/stories/{story-file}.md
   ```

## MCP Usage

### Mobile MCP (Device Automation) ⭐ NEW

**What It Does**: Gives Claude Code direct control over iOS/Android simulators and real devices

**Configuration**: Automatically configured in `.mcp.json`

**Usage in Claude Code**:
```
"Launch the app on iPhone 15 simulator and test the login screen"
→ Mobile MCP lists devices, launches app, interacts with UI

"Test user registration on Android emulator"
→ Mobile MCP automates form filling, button taps, validates screens

"Take a screenshot of the dashboard screen on iPad"
→ Mobile MCP captures screenshot and returns image

"List all UI elements on the current screen"
→ Mobile MCP returns accessibility tree with all tappable elements
```

**Available Tools** (17 total):

**Device Management**:
- `mobile_list_available_devices` - Find connected devices/simulators
- `mobile_launch_app` - Start your app
- `mobile_install_app` - Install .app/.apk file
- `mobile_terminate_app` - Stop running app
- `mobile_uninstall_app` - Remove app

**UI Interaction**:
- `mobile_click_on_screen_at_coordinates` - Tap buttons, links
- `mobile_type_keys` - Enter text into inputs
- `mobile_swipe_on_screen` - Swipe up/down/left/right
- `mobile_long_press_on_screen_at_coordinates` - Long press interactions
- `mobile_double_tap_on_screen` - Double tap gestures

**Screen Inspection**:
- `mobile_list_elements_on_screen` - Get all UI elements (accessibility tree)
- `mobile_take_screenshot` - Capture screen (base64 image)
- `mobile_save_screenshot` - Save screenshot to file
- `mobile_get_screen_size` - Get device dimensions

**Device Control**:
- `mobile_press_button` - Press hardware buttons (home, volume)
- `mobile_open_url` - Open deep links
- `mobile_set_orientation` - Portrait/landscape
- `mobile_get_orientation` - Get current orientation

### Backend MCPs (Configured in Backend Project)

When working on fullstack features, you'll also use backend MCPs:

**Supabase MCP** (if using Supabase backend):
```
"Query all users from the database"
"Create a new row in the posts table"
"Generate migration to add a column"
```

**API Server MCP** (if using OpenAPI MCP Generator):
```
"Call POST /api/users/register with test data"
"Test the GET /api/posts endpoint"
```

**MongoDB MCP** (if using MongoDB backend):
```
"Find all documents in the users collection"
"Create an index on email field"
```

## Project Structure

```
.
├── .mcp.json                          # MCP configuration (Mobile MCP + Backend API)
├── .env                               # Environment variables (API_BASE_URL)
├── app.json                           # Expo configuration
├── package.json                       # Dependencies
├── tsconfig.json                      # TypeScript configuration
├── src/
│   ├── components/                    # Reusable components
│   │   ├── common/                    # Shared components (Button, Input, Card)
│   │   ├── forms/                     # Form components
│   │   └── layout/                    # Layout components (Header, Footer)
│   ├── screens/                       # Screen components
│   │   ├── auth/                      # Authentication screens
│   │   ├── home/                      # Home screen
│   │   └── profile/                   # Profile screens
│   ├── navigation/                    # React Navigation setup
│   │   ├── AppNavigator.tsx           # Main navigator
│   │   ├── AuthNavigator.tsx          # Auth flow navigator
│   │   └── types.ts                   # Navigation types
│   ├── services/                      # External integrations
│   │   ├── api.ts                     # Backend API client
│   │   ├── auth.ts                    # Authentication service
│   │   └── storage.ts                 # AsyncStorage wrapper
│   ├── hooks/                         # Custom React hooks
│   ├── utils/                         # Utility functions
│   ├── types/                         # TypeScript types
│   └── constants/                     # App constants (colors, fonts, etc.)
├── tests/
│   ├── unit/                          # Jest unit tests
│   └── e2e/                           # Mobile MCP E2E test scenarios (markdown)
├── docs/                              # BMad documentation
│   ├── prd.md.template                # PRD template
│   ├── architecture/                  # Architecture docs
│   ├── epics/                         # Sharded epics
│   ├── stories/                       # User stories
│   └── qa/                            # QA assessments and gates
└── README.md                          # This file
```

## Technology Details

### React Native + Expo

**Key Features**:
- Cross-platform (iOS + Android from single codebase)
- TypeScript for type safety
- Expo managed workflow (no Xcode/Android Studio needed)
- Hot reload for fast development
- Access to native APIs via Expo SDK

**Navigation** (React Navigation):
```typescript
// src/navigation/AppNavigator.tsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

export default function AppNavigator() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Profile" component={ProfileScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

**API Integration**:
```typescript
// src/services/api.ts
import axios from 'axios';
import { API_BASE_URL } from '@env';

const api = axios.create({
  baseURL: API_BASE_URL, // http://localhost:3000 or https://api.yourapp.com
  timeout: 10000,
});

// Add auth token to requests
api.interceptors.request.use((config) => {
  const token = await AsyncStorage.getItem('authToken');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export default api;
```

**State Management** (Context API + Hooks):
```typescript
// src/context/AuthContext.tsx
import React, { createContext, useState, useContext } from 'react';

interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }) {
  const [user, setUser] = useState<User | null>(null);

  const login = async (email: string, password: string) => {
    const response = await api.post('/api/auth/login', { email, password });
    setUser(response.data.user);
    await AsyncStorage.setItem('authToken', response.data.token);
  };

  return (
    <AuthContext.Provider value={{ user, login, logout }}>
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
};
```

### Backend Integration

**Connecting to Supabase Backend**:
```typescript
// src/services/api.ts
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
);

// Authentication
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'password',
});

// Query data
const { data: posts } = await supabase
  .from('posts')
  .select('*, author:users(*)')
  .eq('published', true);

// Real-time subscriptions
const channel = supabase
  .channel('posts')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'posts' },
    (payload) => console.log('New post:', payload)
  )
  .subscribe();
```

**Connecting to Node.js/FastAPI Backend**:
```typescript
// src/services/api.ts
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.API_BASE_URL, // http://localhost:3000
});

// Fetch users
const response = await api.get('/api/users');
console.log(response.data);

// Create post
const newPost = await api.post('/api/posts', {
  title: 'My Post',
  content: 'Post content here',
});
```

## Testing Strategy

### Unit Tests (Jest + React Native Testing Library)

```bash
npm test
npm run test:coverage
```

**Example Test**:
```typescript
// src/components/common/Button.test.tsx
import { render, fireEvent } from '@testing-library/react-native';
import Button from './Button';

test('calls onPress when pressed', () => {
  const onPress = jest.fn();
  const { getByText } = render(<Button title="Click Me" onPress={onPress} />);

  fireEvent.press(getByText('Click Me'));
  expect(onPress).toHaveBeenCalledTimes(1);
});
```

### E2E Tests (Mobile MCP via Claude Code)

**Test Scenarios** (Markdown format):
```markdown
# E2E Test Scenarios: User Registration

## TC1.1: Successful Registration

**Priority**: P0 (Critical)

**Steps**:
1. Launch app on iPhone 15 simulator
2. Navigate to registration screen
3. Enter email: test@example.com
4. Enter password: SecurePass123!
5. Tap "Sign Up" button

**Expected Result**:
- User created in backend database
- User redirected to dashboard screen
- Welcome message displayed

**Screenshots**:
- registration_form.png (before submission)
- dashboard_after_signup.png (after successful registration)
```

**MCP-Enhanced Testing** (QA Agent):
```
/BMad/agents/qa
*review docs/stories/1.2.story.md

# QA agent uses Mobile MCP to execute scenarios:
"Launch app on iPhone 15 simulator"
→ mobile_list_available_devices, mobile_launch_app

"List all UI elements on registration screen"
→ mobile_list_elements_on_screen

"Tap the email input field and enter test@example.com"
→ mobile_click_on_screen_at_coordinates, mobile_type_keys

"Take screenshot after registration"
→ mobile_take_screenshot
```

## Common Commands

```bash
# Development
npm start                    # Start Expo dev server
npm run ios                  # Run on iOS simulator (Mac only)
npm run android              # Run on Android emulator
npm run web                  # Run in browser (Expo web)

# Testing
npm test                     # Run Jest unit tests
npm run test:watch           # Watch mode
npm run test:coverage        # Coverage report

# Building
npm run build:ios            # Build iOS app
npm run build:android        # Build Android app
expo build:ios               # Expo build (legacy)
eas build --platform ios     # EAS Build (recommended)

# MCP
npm run mcp:verify           # Check MCP status (if configured)
```

## Mobile MCP Workflow

### Standard Development Cycle

1. **Dev Phase** (Implement feature):
   ```
   /BMad/agents/dev
   *develop-story docs/stories/2.1.story.md

   # Dev writes:
   - React Native components
   - Navigation logic
   - API integration
   - E2E test scenarios (markdown)

   # Dev outputs QA Handoff
   ```

2. **QA Phase** (Test on devices):
   ```
   /BMad/agents/qa
   *review docs/stories/2.1.story.md

   # QA uses Mobile MCP:
   "Launch app on iPhone 15 Pro simulator"
   "Navigate to user profile screen"
   "Take screenshot of profile screen"
   "List all tappable elements"
   "Tap the edit button"
   "Enter new username: JohnDoe123"
   "Tap save button"
   "Verify username updated via GET /api/users/me"

   # QA creates gate file (PASS/FAIL)
   ```

### Example: Complete Mobile Story Flow

```
1. UX Expert: Creates mobile UI specifications
   - Navigation structure (Tab Navigator + Stack Navigator)
   - Screen layouts (using React Native primitives)
   - Component library (React Native Elements / NativeBase)

2. Architect: Documents mobile architecture
   - API integration patterns
   - State management (Context API, Redux, MobX)
   - Navigation structure
   - Offline-first strategy (AsyncStorage, NetInfo)

3. SM: Creates story "Implement User Profile Screen"
   - References UX spec and architecture docs

4. Dev: Implements story
   - Creates ProfileScreen component
   - Integrates API calls (GET /api/users/me)
   - Adds navigation
   - Writes E2E scenarios (markdown)
   - Outputs QA Handoff

5. QA: Tests with Mobile MCP
   - Launches app on iOS simulator
   - Navigates to profile screen
   - Tests edit functionality
   - Takes screenshots for validation
   - Verifies API integration
   - Creates gate file
```

## Environment Variables

```bash
# .env
API_BASE_URL=http://localhost:3000              # Backend API (dev)
# API_BASE_URL=http://192.168.1.100:3000        # Backend API (real device)
# API_BASE_URL=https://api.yourapp.com          # Backend API (production)

SUPABASE_URL=https://your-project.supabase.co   # If using Supabase directly
SUPABASE_ANON_KEY=your-anon-key-here            # If using Supabase directly
```

**For Real Device Testing**:
- Replace `localhost` with your computer's IP address
- Ensure device and computer on same WiFi network
- Backend must accept connections from local network

## BMad Integration

### Dev Agent Context

Update `.bmad-core/core-config.yaml`:
```yaml
devLoadAlwaysFiles:
  - docs/architecture/coding-standards.md
  - docs/architecture/tech-stack.md
  - docs/architecture/unified-project-structure.md
  - docs/architecture/mobile-patterns.md           # Mobile-specific patterns
  - .bmad-core/data/testing-stack-guide.md
```

### MCP Enhancement Example

**Traditional Mobile Flow** (30-40 min per story):
1. Write React Native code
2. Manually open simulator
3. Manually navigate to feature
4. Manually test interactions
5. Check backend API in Postman
6. Repeat for iOS and Android
7. Write test documentation

**MCP-Enhanced Flow** (10-15 min per story):
1. Write React Native code
2. Write E2E scenarios (markdown)
3. **Mobile MCP auto-tests on simulators**
4. **API Server MCP auto-verifies backend**
5. **Screenshots auto-captured**
6. Done

**Time Saved**: ~60-65% per story

## Troubleshooting

### Mobile MCP Not Working

**Issue**: Claude Code can't control simulator

**Solutions**:
1. Ensure Mobile MCP is configured in `.mcp.json`
2. Verify simulator is running: `xcrun simctl list` (iOS) or `adb devices` (Android)
3. Check MCP status: `/mcp` in Claude Code
4. Restart Claude Code
5. For real devices: Enable USB debugging (Android) or trust computer (iOS)

### API Connection Failed

**Issue**: Mobile app can't reach backend

**Solutions**:
1. Check backend is running: `curl http://localhost:3000/api/health`
2. For real devices: Use computer's IP, not `localhost`
3. Check `.env` file has correct `API_BASE_URL`
4. Verify CORS is configured on backend (allow mobile app origin)
5. Check firewall allows connections on backend port

### Expo Build Errors

**Issue**: Build fails with missing dependencies

**Solutions**:
1. Clear cache: `expo start --clear`
2. Delete `node_modules` and reinstall: `rm -rf node_modules && npm install`
3. Update Expo SDK: `expo upgrade`
4. Check `app.json` configuration
5. Use EAS Build instead of legacy Expo Build

### Simulator Not Launching

**Issue**: iOS simulator or Android emulator won't start

**Solutions**:
1. iOS: Open Xcode → Preferences → Components → Download simulators
2. Android: Open Android Studio → AVD Manager → Create virtual device
3. Check available devices: `xcrun simctl list` (iOS) or `emulator -list-avds` (Android)
4. Start manually before running `npm run ios/android`

## Backend Pairing Guide

### Choosing a Backend Stack

**For SaaS/Real-time Apps**: Next.js + Node.js + Supabase
- Built-in auth (email, OAuth, magic link)
- Real-time subscriptions (chat, notifications)
- File storage (user avatars, media)
- Best for: Social apps, dashboards, collaborative tools

**For ML/AI Apps**: Next.js + FastAPI + Supabase
- Python ecosystem (TensorFlow, PyTorch, scikit-learn)
- Same Supabase features as Node.js stack
- Best for: AI-powered apps, image recognition, recommendation engines

**For Document-Heavy Apps**: Next.js + Node.js + MongoDB
- Flexible schema (no migrations for rapid iteration)
- Good for: Content apps, CMS, document management

### Setting Up Backend MCP Integration

**Option 1: Separate Projects** (Recommended)
```bash
# Directory structure:
../my-mobile-app/          # React Native (this template)
../my-mobile-backend/      # Backend (fullstack template)

# Work on mobile:
cd ../my-mobile-app
# MCPs: mobile-mcp only

# Work on backend:
cd ../my-mobile-backend
# MCPs: supabase + api-server + shadcn-ui

# Work on fullstack features:
# Open two Claude Code windows (mobile + backend)
```

**Option 2: Monorepo** (Advanced)
```bash
# Directory structure:
my-app/
  ├── mobile/              # React Native
  ├── backend/             # API server
  ├── admin/               # Next.js admin dashboard
  └── .mcp.json            # All MCPs configured

# MCPs in root .mcp.json:
{
  "mobile-mcp": {...},      # Mobile testing
  "supabase": {...},        # Database
  "api-server": {...}       # Backend API
}
```

## Next Steps

1. **Create Backend Project**:
   ```bash
   cd ../
   npm run create-project nextjs-nodejs-supabase my-mobile-backend
   cd my-mobile-backend
   # Follow backend README
   ```

2. **Configure Backend for Mobile**:
   - Enable CORS for mobile app
   - Set up authentication (JWT or session)
   - Create mobile-specific API endpoints (/api/mobile/...)

3. **Update Mobile App**:
   - Set `API_BASE_URL` in `.env`
   - Implement authentication flow
   - Integrate backend API calls

4. **Start Development**:
   - Use SM agent to create stories
   - Use Dev agent with Mobile MCP for implementation
   - Leverage backend MCPs for database/API operations

## Resources

- React Native Docs: https://reactnative.dev/docs/getting-started
- Expo Docs: https://docs.expo.dev/
- React Navigation: https://reactnavigation.org/
- Supabase React Native: https://supabase.com/docs/guides/getting-started/tutorials/with-expo-react-native
- Mobile MCP: https://github.com/mobile-next/mobile-mcp
- BMad Guide: `.bmad-core/user-guide.md`
