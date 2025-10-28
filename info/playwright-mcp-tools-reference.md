# Playwright MCP Tools Reference Guide

**Version:** 2.0
**Last Updated:** October 13, 2025
**Purpose:** Complete reference for all Playwright MCP tools available to QA Agents
**Tested:** Live on https://linuxmint.com/edition.php?id=323
**Source:** microsoft/playwright-mcp + Simon Willison's TILs

---

## Overview

**Playwright MCP** provides programmatic browser control through Model Context Protocol (MCP) tools. QA Agents use these tools to **automate browser navigation while manually observing and verifying behavior**.

### Installation

To enable Playwright MCP in Claude Code:

```bash
claude mcp add playwright npx '@playwright/mcp@latest'
```

This command:
- ✅ Enables all 26 Playwright MCP tools
- ✅ Persists configuration for the current directory
- ✅ Opens a visible Chrome browser window when used

**First use:** Explicitly say "playwright mcp" to avoid Bash tool confusion
**Authentication:** Login manually in visible browser - cookies persist for session

### Key Concepts

**Hybrid Testing Approach:**
- ✅ **Automated:** Browser navigation, interaction, screenshot capture
- ✅ **Manual:** Observation, verification, decision-making (PASS/FAIL)
- ✅ **Evidence:** Screenshots, console logs, page snapshots
- ✅ **Visible Browser:** Chrome window opens in front of you (not headless)

**NOT:**
- ❌ Fully automated testing with `.spec.js` files
- ❌ Pure manual testing by opening browser and clicking
- ❌ Running `npx playwright test` commands

**Key Advantage:**
Since the browser is visible, authentication is easy - have Claude show you a login page, then login yourself with your own credentials. Cookies persist for the session duration.

---

## Complete MCP Tools List

**Total Tools:** 26 (all available in microsoft/playwright-mcp)

**Tool Categories:**
- Navigation (3 tools): navigate, navigate_back, navigate_forward
- Page Inspection (3 tools): snapshot, console_messages, take_screenshot
- Interaction (7 tools): click, type, fill_form, select_option, hover, drag, press_key
- Utility (5 tools): wait_for, resize, evaluate, handle_dialog, file_upload
- Advanced (3 tools): network_requests, close, install
- Tab Management (4 tools): tab_list, tab_new, tab_select, tab_close
- PDF & Code Generation (2 tools): pdf_save, generate_playwright_test

**All Tools List (alphabetical):**
1. browser_click
2. browser_close
3. browser_console_messages
4. browser_drag
5. browser_evaluate
6. browser_file_upload
7. browser_generate_playwright_test
8. browser_handle_dialog
9. browser_hover
10. browser_install
11. browser_navigate
12. browser_navigate_back
13. browser_navigate_forward
14. browser_network_requests
15. browser_pdf_save
16. browser_press_key
17. browser_resize
18. browser_select_option
19. browser_snapshot
20. browser_tab_close
21. browser_tab_list
22. browser_tab_new
23. browser_tab_select
24. browser_take_screenshot
25. browser_type
26. browser_wait_for

### Navigation Tools

#### 1. `browser_navigate`
**Purpose:** Navigate to any URL

**Parameters:**
- `url` (required): The URL to navigate to

**Example:**
```
browser_navigate(url="http://localhost:3000")
```

**Returns:**
- Page URL
- Page title
- Page snapshot (accessibility tree)

**Use Cases:**
- Navigate to frontend application
- Navigate between pages
- Load specific features

---

#### 2. `browser_navigate_back`
**Purpose:** Go back to previous page

**Parameters:** None

**Example:**
```
browser_navigate_back()
```

**Use Cases:**
- Test navigation flow
- Verify browser history works
- Return to previous page

---

#### 3. `browser_navigate_forward` (NEW)
**Purpose:** Go forward to next page in history

**Parameters:** None

**Example:**
```
browser_navigate_forward()
```

**Use Cases:**
- Navigate forward after going back
- Test browser history navigation
- Return to page after stepping back

---

### Page Inspection Tools

#### 3. `browser_snapshot`
**Purpose:** Get complete page structure (accessibility tree)

**Parameters:** None

**Example:**
```
browser_snapshot()
```

**Returns:**
- Complete DOM structure as YAML
- All elements with reference IDs (e.g., ref="e45")
- Element types (button, link, input, etc.)
- Element labels and text content
- Clickable elements with URLs

**Use Cases:**
- See what elements are on the page
- Get element references for interaction
- Verify expected elements exist
- Check page structure

