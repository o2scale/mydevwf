# Navigation Guide: {Project Name}

**Living Document** - Updated by Dev agent after each user-facing feature implementation
**Purpose**: Cumulative map of all UI features, navigation paths, and user journeys
**Last Updated**: {YYYY-MM-DD HH:MM:SS} (Story {epic}.{story})

---

## Overview

This living document tracks all user-facing features, navigation elements, and user journeys implemented across stories. It provides cumulative UI context for QA testing and prevents missing navigation integration.

**Key Principle**: Every user-facing feature must be accessible through at least 2-3 entry points (menus, contextual links, breadcrumbs).

---

## Navigation Structure

### Primary Navigation (Top Menu)

```
Example:
├── Dashboard
├── Projects
│   ├── All Projects
│   ├── Active Projects
│   └── Archived Projects
├── Settings
│   ├── Profile
│   ├── Account
│   └── Preferences
└── Help
```

**Current Navigation**:
```
(Update this section after each story with new menu items)
```

### Secondary Navigation (Sidebar/Context Menu)

```
Example:
Project Detail Page:
├── Overview
├── Tasks
├── Team
├── Files
└── Settings
```

**Current Secondary Navigation**:
```
(Update this section for context-specific navigation)
```

---

## Feature Catalog

### Feature: {Feature Name}

**Story**: {epic}.{story} - {Story Name}
**Added**: {YYYY-MM-DD}
**Status**: ✅ Implemented | 🚧 In Progress | ⏸️ On Hold

#### Navigation Entry Points

1. **Primary Entry Point**: {Menu Name} → {Submenu} → {Feature}
   - Label: "{Exact Menu Label}"
   - Icon: {icon-name} (if applicable)
   - Position: {Position in menu, e.g., "3rd item under Projects"}
   - Route: `/path/to/feature`

2. **Secondary Entry Point**: {Contextual location}
   - Context: "{Where users can access this feature}"
   - Trigger: {Button/Link/Action}
   - Route: `/path/to/feature`

3. **Tertiary Entry Point** (if applicable): {Additional access path}
   - Context: "{Where/how}"
   - Route: `/path/to/feature`

#### Breadcrumb Hierarchy

```
Home > {Parent Section} > {Current Page}

Example:
Home > Projects > Project Detail > Tasks
```

#### User Journey

**Typical Flow**:
```
1. User starts at: {Starting point}
2. User navigates to: {Next step}
3. User performs action: {Action}
4. User sees result: {Outcome}
```

**Alternative Flows**:
```
(Document 2-3 alternative ways users might reach this feature)
```

#### Contextual Links

Features that link TO this feature:
- {Feature A} → Links to this feature via {action/button}
- {Feature B} → Links to this feature via {action/button}

Features that this feature links TO:
- This feature → Links to {Feature X} via {action/button}
- This feature → Links to {Feature Y} via {action/button}

#### Related Features

- {Related Feature 1}: {Brief description of relationship}
- {Related Feature 2}: {Brief description of relationship}

---

## User Journey Maps

### Journey: {User Goal, e.g., "Upload and Transcribe Media"}

**Stories Involved**: {1.1}, {2.3}, {3.10}
**Updated**: {YYYY-MM-DD}

**Complete Flow**:
```
1. [Story 1.1] User uploads file via Upload Center
   └─ Route: /upload
   └─ Menu: Media > Upload Center

2. [Story 2.3] User views uploaded files in Media Tab
   └─ Route: /media
   └─ Menu: Media > Media Library
   └─ Contextual Link: Upload Center → "View in Media Library"

3. [Story 3.10] User starts transcription from Media Tab
   └─ Route: /media/{fileId}/transcribe
   └─ Menu: Media > Media Library > [Select File] > "Start Transcription"
   └─ Contextual Link: File Detail → "Transcribe"
```

**Entry Points for This Journey**:
- Primary: Media > Upload Center → Start journey
- Secondary: Media > Media Library → Start at step 2
- Tertiary: Dashboard > Recent Uploads → Quick access to step 2

---

## Page Inventory

### Page: {Page Name}

**Route**: `/path/to/page`
**Story**: {epic}.{story}
**Added**: {YYYY-MM-DD}

**Access Methods**:
- Menu: {Menu path}
- Direct Link: {URL}
- Contextual Links: {List of pages that link here}

**Key Actions Available**:
- {Action 1}: {Description}
- {Action 2}: {Description}

**Navigation FROM This Page**:
- Links to: {Page A, Page B, Page C}
- Actions that navigate: {Action → Destination}

---

## Testing Reference

### Quick Navigation Tests

For each new feature, QA should verify:

