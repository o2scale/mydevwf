# shadcn/ui Setup Guide for Project Templates

**Version**: 1.0
**Last Updated**: 2025-10-29
**Applies To**: All Next.js-based project templates (nodejs-supabase, nodejs-mongodb)

---

## Overview

All frontend projects use **shadcn/ui** as the standard component library:

- **Framework**: Next.js 14+ (App Router)
- **Styling**: Tailwind CSS 3.4+
- **Type Safety**: TypeScript
- **Component Library**: shadcn/ui (built on Radix UI primitives)
- **Philosophy**: Copy-paste components (not npm packages)

---

## Initial Project Setup

### 1. Prerequisites

Ensure your project has these installed:

```json
// package.json dependencies
{
  "next": "^14.0.0",
  "react": "^18.2.0",
  "react-dom": "^18.2.0",
  "typescript": "^5.0.0",
  "tailwindcss": "^3.4.0"
}
```

### 2. Initialize shadcn/ui

Run the initialization command in your project root:

```bash
npx shadcn@latest init
```

**Configuration Prompts**:
```
✔ Which style would you like to use? › New York
✔ Which color would you like to use as base color? › Zinc
✔ Would you like to use CSS variables for colors? › yes
✔ Where is your global CSS file? › app/globals.css
✔ Would you like to use React Server Components? › yes
✔ Write configuration to components.json? › Yes
```

This creates:
- `components.json` - shadcn/ui configuration
- `components/ui/` - Directory for shadcn components
- Updates `tailwind.config.ts` with shadcn theme
- Updates `app/globals.css` with CSS variables

### 3. Verify Installation

Check that `components.json` was created:

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "new-york",
  "rsc": true,
  "tsx": true,
  "tailwind": {
    "config": "tailwind.config.ts",
    "css": "app/globals.css",
    "baseColor": "zinc",
    "cssVariables": true,
    "prefix": ""
  },
  "aliases": {
    "components": "@/components",
    "utils": "@/lib/utils",
    "ui": "@/components/ui"
  }
}
```

---

## Adding Components

### Install Individual Components

```bash
# Core form components
npx shadcn@latest add button
npx shadcn@latest add input
npx shadcn@latest add label
npx shadcn@latest add form
npx shadcn@latest add select
npx shadcn@latest add checkbox
npx shadcn@latest add radio-group

# Data display components
npx shadcn@latest add table
npx shadcn@latest add card
npx shadcn@latest add badge
npx shadcn@latest add separator

# Feedback components
npx shadcn@latest add dialog
npx shadcn@latest add alert
npx shadcn@latest add toast
npx shadcn@latest add skeleton

# Navigation components
npx shadcn@latest add dropdown-menu
npx shadcn@latest add navigation-menu
npx shadcn@latest add tabs
```

### Install All Components at Once

```bash
npx shadcn@latest add --all
```

**⚠️ Recommendation**: Only install components you need to keep bundle size small.

---

## Component Usage

### Example: Button Component

After installation (`npx shadcn@latest add button`):

**File Created**: `components/ui/button.tsx`

**Usage**:
```tsx
import { Button } from "@/components/ui/button"

export function MyComponent() {
  return (
    <Button variant="default">Click me</Button>
  )
}
```

**Available Variants**:
- `default` - Primary button (blue background)
- `destructive` - Dangerous actions (red background)
- `outline` - Secondary button (border only)
- `secondary` - Tertiary button (gray background)
- `ghost` - No background (transparent)
- `link` - Text-style link with button behavior

**Available Sizes**:
- `default` - Standard size
- `sm` - Small button
- `lg` - Large button
- `icon` - Square button for icons only

### Example: Form Components

After installation (`npx shadcn@latest add form input label`):

**Usage**:
```tsx
"use client"

import { zodResolver } from "@hookform/resolvers/zod"
import { useForm } from "react-hook-form"
import * as z from "zod"

import { Button } from "@/components/ui/button"
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form"
import { Input } from "@/components/ui/input"

const formSchema = z.object({
  username: z.string().min(2, {
    message: "Username must be at least 2 characters.",
  }),
})