**Example Output:**
```yaml
- button "Login" [ref=e45] [cursor=pointer]
- input "username" [ref=e12]
- link "Forgot Password" [ref=e23] [cursor=pointer]
  /url: /forgot-password
```

---

#### 4. `browser_console_messages`
**Purpose:** Get all console logs and errors

**Parameters:**
- `onlyErrors` (optional): If true, only return error messages

**Example:**
```
browser_console_messages()
browser_console_messages(onlyErrors=true)
```

**Returns:**
- All console.log, console.warn, console.error messages
- Timestamps
- Source file locations

**Use Cases:**
- Check for JavaScript errors
- Verify no unexpected warnings
- Debug issues
- Quality gate evidence (no console errors = PASS)

---

#### 5. `browser_take_screenshot`
**Purpose:** Capture visual evidence

**Parameters:**
- `filename` (optional): Name for screenshot file
- `type` (optional): "png" or "jpeg" (default: png)
- `fullPage` (optional): If true, captures entire scrollable page
- `element` (optional): Element description to screenshot
- `ref` (optional): Element reference to screenshot

**Examples:**
```
browser_take_screenshot(filename="login-page.png")
browser_take_screenshot(filename="mobile-view.png", type="png")
browser_take_screenshot(filename="full-page.png", fullPage=true)
browser_take_screenshot(element="product grid", ref="e67", filename="grid.png")
```

**Returns:**
- File path where screenshot was saved
- Visual preview in chat

**Use Cases:**
- Capture test evidence
- Document UI state
- Compare before/after
- Visual regression testing

**Saved Location:** `.playwright-mcp/{filename}`

---

### Interaction Tools

#### 6. `browser_click`
**Purpose:** Click buttons, links, or elements

**Parameters:**
- `element` (required): Human-readable description
- `ref` (required): Element reference from snapshot
- `button` (optional): "left", "right", "middle" (default: left)
- `doubleClick` (optional): If true, performs double click
- `modifiers` (optional): Keys to hold (Alt, Control, Shift, etc.)

**Examples:**
```
browser_click(element="Login button", ref="e45")
browser_click(element="Product card", ref="e67", doubleClick=true)
browser_click(element="Context menu item", ref="e89", button="right")
```

**Use Cases:**
- Click buttons
- Click links
- Click menu items
- Select items

---

#### 7. `browser_type`
**Purpose:** Type text into input fields

**Parameters:**
- `element` (required): Human-readable description
- `ref` (required): Element reference from snapshot
- `text` (required): Text to type
- `slowly` (optional): If true, types one character at a time
- `submit` (optional): If true, presses Enter after typing

**Examples:**
```
browser_type(element="username field", ref="e12", text="test_student")
browser_type(element="search box", ref="e34", text="laptop", submit=true)
browser_type(element="comment field", ref="e56", text="Great product!", slowly=true)
```

**Use Cases:**
- Fill form fields
- Enter search queries
- Type comments
- Enter credentials

---

#### 8. `browser_fill_form`
**Purpose:** Fill multiple form fields at once

**Parameters:**
- `fields` (required): Array of field objects with:
  - `name`: Human-readable field name
  - `ref`: Element reference
  - `type`: "textbox", "checkbox", "radio", "combobox", "slider"
  - `value`: Value to set

**Example:**
```
browser_fill_form(fields=[
  {name: "username", ref: "e12", type: "textbox", value: "test_student"},
  {name: "password", ref: "e13", type: "textbox", value: "password123"},
  {name: "remember me", ref: "e14", type: "checkbox", value: "true"}
])
```

**Use Cases:**
- Fill login forms quickly
- Fill registration forms
- Fill checkout forms
- Batch data entry

---

#### 9. `browser_select_option`
**Purpose:** Select options from dropdown menus

**Parameters:**
- `element` (required): Human-readable description
- `ref` (required): Element reference
- `values` (required): Array of values to select

**Examples:**
```
browser_select_option(element="category dropdown", ref="e45", values=["Electronics"])
browser_select_option(element="size", ref="e67", values=["Large", "Extra Large"])
```

**Use Cases:**
- Select from dropdowns
- Multi-select lists
- Category filters
- Size/color selection

---

#### 10. `browser_hover`
**Purpose:** Hover mouse over elements

**Parameters:**
- `element` (required): Human-readable description
- `ref` (required): Element reference

**Example:**
```
browser_hover(element="product card", ref="e45")
```

**Use Cases:**
- Trigger hover effects
- Show tooltips
- Reveal hidden menus
- Test CSS :hover states

