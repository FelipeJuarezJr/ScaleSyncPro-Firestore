# ScaleSync Pro Design System & Style Guide

This document presents a comprehensive summary of the visual design system, color palettes, typography, spacing, layouts, and component styles used across the **ScaleSync Pro Ecosystem** (including the core dashboard, ScaleSync Marketplace, and ScaleSync Social portals). 

These specifications represent the current styling found in both the **Next.js Web Frontend** (CSS Custom Properties) and the **Flutter Mobile/Web Apps** (Material 3 Theme Data).

---

## 1. Visual Theme & Color Palette

The ecosystem features a dynamic theme system supporting two distinct modes: **Diurnal Mode** (Light Theme) and **Nocturnal Mode** (Dark Theme).

### A. Diurnal Mode (Light Theme)
Diurnal Mode is inspired by organic, natural tones suited for daytime reading.

| Color Variable | Hex Code | Flutter Constant | Visual Role / Usage |
| :--- | :--- | :--- | :--- |
| Primary Color | `#2C5530` | `Color(0xFF2C5530)` | Forest Green; main brand identifiers, primary buttons |
| Primary Light | `#4A7C59` | `Color(0xFF4A7C59)` | Muted Sage Green; button hovers, highlights |
| Secondary Color | `#8BC34A` | `Color(0xFF8BC34A)` | Lime Green; interactive accents, select states |
| Accent Color | `#FF9800` | `Color(0xFFFF9800)` | Bright Orange; system alerts, warning states, gold plan badges |
| Background Primary | `#FFFFFF` | `Color(0xFFFFFFFF)` | True White; page containers, cards, navigation background |
| Background Secondary| `#F8F9FA` | `Color(0xFFF8F9FA)` | Off-White; page scaffolds, main container background |
| Background Tertiary | `#E9ECEF` | `Color(0xFFE9ECEF)` | Cool Light Grey; inputs, divider backdrops, image placeholders |
| Text Primary | `#333333` | `Color(0xFF333333)` | Charcoal Grey; high-contrast titles, body text |
| Text Secondary | `#666666` | `Color(0xFF666666)` | Medium Grey; subtitles, metadata, label descriptions |
| Text Light | `#999999` | `Color(0xFF999999)` | Light Grey; input placeholders, disabled elements |
| Border Default | `#E0E0E0` | `Color(0xFFE0E0E0)` | Soft Grey; standard container outlines, dividers |
| Border Light | `#F1F3F4` | `Color(0xFFF1F3F4)` | Ultra-light Grey; secondary grid lines |

### B. Nocturnal Mode (Dark Theme)
Nocturnal Mode is a neon-cyberpunk dark interface designed to reduce eye strain.

| Color Variable | Hex Code | Flutter Constant | Visual Role / Usage |
| :--- | :--- | :--- | :--- |
| Primary Color | `#00FF00` | `Color(0xFF00FF00)` | Neon Green; branding, success indicators, focused outlines |
| Primary Light | `#00D4FF` | `Color(0xFF00D4FF)` | Cyan Blue; secondary accents, info status indicators |
| Secondary Color | `#00FF00` | `Color(0xFF00FF00)` | Neon Green; identical to primary for dark-mode consistency |
| Accent Color | `#FFA500` | `Color(0xFFFFA500)` | Cyber Orange; warning/attention badges, premium elements |
| Background Primary | `#1A1A1A` | `Color(0xFF1A1A1A)` | Obsidian Black; cards, input fields, dropdown menus, app bars |
| Background Secondary| `#2C2C2C` | `Color(0xFF2C2C2C)` | Deep Charcoal; main page background |
| Background Tertiary | `#3A3A3A` | `Color(0xFF3A3A3A)` | Muted Charcoal; active inputs, layout partitions |
| Text Primary | `#FFFFFF` | `Color(0xFFFFFFFF)` | Pure White; header titles, high-emphasis text |
| Text Secondary | `#CCCCCC` | `Color(0xFFCCCCCC)` | Muted White; body copy, lists, table content |
| Text Light | `#999999` | `Color(0xFF999999)` | Neutral Grey; placeholders, time stamps |
| Border Default | `#4A4A4A` | `Color(0xFF4A4A4A)` | Dark Grey; card borders, divider lines |
| Border Light | `#3A3A3A` | `Color(0xFF3A3A3A)` | Subdued Grey; list dividers |

