## Purpose
kss-frontend looks like the Iqrolife dashboard and its shell works on phone, tablet and desktop.

## ADDED Requirements

### Requirement: Iqrolife visual tokens
kss-frontend SHALL use the Iqrolife palette and the Montserrat font. The existing `brand-*` and `gray-*` utility scales SHALL map to Iqrolife sky and night/line values, in both light and dark mode. Iqrolife color names and semantic tokens SHALL be available as utilities for new code.

#### Scenario: Primary color
- **WHEN** a page renders an element with `bg-brand-500`
- **THEN** its fill is Iqrolife sky `#0070b8`

#### Scenario: Page background
- **WHEN** any page renders in light mode
- **THEN** the page background is Iqrolife cloud `#f7fcff` and body text uses Montserrat

### Requirement: One responsive breakpoint for the shell
The shell SHALL switch between the mobile and desktop layout at 1024px only.

#### Scenario: Tablet portrait
- **WHEN** the viewport is 768px wide
- **THEN** the sidebar is hidden, the menu button is shown, and the content uses the full width

#### Scenario: Desktop
- **WHEN** the viewport is 1280px wide
- **THEN** the sidebar is always visible next to the content and the menu button is hidden

### Requirement: Desktop sidebar follows the Iqrolife dashboard
On desktop the sidebar SHALL be a fixed-width panel below the header that stays in place while the page scrolls. It SHALL NOT collapse to an icon rail or depend on mouse hover. The active link SHALL be marked with `aria-current="page"`.

#### Scenario: Active link
- **WHEN** the user is on `/teacher/attendance`
- **THEN** the "Absensi Saya" link has `aria-current="page"` and the active style

### Requirement: Mobile drawer
Below 1024px the sidebar SHALL open as a drawer over the content with a backdrop. The menu button SHALL report its state with `aria-expanded`. The drawer SHALL close on navigation, on a backdrop tap, on Escape, and when the viewport grows to 1024px or more. Role and child selectors that do not fit in the mobile header SHALL be reachable from the drawer.

#### Scenario: Navigate from drawer
- **WHEN** a parent on a 375px phone opens the menu and taps "Rapor Anak"
- **THEN** the page changes and the drawer is closed

#### Scenario: Escape
- **WHEN** the drawer is open and the user presses Escape
- **THEN** the drawer closes

#### Scenario: No horizontal scroll from the shell
- **WHEN** the viewport is 360px wide
- **THEN** the header and drawer cause no horizontal page scroll