---

#### 11. `browser_drag`
**Purpose:** Drag and drop between elements

**Parameters:**
- `startElement` (required): Source element description
- `startRef` (required): Source element reference
- `endElement` (required): Target element description
- `endRef` (required): Target element reference

**Example:**
```
browser_drag(
  startElement="product card",
  startRef="e45",
  endElement="shopping cart",
  endRef="e67"
)
```

**Use Cases:**
- Drag-and-drop interfaces
- Reorder lists
- Move items between containers
- File uploads via drag

---

### Utility Tools

#### 12. `browser_wait_for`
**Purpose:** Wait for text to appear/disappear or time to pass

**Parameters:**
- `text` (optional): Text to wait for to appear
- `textGone` (optional): Text to wait for to disappear
- `time` (optional): Time to wait in seconds

**Examples:**
```
browser_wait_for(text="Welcome")
browser_wait_for(textGone="Loading...")
browser_wait_for(time=5)
```

**Use Cases:**
- Wait for page load
- Wait for API responses
- Wait for animations
- Prevent timing issues

---

#### 13. `browser_resize`
**Purpose:** Change browser window size for responsive testing

**Parameters:**
- `width` (required): Width in pixels
- `height` (required): Height in pixels

**Examples:**
```
browser_resize(width=375, height=667)   # iPhone
browser_resize(width=768, height=1024)  # iPad
browser_resize(width=1920, height=1080) # Desktop
```

**Use Cases:**
- Test mobile layouts
- Test tablet layouts
- Test responsive design
- Verify breakpoints

**Common Sizes:**
- Mobile: 375x667 (iPhone)
- Tablet: 768x1024 (iPad)
- Desktop: 1920x1080 (Full HD)

---

#### 14. `browser_evaluate`
**Purpose:** Execute custom JavaScript in browser context

**Parameters:**
- `function` (required): JavaScript function as string
- `element` (optional): Element description
- `ref` (optional): Element reference

**Examples:**
```
browser_evaluate(function="() => document.title")
browser_evaluate(function="() => window.innerWidth")
browser_evaluate(
  function="(element) => element.textContent",
  element="price label",
  ref="e45"
)
```

**Use Cases:**
- Get computed values
- Check JavaScript state
- Custom verifications
- Access global variables

---

#### 15. `browser_handle_dialog`
**Purpose:** Handle alert/confirm/prompt dialogs

**Parameters:**
- `accept` (required): true to accept, false to dismiss
- `promptText` (optional): Text for prompt dialogs

**Examples:**
```
browser_handle_dialog(accept=true)
browser_handle_dialog(accept=false)
browser_handle_dialog(accept=true, promptText="Confirmed")
```

**Use Cases:**
- Accept confirmations
- Dismiss alerts
- Respond to prompts
- Test dialog behavior

---

### Advanced Tools

#### 16. `browser_network_requests`
**Purpose:** Get all network requests since page load

**Parameters:** None

**Example:**
```
browser_network_requests()
```

**Returns:**
- All HTTP requests
- URLs, methods, status codes
- Request/response headers
- Timing information

**Use Cases:**
- Verify API calls made
- Check request parameters
- Debug network issues
- Performance analysis

---

#### 17. `browser_file_upload`
**Purpose:** Upload files to file input elements

**Parameters:**
- `paths` (optional): Array of absolute file paths

**Example:**
```
browser_file_upload(paths=["D:\\test-data\\image.png"])
```

**Use Cases:**
- Test file upload features
- Upload images
- Upload documents
- Bulk upload testing

---

#### 18. `browser_tabs`
**Purpose:** Manage browser tabs

**Parameters:**
- `action` (required): "list", "new", "close", "select"
- `index` (optional): Tab index for close/select

**Examples:**
```
browser_tabs(action="list")
browser_tabs(action="new")
browser_tabs(action="select", index=0)
browser_tabs(action="close", index=1)
```

**Use Cases:**
- Open new tabs
- Switch between tabs
- Close tabs
- Multi-tab testing

---

#### 19. `browser_close`
**Purpose:** Close the browser

**Parameters:** None

**Example:**
```
browser_close()
```

**Use Cases:**
- Clean up after testing
- Reset browser state
- End test session

---

### Tab Management Tools

#### 20. `browser_tab_list` (NEW)
**Purpose:** List all open browser tabs

**Parameters:** None

**Example:**
```
browser_tab_list()
```

**Returns:**
- List of all open tabs with IDs and titles