export function ProfileForm() {
  const form = useForm<z.infer<typeof formSchema>>({
    resolver: zodResolver(formSchema),
    defaultValues: {
      username: "",
    },
  })

  function onSubmit(values: z.infer<typeof formSchema>) {
    console.log(values)
  }

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-8">
        <FormField
          control={form.control}
          name="username"
          render={({ field }) => (
            <FormItem>
              <FormLabel>Username</FormLabel>
              <FormControl>
                <Input placeholder="shadcn" {...field} />
              </FormControl>
              <FormDescription>
                This is your public display name.
              </FormDescription>
              <FormMessage />
            </FormItem>
          )}
        />
        <Button type="submit">Submit</Button>
      </form>
    </Form>
  )
}
```

**Key Features**:
- Built on `react-hook-form` (excellent DX)
- Zod schema validation
- Accessible by default (ARIA attributes)
- Type-safe with TypeScript
- Error messages handled automatically

---

## Customization

### Theming with CSS Variables

shadcn/ui uses CSS variables for theming. Customize in `app/globals.css`:

```css
@layer base {
  :root {
    --background: 0 0% 100%;
    --foreground: 222.2 84% 4.9%;

    --card: 0 0% 100%;
    --card-foreground: 222.2 84% 4.9%;

    --popover: 0 0% 100%;
    --popover-foreground: 222.2 84% 4.9%;

    --primary: 222.2 47.4% 11.2%;
    --primary-foreground: 210 40% 98%;

    --secondary: 210 40% 96.1%;
    --secondary-foreground: 222.2 47.4% 11.2%;

    --muted: 210 40% 96.1%;
    --muted-foreground: 215.4 16.3% 46.9%;

    --accent: 210 40% 96.1%;
    --accent-foreground: 222.2 47.4% 11.2%;

    --destructive: 0 84.2% 60.2%;
    --destructive-foreground: 210 40% 98%;

    --border: 214.3 31.8% 91.4%;
    --input: 214.3 31.8% 91.4%;
    --ring: 222.2 84% 4.9%;

    --radius: 0.5rem;
  }

  .dark {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;

    --card: 222.2 84% 4.9%;
    --card-foreground: 210 40% 98%;

    --popover: 222.2 84% 4.9%;
    --popover-foreground: 210 40% 98%;

    --primary: 210 40% 98%;
    --primary-foreground: 222.2 47.4% 11.2%;

    --secondary: 217.2 32.6% 17.5%;
    --secondary-foreground: 210 40% 98%;

    --muted: 217.2 32.6% 17.5%;
    --muted-foreground: 215 20.2% 65.1%;

    --accent: 217.2 32.6% 17.5%;
    --accent-foreground: 210 40% 98%;

    --destructive: 0 62.8% 30.6%;
    --destructive-foreground: 210 40% 98%;

    --border: 217.2 32.6% 17.5%;
    --input: 217.2 32.6% 17.5%;
    --ring: 212.7 26.8% 83.9%;
  }
}
```

### Modifying Components

Since components are copy-pasted, you own the code:

**Example: Custom Button Variant**:

```tsx
// components/ui/button.tsx
const buttonVariants = cva(
  "inline-flex items-center justify-center rounded-md text-sm font-medium",
  {
    variants: {
      variant: {
        default: "bg-primary text-primary-foreground",
        destructive: "bg-destructive text-destructive-foreground",
        outline: "border border-input bg-background",
        // ADD YOUR CUSTOM VARIANT HERE:
        gradient: "bg-gradient-to-r from-purple-500 to-pink-500 text-white",
      },
    },
  }
)
```

**Usage**:
```tsx
<Button variant="gradient">Fancy Button</Button>
```

---

## Dark Mode Setup

shadcn/ui supports dark mode out of the box. Use `next-themes`:

### 1. Install next-themes

```bash
npm install next-themes
```

### 2. Create Theme Provider

```tsx
// components/theme-provider.tsx
"use client"

import * as React from "react"
import { ThemeProvider as NextThemesProvider } from "next-themes"
import { type ThemeProviderProps } from "next-themes/dist/types"

export function ThemeProvider({ children, ...props }: ThemeProviderProps) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>
}
```

### 3. Wrap App with Provider

```tsx
// app/layout.tsx
import { ThemeProvider } from "@/components/theme-provider"

export default function RootLayout({ children }: { children: React.Node }) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body>
        <ThemeProvider
          attribute="class"
          defaultTheme="system"
          enableSystem
          disableTransitionOnChange
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  )
}
```

### 4. Add Theme Toggle

```tsx
// components/theme-toggle.tsx
"use client"

