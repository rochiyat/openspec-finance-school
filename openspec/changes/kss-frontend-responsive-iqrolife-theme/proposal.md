## Why

kss-frontend still looks like the TailAdmin template it was built from (Outfit font, `#465fff` blue, plain grays), while the Iqrolife dashboard (`iqrolife/`) already uses the Iqrolife design system (sky, sun, coral, willow on night text, Montserrat). Parents and teachers move between both apps, so they should look like one product.

The app shell also does not work well on phones and tablets. The sidebar context treats `<768px` as mobile but the header and layout switch at `1024px`, so on a tablet the drawer can close by itself when the screen rotates. The desktop sidebar is a 90px rail that only opens on mouse hover, which touch screens cannot do.

## What Changes

- **Phase 1, tokens:** `kss-frontend/src/index.css` takes the Iqrolife palette and font. The existing `brand-*` and `gray-*` scales are remapped to Iqrolife sky and night/line values so the ~5,700 existing class uses change look without editing pages. Iqrolife names (`sky`, `sun`, `coral`, `willow`, `night`, `cloud`, `line`) and semantic tokens (`primary`, `muted`, `border`, …) are added for new code. Card radius becomes 20px.
- **Phase 2, app shell:** one breakpoint (`lg`, 1024px) for everything. The desktop sidebar follows the Iqrolife dashboard: a fixed-width (`w-64`) sticky panel under the header, no hover rail and no collapse. Below `lg` it is an off-canvas drawer with a backdrop that closes on navigation, backdrop tap and Escape. The header is one row: menu button (below `lg`), logo, then actions.
- Later phases (primitives such as `Button`, `Modal`, responsive tables, and page migration) are **not** part of this change.

## Capabilities

### New Capabilities
- `kss-responsive-app-shell`: Iqrolife visual tokens for kss-frontend and a responsive app shell (header, sidebar, drawer) for phone, tablet and desktop.

### Modified Capabilities
(none)

## Impact

- **kss-frontend only:** `src/index.css`, `src/context/SidebarContext.tsx`, `src/layout/*`, `index.html`, `public/logo-iqrolife.png`, plus chart font names. No API, route or data change.
- Pages keep their current classes. They pick up the new colors through the remapped scales, and raw Tailwind colors (`red`, `emerald`, `blue`, …) are unchanged until a later phase.
- The student report PDF is rendered from the page, so it switches to Montserrat as well.
