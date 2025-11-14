# Existing HDA Transcribe & Translate Workflow Research

**Date:** 2025-10-24 19:19:15
**Research Method:** Playwright MCP browser automation
**Application URL:** https://hda.harikrishnamandir.org
**Status:** ✅ Complete

---

## Executive Summary

The existing HDA (Hari Krishna Mandir Digital Archive) application has a **fully functional audio/video transcription and translation workflow** designed to preserve and make accessible spiritual discourses and teachings. The system processes over 1,350+ media files (135 pages × 10 items/page) including audio recordings and videos of talks, bhajans, and spiritual discussions.

**Core Workflow:** Upload Media from Google Drive → Transcribe Audio/Video → Verify Transcription → Translate to Multiple Languages → Verify Translation → Save & Export

---

## 1. System Architecture Overview

### Technology Stack (Inferred):
- **Frontend:** React-based SPA
- **Authentication:** Email/Password with registration
- **Storage:** Google Drive integration for media files
- **Transcription Service:** Likely Google Cloud Speech-to-Text or similar
- **Translation Service:** Likely Google Cloud Translation API
- **Backend API:** REST API at `https://hda.harikrishnamandir.org/api`
- **Rich Text Editor:** WYSIWYG editor with formatting tools

---

## 2. User Flows & Features

### 2.1 Authentication Flow

**Registration:**
- Email/password signup
- Simple 2-field form
- Success message: "Registered successfully! Click on login to continue"

**Login:**
- Email/password login
- Redirect to dashboard after successful authentication

### 2.2 Dashboard

**Main Navigation:**
1. **Transcribe Media** - Upload and transcribe new media
2. **Verify media** - Review and verify transcriptions
3. **Translate Media** - Translate verified transcriptions
4. **Settings** - User settings (not explored)

**Welcome Message:**
> "Welcome to the Hari Krishna Mandir Digital Archiving System. We are delighted to have you here and deeply grateful for your participation in this noble and meaningful endeavor. This platform is dedicated to preserving and celebrating the rich spiritual legacy of Ma Indira Devi and Dadaji..."

---

## 3. Transcribe Media Workflow

### 3.1 Upload Interface

**Page:** `/picker`

**Features:**
- **Google Drive File Picker** integration
- **File Selection:** "Choose audio or video files from your Google Drive for transcription and processing"
- **Actions:**
  - "Sign in with Google" button
  - "Back" button

**Key Observations:**
- Uses Google Drive as primary storage/upload mechanism
- NO direct file upload from local device
- Requires Google authentication for Drive access

**Implications for HDA v2:**
- User mentioned "WITHOUT the drive functionality"
- HDA v2 will need different upload mechanism (likely direct upload like PDF system)

---

## 4. Verify Media Workflow

### 4.1 All Media List Page

**Page:** `/all-media`

**Features:**
- **Pagination:** 135 pages of media files (1,350+ files total)
- **Items per page:** 10 (configurable dropdown)
- **Filter Options:**
  - Media Type dropdown (All Types / Audio / Video)
  - Search by Title or PseudoName
  - Status checkboxes: Touched, Assigned, Verified

**Table Columns:**
1. **PseudoName** - Internal file identifier
2. **Title** - Display name (often same as filename)
3. **Media Type** - "audios" or "videos"
4. **Assigned** - Assignment status (✓/✗)
5. **Touched** - Has been viewed/edited (✓/✗)
6. **Verified** - Transcription verified (✓/✗)
7. **Action** - Button to open verification page

**Sample Media Files:**
- "Ground up meeting.mp4"
- "c 333 01 38.32 min ma talk on dadaji.mp3"
- "c 333 04 14.25 min ma talk+bhajan.mp3"
- "c 333 05 04.03 min ma talk.mp3"

**Status Patterns Observed:**
- Most files show "Touched: ✓" (green checkmark)
- Most files show "Assigned: ✗" (not assigned)
- Most files show "Verified: ✗" (not verified)

### 4.2 Verification Page

**Page:** `/verify-media/{mediaId}`
**Example:** `/verify-media/68ef88deb740aa3b7b923731`