---

## 2. Common Design Tokens

### A. Border Radius
*   `--border-radius-sm` / `borderRadiusSm`: `4.0px` — Used for status badges, tags, custom checkboxes, and toggle buttons.
*   `--border-radius` / `borderRadius`: `8.0px` — Used for text inputs, dropdowns, primary buttons, and list items.
*   `--border-radius-lg` / `borderRadiusLg`: `12.0px` — Used for cards, dialog modals, sheet panels, and main grids.

### B. Transitions
*   `--transition` / `transition`: `all 0.3s ease` (or `Duration(milliseconds: 300)` in Flutter) — Standardized timing for hover states, focus transitions, and panel animations.

### C. Shadows (BoxShadows)
*   **Small Shadow (`shadowSm`)**: `0 2px 4px rgba(0,0,0,0.05)` (Light) or `0 2px 4px rgba(0,0,0,0.3)` (Dark). Used for sticky elements and small indicators.
*   **Medium Shadow (`shadowMd`)**: `0 4px 6px rgba(0,0,0,0.1)` (Light) or `0 4px 12px rgba(0,0,0,0.3)` (Dark). Used for cards, buttons, and navigation bars.
*   **Large Shadow (`shadowLg`)**: `0 10px 15px rgba(0,0,0,0.1)` (Light) or `0 10px 25px rgba(0,0,0,0.4)` (Dark). Used for dropdown boxes, modals, and landing pages.

---

## 3. Typography Size Scales & Weights

The typography scale utilizes browser-safe Sans-Serif fonts (`'Segoe UI'`, `Tahoma`, `Geneva`, `Verdana`, `sans-serif`) to ensure compatibility across all web and native renders.

*   **Display Large**: `32px` / Bold — Page titles, marketing slogans, and hero displays.
*   **Display Medium**: `28px` / Bold — Primary section headers, brand logos.
*   **Display Small**: `24px` / Bold — Modal titles, secondary sections.
*   **Headline Large**: `22px` / Semi-bold (w600) — Major card headings.
*   **Headline Medium**: `20px` / Semi-bold (w600) — Subsections, statistics numbers.
*   **Headline Small**: `18px` / Semi-bold (w600) — Dialog headers.
*   **Title Large**: `16px` / Semi-bold (w600) — Item titles, input labels.
*   **Title Medium**: `14px` / Medium (w500) — Buttons text, navigation tags.
*   **Title Small**: `12px` / Medium (w500) — Small category badges, tab labels.
*   **Body Large**: `16px` / Regular — Main body descriptions, posts, text areas.
*   **Body Medium**: `14px` / Regular — Table elements, item metadata.
*   **Body Small**: `12px` / Regular — Muted timestamps, disclaimer text.

---

## 4. Domain-Specific Portal Aesthetics

ScaleSync Pro splits its ecosystem into three portals with distinct, signature styles for authentication screens, while sharing standard dark dashboard pages.

### Portal A: ScaleSync Pro (Core Collection Management)
A clean, grid-aligned corporate styling with bright gradient anchors.
*   **Background**: High-contrast, double-gradient background.
    *   **Base page background**: `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF00FF00), Color(0xFF00D4FF)])`.
    *   **Card wrapper background**: `LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF1A1A1A), Color(0xFF2C2C2C)])` (Dark obsidian card).
*   **Branding Element**: Drag indicator icon (`Icons.drag_indicator` / `fa-drag-indicator`).

### Portal B: ScaleSync Marketplace
Commercial storefront vibe utilizing premium **glassmorphism** overlays and colorful background lighting.
*   **Background**: Radial background lighting overlaying solid dark page base.
    *   **Base background**: `#1A1A1A`.
    *   **Glowing Orb 1 (Top-Left)**: Radial gradient with Cyan (`Color(0x2400D2FF)`, 14% opacity), diameter `500px`.
    *   **Glowing Orb 2 (Bottom-Right)**: Radial gradient with Green (`Color(0x2400E676)`, 14% opacity), diameter `600px`.
*   **Glassmorphic Overlay Card**:
    *   **Backdrop Filter**: Gaussian blur with `sigmaX: 20, sigmaY: 20`.
    *   **Card container background**: `#2C2C2C` with `75%` opacity (allows glowing background colors to bleed through dynamically).
    *   **Border**: `#4A4A4A` with `30%` opacity (`withValues(alpha: 0.3)`).