**Use Cases:**
- See what tabs are currently open
- Get tab IDs for switching
- Debug multi-tab scenarios

---

#### 21. `browser_tab_new` (NEW)
**Purpose:** Open a new browser tab

**Parameters:** None

**Example:**
```
browser_tab_new()
```

**Use Cases:**
- Open new tab for testing
- Test multi-tab workflows
- Parallel test execution

---

#### 22. `browser_tab_select` (NEW)
**Purpose:** Switch to a specific tab

**Parameters:**
- `index` (required): Tab index to switch to

**Example:**
```
browser_tab_select(index=0)
browser_tab_select(index=2)
```

**Use Cases:**
- Switch between tabs during testing
- Test cross-tab interactions
- Multi-window workflows

---

#### 23. `browser_tab_close` (NEW)
**Purpose:** Close a specific tab

**Parameters:**
- `index` (optional): Tab index to close (if omitted, closes current tab)

**Example:**
```
browser_tab_close(index=1)
browser_tab_close()  # Close current tab
```

**Use Cases:**
- Clean up tabs after testing
- Test tab close behavior
- Memory cleanup

---

### PDF & Installation Tools

#### 24. `browser_pdf_save` (NEW)
**Purpose:** Save current page as PDF

**Parameters:**
- `filename` (optional): Name for PDF file

**Example:**
```
browser_pdf_save(filename="test-report.pdf")
```

**Returns:**
- Path to saved PDF file

**Use Cases:**
- Generate PDF reports
- Save page for documentation
- Export test evidence
- Capture printable version

---

#### 25. `browser_install` (NEW)
**Purpose:** Install Playwright browser if not present

**Parameters:** None

**Example:**
```
browser_install()
```

**Use Cases:**
- First-time setup
- Fix missing browser errors
- Ensure browser is installed

**Note:** Call this if you get "browser not installed" errors

---

#### 26. `browser_generate_playwright_test` (NEW)
**Purpose:** Generate Playwright test code from current session

**Parameters:** None

**Example:**
```
browser_generate_playwright_test()
```

**Returns:**
- Generated Playwright test code (.spec.js format)

**Use Cases:**
- Convert manual test session to code
- Create automated test scaffold
- Learn Playwright test syntax
- Generate regression tests

**Note:** While useful for learning, your workflow uses test SCENARIOS (markdown), not code

---

### Keyboard Input Tools

#### `browser_press_key` (included in browser_type)
**Purpose:** Press specific keyboard keys

**Parameters:**
- `key` (required): Key name (e.g., "Enter", "Escape", "ArrowDown")

**Example:**
```
browser_press_key(key="Enter")
browser_press_key(key="Escape")
browser_press_key(key="Tab")
```

**Use Cases:**
- Press Enter to submit
- Press Escape to cancel
- Navigate with arrow keys
- Test keyboard shortcuts

---

## Common Testing Workflows

### Workflow 1: Login and Navigate

```
Step 1: Navigate to app
  → browser_navigate("http://localhost:3000")

Step 2: Get page structure
  → browser_snapshot()
  → Find login button ref (e.g., ref="e45")

Step 3: Click login button
  → browser_click(element="Login button", ref="e45")

Step 4: Fill credentials
  → browser_type(element="username", ref="e12", text="test_student")
  → browser_type(element="password", ref="e13", text="password123")

Step 5: Submit
  → browser_click(element="Submit button", ref="e23")

Step 6: Wait for success
  → browser_wait_for(text="Welcome")

Step 7: Verify no errors
  → browser_console_messages()

Step 8: Capture evidence
  → browser_take_screenshot("login-success.png")
```

---

### Workflow 2: Verify UI Element Exists

```
Step 1: Navigate to page
  → browser_navigate("http://localhost:3000/shop")

Step 2: Get page structure
  → browser_snapshot()

Step 3: Check snapshot output
  → Look for expected element (e.g., "Product grid")
  → Verify element exists with correct label/text

Step 4: Capture evidence
  → browser_take_screenshot("shop-page.png")

Step 5: Document result
  → PASS: Product grid found at ref="e67"
  → FAIL: Product grid not found in snapshot
```

---

### Workflow 3: Test Form Submission

```
Step 1: Navigate to form
  → browser_navigate("http://localhost:3000/checkout")

Step 2: Fill form
  → browser_fill_form(fields=[
      {name: "name", ref: "e12", type: "textbox", value: "John Doe"},
      {name: "email", ref: "e13", type: "textbox", value: "john@example.com"},
      {name: "agree", ref: "e14", type: "checkbox", value: "true"}
    ])

Step 3: Submit
  → browser_click(element="Submit", ref="e45")

Step 4: Wait for confirmation
  → browser_wait_for(text="Order Confirmed")

Step 5: Check console
  → browser_console_messages()
  → Verify no errors

Step 6: Capture evidence
  → browser_take_screenshot("order-confirmation.png")
```