**Layout:** Split-screen interface

**Left Panel - Media Player:**
- Video/Audio player with standard controls
- Progress bar
- Time display (e.g., "0:00 / 11:54")
- Playback speed control (1x default)
- Rewind/Play/Forward buttons
- File info: "pseudoName: Ground up meeting.mp4"
- Action buttons:
  - "COMPLETED" button (disabled until verified)
  - "VERIFY" button (disabled until changes saved)

**Right Panel - Transcription Editor:**
- **Media Details** (collapsible accordion)
- **Timestamps** section header
- **Search text** input (to find specific text in transcription)
- **Action Buttons:**
  - "DOWNLOAD AS PDF" - Export transcription
  - "OPEN PICKER PAGE" - Return to media selection
  - "SAVE" - Save edits (disabled until changes made)

**Transcription Content:**
- Full text transcription in scrollable table
- Long-form conversational text
- Example transcription included detailed conversation about centrifuges and fermentation (very specific technical content)
- Text appears to be unedited AI output

**Workflow:**
1. User clicks media from All Media list
2. Media player loads on left
3. Transcription appears on right
4. User can:
   - Play media and listen/watch
   - Read transcription alongside
   - Search for specific text
   - Edit transcription if needed
   - Download as PDF
   - Mark as verified when done

---

## 5. Translate Media Workflow

### 5.1 Translation Media List Page

**Page:** `/translate-media`

**Filters:**
- Media Type dropdown
- Search by Title or PseudoName

**Table Columns:**
1. **PseudoName**
2. **Title**
3. **Media Type**
4. **Transcription Verified** - Shows ✓ (prerequisite for translation)
5. **Touched** - Translation has been viewed
6. **Verified** - Translation verified
7. **Action** - Button to open translation workspace

**Sample Files Ready for Translation:**
- "Maut ka ek din mukarrar hai magar_shayari_c539-05_rx.mp3"
- "Ma's initial struggle_MA_c294-01_rx.mp3"
- "Ma's faith in Guru_GURUVAAD_c539-02_edt_rx extreme needed.mp3"
- "1994-08-20 Upstairs_0536_Mae Giridhar ki Giridhar mere_x264.mp4"

**Observation:** Only transcription-verified files appear in translation list

### 5.2 Translation Workspace

**Page:** `/translation-workspace/{transcriptId}`
**Example:** `/translation-workspace/68e3509eb740aa3b7b91d374`

**Layout:** Split-screen interface

**Left Panel - Original Transcript:**
- File name display: "Maut ka ek din mukarrar hai magar_shayari_c539-05_rx.mp3"
- **"Original Transcript"** heading
- Read-only text display showing source transcription
- **Mixed Language Content:**
  - English: "Day after day, month after month, hour after hour, just waiting for our gentle Lord to come or in death to come."
  - Hindi (Devanagari): "मौत का एक दिन मुअय्यन है मगर नींद क्यों रात भर नहीं आती। मौत भी नहीं आती, नींद भी नहीं आती, चैन भी नहीं आता।"

**Right Panel - Translation Interface:**
- **"Translation"** heading
- **Language Selector:**
  - Dropdown showing "English" (current)
  - Likely supports: Hindi, Marathi, Bengali, Gujarati, German, etc.
- **Action Buttons:**
  - "TRANSLATE" button (blue/primary) - Triggers AI translation
  - "VERIFY" button (disabled until translation exists)
  - "SAVE" button (disabled until changes made)
- **Rich Text Editor:**
  - Formatting toolbar:
    - Bold (B)
    - Italic (I)
    - Underline (U)
    - Bullet list
    - Numbered list
    - Clear formatting
  - Empty text area (awaiting translation)
  - Scroll support for long content

**Workflow:**
1. Select target language from dropdown
2. Click "TRANSLATE" button
3. AI generates translation in selected language
4. Translation appears in rich text editor
5. User can manually edit/refine translation
6. Click "SAVE" to save edits
7. Click "VERIFY" to mark as complete
8. Repeat for additional languages

**Key Features:**
- Manual editing support (rich text formatting)
- Multiple language support
- Verification workflow (quality control)
- Save state management

