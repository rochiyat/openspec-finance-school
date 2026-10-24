## 1. Tokens (Phase 1)

- [x] 1.1 Montserrat font, `font-sans` default, `font-outfit` alias; chart font names updated
- [x] 1.2 Remap `brand-*` and `gray-*` scales to Iqrolife values; focus ring and `--color-black` follow
- [x] 1.3 Add Iqrolife color utilities and semantic tokens with `.dark` values
- [x] 1.4 Card radius 20px (`rounded-2xl`); menu utilities use the new tokens

## 2. App shell (Phase 2)

- [x] 2.1 `SidebarContext`: drawer state only, one 1024px breakpoint, close on resize to desktop and on Escape
- [x] 2.2 `AppHeader`: one row with menu button (`aria-expanded`, `aria-controls`), logo, breadcrumb from `md`, actions; `UserDropdown` shows the avatar only below `xl` and the notification panel fits phone width
- [x] 2.3 `AppSidebar`: Iqrolife-style `w-64` sticky panel on desktop, drawer below `lg`, `rounded-full` links with `aria-current`, role and child selectors in the drawer
- [x] 2.4 `AppLayout` and `Backdrop`: z-index order header 40, sidebar 30, backdrop 20; main `min-w-0` with Iqrolife padding; close drawer on route change
- [x] 2.5 Logo asset and page title

## 3. Verification

- [x] 3.1 Update tests that mock `useSidebar`; add a shell test for `aria-expanded`, Escape and active link
- [x] 3.2 `npm run lint`, `npm run build`, `npm run test` in `kss-frontend` (build and typecheck pass; changed files add no lint errors; 4 `App.test.tsx` tests already failed before this change and are not fixed here)
- [x] 3.3 Visual check at 375, 768 and 1280px in light and dark mode
