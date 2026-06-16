# 03 - Footer Links

## Steps

### 1. Locate SiteFooter

If `adding-landing-page` was run, `SiteFooter` is at `app/components/landing/SiteFooter.tsx`. Open it and add links to each legal page that was created.

### 2. Update SiteFooter

Add a `Link` for each created page inside the footer nav. Only add links for pages that exist.

```tsx
import { Link } from "react-router";

export function SiteFooter() {
  return (
    <footer className="border-t py-8">
      <div className="container flex flex-col items-center justify-between gap-4 sm:flex-row">
        <p className="text-sm text-muted-foreground">
          © {new Date().getFullYear()} {/* Product name */}. All rights reserved.
        </p>
        <nav className="flex gap-4 text-sm text-muted-foreground">
          {/* Add only the pages that were created */}
          <Link to="/impressum" className="hover:underline">Impressum</Link>
          <Link to="/privacy-policy" className="hover:underline">Privacy Policy</Link>
          <Link to="/terms" className="hover:underline">Terms of Service</Link>
        </nav>
      </div>
    </footer>
  );
}
```

### 3. If SiteFooter does not exist

If the project has no `SiteFooter` (e.g., `adding-landing-page` was not run), add footer links to the closest existing public layout or page. Do not create a new layout file just for footer links — add the links inline to whatever renders at the bottom of the public pages.

### 4. Check for existing cookie banner or consent UI

If the project has a cookie banner or consent modal (e.g., in `app/components/CookieBanner.tsx`), add a link to the Privacy Policy there as well.

## Expected Results

- Every created legal page is reachable from the site footer.
- Footer links use React Router `<Link>` (not `<a>` tags) for client-side navigation.
- No other layout or navigation is affected.