---

## 6. Data Model (Inferred)

### Media Entity:
```javascript
{
  _id: "68ef88deb740aa3b7b923731",
  pseudoName: "Ground up meeting.mp4",
  title: "Ground up meeting.mp4",
  mediaType: "audios" | "videos",
  audioUrl: string | null,
  videoUrl: string | null,
  driveFileId: string,
  status: {
    assigned: boolean,
    touched: boolean,
    verified: boolean
  }
}
```

### Transcript Entity:
```javascript
{
  transcriptId: "68e3509eb740aa3b7b91d374",
  mediaId: "68ef88deb740aa3b7b923731",
  content: string, // Full transcription text
  verified: boolean,
  transcribedAt: timestamp
}
```

### Translation Entity:
```javascript
{
  transcriptId: "68e3509eb740aa3b7b91d374",
  translations: {
    "en": {
      language: "English",
      content: string,
      verified: boolean,
      touchedBy: userId,
      verifiedBy: userId,
      updatedAt: timestamp
    },
    "hi": {...},
    "mr": {...}
    // ... other languages
  }
}
```

---

## 7. Screenshots Captured

1. **existing-hda-login-page.png** - Authentication interface
2. **existing-hda-dashboard.png** - Main dashboard with navigation
3. **existing-hda-transcribe-media-picker.png** - Google Drive file picker
4. **existing-hda-all-media-list.png** - Media list with status columns
5. **existing-hda-verify-transcription.png** - Split-screen verification interface
6. **existing-hda-translate-media-list.png** - Translation-ready media list
7. **existing-hda-translation-workspace.png** - Translation interface with rich text editor

All screenshots saved to: `.playwright-mcp/`

---

## 8. Key Insights for HDA v2 Epic 2

### 8.1 What to Bring into HDA v2:

**Core Workflows:**
1. ✅ Media upload (but NOT Google Drive - use direct upload)
2. ✅ Audio/video transcription
3. ✅ Transcription verification interface (media player + text editor)
4. ✅ Multi-language translation
5. ✅ Translation verification
6. ✅ Status tracking (Touched, Verified)
7. ✅ Export functionality (Download as PDF)

**UI/UX Patterns:**
1. ✅ Split-screen layout (media player + content)
2. ✅ Rich text editor for manual editing
3. ✅ Search functionality in transcriptions
4. ✅ Pagination for large media libraries
5. ✅ Filter/search interface

### 8.2 What to EXCLUDE (per user requirements):

**❌ Google Drive Integration:**
- User explicitly stated "WITHOUT the drive functionality"
- HDA v2 should use direct file upload (similar to PDF upload in Epic 1)

### 8.3 Technical Decisions Needed:

**Transcription Service:**
- Option 1: Google Cloud Speech-to-Text (like existing HDA)
- Option 2: AssemblyAI (cost-effective, better accuracy)
- Option 3: OpenAI Whisper API (multilingual support)
- **Recommendation:** Evaluate based on:
  - Cost per minute of audio
  - Language support (Hindi, Marathi, Bengali, Gujarati)
  - Accuracy for spiritual/religious content
  - Real-time vs batch processing

**Translation Service:**
- Option 1: Google Cloud Translation API
- Option 2: OpenAI GPT-4 (context-aware translation)
- Option 3: Vertex AI Gemini (already used in Epic 1)
- **Recommendation:** Vertex AI Gemini 2.5 Pro (consistency with Epic 1, context awareness)

**Storage:**
- Use Supabase Storage (already configured)
- Store audio/video files
- Store generated transcriptions
- Store translations per language

**Database Schema:**
- Extend `documents` table OR create new `media` table
- `transcriptions` table (mediaId, content, verified)
- `translations` table (transcriptId, language, content, verified)

---

## 9. Differences from Epic 1 (PDF Translation)