*   **Branding Element**: Storefront icon (`Icons.storefront` / `fa-storefront`).

### Portal C: ScaleSync Social
Interactive social-graph styling featuring glassmorphic overlay cards, glowing background orbs, and low-opacity floating interface nodes.
*   **Background**: Solid dark viewport base decorated with radial orbs and floating icons.
    *   **Base background**: `#1A1A1A`.
    *   **Glowing Orb 1 (Center-Left)**: Cyan (`Color(0x2000D2FF)`, 12% opacity), diameter `450px`.
    *   **Glowing Orb 2 (Top-Right)**: Green (`Color(0x2000E676)`, 12% opacity), diameter `400px`.
*   **Floating Icons (Nodes)**: Decorated in corners behind the card overlay.
    *   **Share Node (Top-Left)**: Cyan, 12% opacity, size `44px`.
    *   **People Node (Top-Right)**: Cyan, 10% opacity, size `60px`.
    *   **Thumbs Up Node (Bottom-Left)**: Green, 14% opacity, size `38px`.
    *   **Chat Bubble Node (Bottom-Right)**: Green, 14% opacity, size `52px`.
*   **Glassmorphic Overlay Card**: Identical layout to the Marketplace (blur: 20px, container background: `#2C2C2C` at 75% opacity, border: `#4A4A4A` at 30% opacity).
*   **Branding Element**: People outline icon (`Icons.people_outline` / `fa-people-outline`).

---

## 5. Layout and Grid Specifications

The web and app layouts use standardized flex and grid grids to keep structures clean and responsive:

*   **Main Content Section**: Max width of `1400px`, centered, with default padding of `20px`.
*   **Dashboard Grid**: Standard flex-grid arrangement, shifting based on viewports.
*   **Stats Grid**: Grid using CSS `repeat(auto-fit, minmax(250px, 1fr))` or dynamic row wrap in Flutter. Cards feature a circular icon on the left (`60x60px` with radial gradient background) and statistical content on the right.
*   **Reptile Grid**: Grid using CSS `repeat(auto-fill, minmax(300px, 1fr))`. Features card item containers with image blocks fixed to a height of `200px` (or `CanvasKit` canvases on Flutter web builds).
*   **Breeding Projects Grid**: Grid using CSS `repeat(auto-fill, minmax(350px, 1fr))`. Features double nested containers representing sire (male parent) and dam (female parent) cards on a split `1fr 1fr` row.
*   **Form Rows**: Side-by-side inputs (e.g., first/last name, species/morph) are split via a double-column layout (`grid-template-columns: 1fr 1fr`) with a standard gutter gap of `15px`.
*   **Sidebar / Header Navigation**: High-contrast, sticky navigation bar with a fixed height of `70px`.

---

## 6. Micro-Animations & Dynamic Hover States

*   **Interactive Input Focus/Hover**: Text fields transition their border to `#00FF00` (Neon Green) upon user hover or selection. In CSS, they also grow a neon halo: `box-shadow: 0 0 0 3px rgba(0, 255, 0, 0.2)`.
*   **Card Hovers**: Cards smoothly elevate upon mouse hover by reducing margins/shifting coordinates and switching shadows from `shadowSm` to `shadowMd`:
    `transform: translateY(-2px)`.
*   **Submit Buttons**: ScaleSync Pro primary buttons blend into a cyan gradient upon hover, transitioning from `#00FF00` to `#00D4FF` over `300ms`.
*   **Google Auth Multi-Color Border Loop**: The "Continue with Google" button loops through Google's branding colors when hovered. Upon hover activation, it transitions through:
    $$\text{Blue} \rightarrow \text{Red} \rightarrow \text{Yellow} \rightarrow \text{Green} \rightarrow \text{Original Dark Theme Background}$$
    This animation runs over `1200ms` using smooth color interpolation (`Color.lerp`).
*   **Developer Switcher Bar**: Located at the top of web developer viewports, it has a solid black layout (`#0F0F0F`) and features a green circular indicator that pulses with a glowing green spread shadow (`BoxShadow(color: Color(0xFF00FF00).withOpacity(0.6), blurRadius: 4, spreadRadius: 1)`). Segment buttons slide transition using a fast cubic-bezier curve over `220ms`.
