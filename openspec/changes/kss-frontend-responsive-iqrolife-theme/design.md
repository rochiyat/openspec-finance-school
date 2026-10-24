## Context

Reference: `iqrolife/app/globals.css` (tokens) and `iqrolife/app/dashboard/(protected)/layout.tsx` (shell). kss-frontend is Vite + React + Tailwind v4 with a `.dark` class toggled by `ThemeContext`, and about 4,800 `gray-*`, 970 `brand-*` and 2,000 `dark:` class uses.

## Decisions

### 1. Remap scales instead of renaming classes
`brand-*` and `gray-*` keep their names but take Iqrolife values. This changes the whole app in one file and keeps `dark:` classes working, because the gray scale stays a light-to-dark ramp.

| Scale | Anchor values |
|---|---|
| `brand-500` | `#0070b8` (Iqrolife `sky-700`, text-safe, white text on fill) |
| `brand-400` | `#38b6ff` (`sky-500`, used as text in dark mode) |
| `brand-50` | `#e6f4fd` (`sky-100`, active menu surface) |
| `gray-50` | `#f7fcff` (`cloud-50`, page background) |
| `gray-200` | `#cfe3f1` (`line`, borders) |
| `gray-500` | `#4a6478` (`night-600`, muted text) |
| `gray-900` | `#04263d` (body text in light, surface in dark) |
| `gray-950` | `#011a2b` (dark page background) |

Alternative rejected: switching to Iqrolife's CSS-variable dark mode now. That needs every `dark:` class removed and belongs to page migration.

Status colors (`success`, `error`, `warning`) and raw Tailwind colors stay as they are, so status meaning does not shift.

### 2. New code uses Iqrolife names
`sky-100/500/700`, `sun-500`, `cream-50`, `coral-500/700`, `willow-500/800`, `night-600/900/950`, `cloud-50`, `line`, `line-strong`, `on-fill` and semantic `primary`, `secondary`, `muted`, `accent`, `border`, `ring` are defined as utilities with dark values, the same as Iqrolife. Defining `sky-100/500/700` replaces only those three steps of Tailwind's default sky scale. kss-frontend uses `sky-*` 4 times, none on those steps.

### 3. Font
Montserrat replaces Outfit. `font-outfit` stays as an alias so the pages that use it keep working. `font-sans` is the default.

### 4. Shell
- One breakpoint: `lg` (1024px). `SidebarContext` only keeps `isMobileOpen`, `toggleMobileSidebar` and `closeMobileSidebar`. The expand, hover and submenu state is removed because nothing else reads it.
- Header: `sticky top-0 z-40 h-16`, full width. Menu button `lg:hidden` with `aria-expanded` and `aria-controls`. Logo plus "KSS Iqrolife". Actions on the right. Breadcrumb shown from `md`.
- Sidebar: `w-64`, `top-16`, height `calc(100vh-4rem)`, `z-30`. `lg:sticky lg:translate-x-0`. Below `lg` it is `fixed` and `-translate-x-full` until opened. Links are `rounded-full` with `bg-sky-100` and `aria-current="page"` when active, as in Iqrolife.
- Backdrop `z-20`, `lg:hidden`. The drawer closes on route change, backdrop tap, Escape, and when the window grows to `lg`.
- Main: `min-w-0 flex-1 p-4 md:p-6 lg:p-8`, `max-w-screen-2xl`.

## Risks

- Some pages use `gray-900` for text on a `brand-500` fill, or similar pairs. The contrast stays above 4.5:1 because both anchors are darker than before.
- Hard-coded hex in charts (108 uses) still shows the old blue until page migration.