| Feature | Epic 1 (PDF) | Epic 2 (Media) |
|---------|--------------|----------------|
| **Input Type** | PDF documents | Audio/Video files |
| **Extraction** | Text extraction (Vertex AI) | Speech-to-text transcription |
| **Content Type** | Static text pages | Time-based media with timestamps |
| **Playback** | PDF viewer | Media player (audio/video) |
| **Verification** | Text review per page | Listen/watch + read transcription |
| **Translation** | Page-by-page | Full transcript at once |
| **Export** | PDF with fonts | PDF transcript OR subtitles (SRT/VTT) |
| **Processing Time** | Minutes (pages) | Potentially hours (long videos) |
| **File Size** | Typically < 50MB | Potentially > 500MB (videos) |

---

## 10. Epic 2 Scope Recommendations

### Must-Have (MVP for Epic 2):

**Story 2.1: Media Upload & Queue Integration**
- Direct file upload (audio/video)
- File validation (format, size limits)
- Queue system integration
- Progress indicators

**Story 2.2: Audio/Video Transcription**
- AI transcription service integration
- Job processing (similar to extraction workers)
- Transcription storage
- Error handling

**Story 2.3: Transcription Verification Interface**
- Media player component (audio/video)
- Split-screen layout
- Transcription text display
- Edit and save functionality
- Mark as verified

**Story 2.4: Multi-Language Translation**
- Language selection interface
- AI translation generation
- Translation storage (per language)
- Manual editing support

**Story 2.5: Translation Verification & Export**
- Translation review interface
- Verification workflow
- Export as PDF
- (Optional) Export as subtitles (SRT/VTT)

**Story 2.6: Media Library & Management**
- List view with filters
- Search functionality
- Status indicators
- Pagination

### Nice-to-Have (Future Epics):

- Timestamp-based editing (jump to specific time in media)
- Batch processing (multiple files at once)
- Speaker diarization (identify different speakers)
- Auto-subtitle generation
- Integration with video hosting (YouTube, Vimeo)
- Collaborative verification (multiple users)
- Quality scoring (transcription/translation confidence)

---

## 11. Architecture Alignment with Epic 1

### Reusable Components from Epic 1:

1. **Queue System (PGMQ)**
   - Create new queues: `transcription_queue`, `translation_queue`
   - Similar job structure to extraction/translation

2. **Worker Architecture**
   - `transcription_worker.py` (similar to text_extraction_worker.py)
   - `translation_worker.py` (reuse existing, extend for media)

3. **Database Tables**
   - Extend schema with `media`, `transcriptions`, `media_translations`
   - Reuse patterns from `documents`, `extractions`, `translations`

4. **Frontend Components**
   - Upload interface (modify from PDF upload)
   - Queue management (extend existing)
   - Rich text editor (new component)

5. **API Patterns**
   - `/api/media/upload`
   - `/api/transcriptions/{id}`
   - `/api/translations/{transcriptId}`

---

## 12. Open Questions for User

1. **Supported Media Formats:**
   - Audio: MP3, WAV, M4A, FLAC?
   - Video: MP4, AVI, MOV, MKV?
   - File size limits?

2. **Transcription Service:**
   - Budget for transcription? (price per minute)
   - Required languages for transcription recognition?
   - Accuracy requirements?

3. **Translation Languages:**
   - Same 6 languages as Epic 1? (English, Hindi, Marathi, Bengali, Gujarati, German)
   - Or different set for media content?

4. **Export Formats:**
   - PDF transcript only?
   - Subtitle files (SRT/VTT)?
   - Both?

5. **Media Management:**
   - Do we need the "Assigned" workflow (assign media to specific users)?
   - Or simpler status tracking like Epic 1?

6. **Priority:**
   - Which is more important: transcription or translation?
   - Can we release in phases (transcription first, translation later)?

---

## 13. Next Steps

1. **Create Epic 2 PRD** based on this research
2. **Define story breakdown** (6 stories recommended)
3. **Create architecture diagrams** for media workflow
4. **Estimate effort** per story (2-3 days each)
5. **Get user feedback** on scope and priorities
6. **Initialize Epic 2 context files** from templates
7. **Begin Story 2.1** development

---

**Research Completed:** 2025-10-24 19:19:15
**Total Time:** ~90 minutes
**Method:** Playwright MCP browser automation
**Status:** ✅ Ready for Epic 2 planning