---

### Workflow 4: Test Responsive Design

```
Step 1: Navigate to page
  → browser_navigate("http://localhost:3000")

Step 2: Desktop view
  → browser_resize(1920, 1080)
  → browser_take_screenshot("desktop-view.png")
  → browser_snapshot() → verify 4-column grid

Step 3: Tablet view
  → browser_resize(768, 1024)
  → browser_take_screenshot("tablet-view.png")
  → browser_snapshot() → verify 2-column grid

Step 4: Mobile view
  → browser_resize(375, 667)
  → browser_take_screenshot("mobile-view.png")
  → browser_snapshot() → verify 1-column grid

Step 5: Document results
  → PASS: All breakpoints work correctly
```

---

### Workflow 5: Test Error Handling

```
Step 1: Navigate to page
  → browser_navigate("http://localhost:3000/shop")

Step 2: Simulate error (stop backend server)
  → Ask Dev Agent to stop backend

Step 3: Trigger action
  → browser_click(element="Add to Cart", ref="e45")

Step 4: Wait for error message
  → browser_wait_for(text="Network error")

Step 5: Check console
  → browser_console_messages()
  → Verify error logged correctly

Step 6: Capture evidence
  → browser_take_screenshot("error-state.png")

Step 7: Verify error handling
  → PASS: Error message displayed
  → PASS: No crash
  → PASS: User can retry
```

---

## Best Practices

### For QA Agents

1. **Always run browser_snapshot() first**
   - See page structure before interacting
   - Get element references
   - Verify expected elements exist

2. **Check console after every major action**
   - browser_console_messages() after navigation
   - browser_console_messages() after form submission
   - browser_console_messages() after errors

3. **Take screenshots liberally**
   - Before and after each test case
   - At key points in workflow
   - When errors occur
   - For responsive testing

4. **Use browser_wait_for() to prevent timing issues**
   - Wait for text to appear after actions
   - Wait for loading indicators to disappear
   - Don't assume instant responses

5. **Test responsive behavior systematically**
   - Always test mobile, tablet, desktop
   - Use standard viewport sizes
   - Capture screenshot at each size

6. **Document everything**
   - Which tools you used
   - What you observed
   - Screenshots as evidence
   - Console errors (if any)

---

## Troubleshooting

### Problem: Element ref not found
**Cause:** Page structure changed since snapshot
**Solution:** Run browser_snapshot() again to get updated refs

### Problem: Click doesn't work
**Cause:** Element not yet loaded or wrong ref
**Solution:** Use browser_wait_for() before clicking, verify ref from snapshot

### Problem: Screenshot is blank
**Cause:** Page not fully loaded
**Solution:** Use browser_wait_for() before screenshot, or set fullPage=true

### Problem: Console messages empty
**Cause:** Browser restarted or page reloaded
**Solution:** Console messages are cleared on navigation, check immediately after action

### Problem: Can't find element in snapshot
**Cause:** Element hidden, in iframe, or dynamic
**Solution:** Interact with page first (scroll, click), then snapshot again

---

## Appendix: Element Reference Format

**From browser_snapshot():**
```yaml
- button "Login" [ref=e45] [cursor=pointer]
```

**To use in browser_click():**
```
browser_click(element="Login", ref="e45")
```

**Note:**
- `element` = Human-readable description (for permission/logging)
- `ref` = Exact reference from snapshot (for targeting)
- Both are required for interaction tools

---

## Related Documents

- `.ai/bmad-playwright-workflow.md` - Complete BMAD workflow
- `.ai/workflow-quick-reference.md` - Quick reference cheat sheet
- `.ai/qa-onboarding-guide.md` - QA Agent onboarding
- `.ai/playwright-mcp-capabilities-report.md` - Live testing results

---

**Version:** 2.0
**Last Updated:** October 13, 2025
**Maintained By:** BMad Orchestrator
**Tested Live:** ✅ Yes - Linux Mint page navigation successful
**Total Tools:** 26 (7 new tools added: navigate_forward, tab_list, tab_new, tab_select, tab_close, pdf_save, install, generate_playwright_test)
**Source:** microsoft/playwright-mcp official MCP server + Simon Willison's TILs