import * as React from "react"
import { Moon, Sun } from "lucide-react"
import { useTheme } from "next-themes"

import { Button } from "@/components/ui/button"

export function ThemeToggle() {
  const { setTheme, theme } = useTheme()

  return (
    <Button
      variant="ghost"
      size="icon"
      onClick={() => setTheme(theme === "light" ? "dark" : "light")}
    >
      <Sun className="h-[1.2rem] w-[1.2rem] rotate-0 scale-100 transition-all dark:-rotate-90 dark:scale-0" />
      <Moon className="absolute h-[1.2rem] w-[1.2rem] rotate-90 scale-0 transition-all dark:rotate-0 dark:scale-100" />
      <span className="sr-only">Toggle theme</span>
    </Button>
  )
}
```

---

## Common Patterns

### Loading States

```tsx
import { Button } from "@/components/ui/button"
import { Loader2 } from "lucide-react"

<Button disabled>
  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
  Please wait
</Button>
```

### Toast Notifications

```bash
npx shadcn@latest add toast
```

```tsx
"use client"

import { useToast } from "@/components/ui/use-toast"
import { Button } from "@/components/ui/button"

export function ToastDemo() {
  const { toast } = useToast()

  return (
    <Button
      onClick={() => {
        toast({
          title: "Scheduled: Catch up",
          description: "Friday, February 10, 2023 at 5:57 PM",
        })
      }}
    >
      Show Toast
    </Button>
  )
}
```

### Confirmation Dialogs

```tsx
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import { Button } from "@/components/ui/button"

export function ConfirmDialog() {
  return (
    <AlertDialog>
      <AlertDialogTrigger asChild>
        <Button variant="destructive">Delete Account</Button>
      </AlertDialogTrigger>
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
          <AlertDialogDescription>
            This action cannot be undone. This will permanently delete your
            account and remove your data from our servers.
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel>Cancel</AlertDialogCancel>
          <AlertDialogAction>Continue</AlertDialogAction>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  )
}
```

---

## Accessibility

shadcn/ui components are accessible by default (built on Radix UI):

### ✅ What's Included

- Proper ARIA attributes
- Keyboard navigation
- Focus management
- Screen reader support
- High contrast mode support

### ⚠️ Your Responsibility

- Provide meaningful labels
- Add alt text to images
- Ensure color contrast ratios (4.5:1 minimum)
- Test with keyboard only
- Test with screen readers

---

## Resources

- **Official Docs**: https://ui.shadcn.com
- **Component Catalog**: https://ui.shadcn.com/docs/components
- **Blocks (pre-built sections)**: https://ui.shadcn.com/blocks
- **Themes**: https://ui.shadcn.com/themes
- **GitHub**: https://github.com/shadcn-ui/ui
- **Radix UI** (underlying primitives): https://www.radix-ui.com

---

## Troubleshooting

### Issue: Components not found

**Cause**: Path alias not configured

**Fix**: Check `tsconfig.json`:
```json
{
  "compilerOptions": {
    "baseUrl": ".",
    "paths": {
      "@/*": ["./*"]
    }
  }
}
```

### Issue: Styles not applied

**Cause**: Tailwind not configured correctly

**Fix**: Check `tailwind.config.ts`:
```ts
import type { Config } from "tailwindcss"

const config: Config = {
  darkMode: ["class"],
  content: [
    "./pages/**/*.{ts,tsx}",
    "./components/**/*.{ts,tsx}",
    "./app/**/*.{ts,tsx}",
    "./src/**/*.{ts,tsx}",
  ],
  // ... shadcn theme config
}
```

### Issue: Type errors

**Cause**: Missing dependencies

**Fix**:
```bash
npm install -D @types/node @types/react @types/react-dom
```

---

## Checklist for New Projects

- [ ] Next.js 14+ installed
- [ ] Tailwind CSS configured
- [ ] TypeScript configured
- [ ] Run `npx shadcn@latest init`
- [ ] Verify `components.json` created
- [ ] Install core components (button, form, input, etc.)
- [ ] Set up dark mode (optional)
- [ ] Configure theme colors in `globals.css`
- [ ] Test component imports work
- [ ] Document component decisions in `docs/front-end-spec.md`

---

**Next Steps**: After setup, UX Expert will specify which components to use in `docs/front-end-spec.md`, and Dev agents will install and implement them as needed.