1. **Menu Access**: Feature accessible from primary menu ✓
2. **Breadcrumbs**: Correct breadcrumb hierarchy displayed ✓
3. **Contextual Links**: All related pages link to feature ✓
4. **Back Navigation**: Users can return to previous page ✓
5. **Direct URL**: Feature accessible via direct URL ✓

### Common Navigation Issues

Track recurring navigation problems:

- **Issue**: {Description}
  - **Story**: {epic}.{story}
  - **Resolution**: {How it was fixed}
  - **Prevention**: {How to avoid in future}

---

## Update Protocol

### When to Update This Guide

Dev agent MUST update this guide after implementing:
- New user-facing page/feature
- New menu item or navigation element
- New user journey or workflow
- Changes to existing navigation structure

### Update Checklist

After implementing user-facing feature in story {epic}.{story}:

- [ ] Add feature to Feature Catalog
- [ ] Document all navigation entry points (minimum 2-3)
- [ ] Update primary/secondary navigation structure
- [ ] Add breadcrumb hierarchy
- [ ] Document user journey (typical + alternative flows)
- [ ] Add contextual links (TO and FROM this feature)
- [ ] Update relevant User Journey Maps
- [ ] Add page to Page Inventory
- [ ] Add timestamp and story reference
- [ ] Include Navigation Guide update in QA Handoff

### Update Format

```markdown
**[YYYY-MM-DD HH:MM:SS] Story {epic}.{story} - {Feature Name}**

Added:
- Menu item: {Menu path}
- Page: {Route}
- User journey: {Brief description}
- Contextual links: {From X to Y}
```

---

## QA Testing Guide

### Using This Guide for E2E Testing

**Before Writing Test Scenarios**:
1. Read this guide to understand all existing UI features
2. Identify all navigation entry points for feature under test
3. Verify user journeys documented here
4. Check contextual links exist as documented

**Example**: Testing Story 3.10 (Start Transcription)
```
Step 1: Check Feature Catalog → "Start Transcription" feature
Step 2: Verify 3 entry points documented (Menu, Media Tab, File Detail)
Step 3: Check User Journey Map → "Upload and Transcribe Media"
Step 4: Test all documented entry points in E2E scenarios
```

### Navigation Coverage Requirements

Every test scenario should verify:
- ✅ Primary entry point (menu/direct link)
- ✅ Breadcrumb navigation
- ✅ At least 1 contextual entry point
- ✅ Back navigation works correctly

---

## Maintenance Notes

### Document Health

- **Completeness**: All user-facing features documented? {Yes/No}
- **Accuracy**: Navigation matches current implementation? {Yes/No}
- **Last Audit**: {YYYY-MM-DD}

### Known Gaps

Document any incomplete navigation integration:

- **Story {epic}.{story}**: {Feature name}
  - **Gap**: {Description of missing navigation}
  - **Impact**: {How this affects UX}
  - **Planned Fix**: {When/how to address}

---

## Example Entry (Template)

### Feature: Media Upload Center

**Story**: 1.1 - Media Upload Center
**Added**: 2025-11-26
**Status**: ✅ Implemented

#### Navigation Entry Points

1. **Primary Entry Point**: Media → Upload Center
   - Label: "Upload Center"
   - Icon: upload-cloud
   - Position: 1st item under Media menu
   - Route: `/media/upload`

2. **Secondary Entry Point**: Dashboard → Quick Actions
   - Context: "Quick Action widget on dashboard"
   - Trigger: "Upload Media" button
   - Route: `/media/upload`

3. **Tertiary Entry Point**: Media Library → Empty State
   - Context: "When no media files exist, empty state shows 'Upload Files' CTA"
   - Route: `/media/upload`

#### Breadcrumb Hierarchy

```
Home > Media > Upload Center
```

#### User Journey

**Typical Flow**:
```
1. User starts at: Dashboard or Media menu
2. User navigates to: Upload Center
3. User performs action: Drag & drop or select files
4. User sees result: Upload progress, then redirect to Media Library
```

**Alternative Flows**:
```
Flow 2: Dashboard Quick Action → Upload Center → Upload → Stay on Upload Center for bulk upload
Flow 3: Media Library Empty State → Upload Center → Upload → Auto-redirect to Media Library
```

#### Contextual Links

Features that link TO this feature:
- Dashboard → "Upload Media" quick action button
- Media Library → "Upload Files" button (top-right)
- Media Library → Empty state CTA (when no files exist)

Features that this feature links TO:
- Upload Center → "View in Media Library" link (after successful upload)
- Upload Center → "Dashboard" breadcrumb link

#### Related Features

- Media Library: Displays uploaded files
- File Detail: Shows individual file information after upload

---

**End of Template**
