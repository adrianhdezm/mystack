# 02 - Landing Page Sections

## Content sourcing

Before writing any component, read `docs/vision.md` (if present) to gather:

- Product name
- One-line tagline or headline
- Key features or benefits (3–6 items)
- Primary CTA label and destination (e.g., "Get started" → `/signup`, "Try it free" → `/signup`)

If `docs/vision.md` is absent, ask the user for product name, headline, and 3–6 features before writing component code. Do not use generic placeholder copy.

## SiteHeader

`app/components/landing/SiteHeader.tsx`

A minimal navigation bar with the product name/logo and a primary CTA link. Link to `/login` and `/signup` when authentication is present; otherwise link directly to the main app entry point.

```tsx
import { Link } from "react-router";
import { Button } from "~/components/ui/button";

export function SiteHeader() {
  return (
    <header className="sticky top-0 z-50 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-16 items-center justify-between">
        <Link to="/" className="text-xl font-bold">
          {/* Product name */}
        </Link>
        <nav className="flex items-center gap-4">
          <Button asChild variant="ghost">
            <Link to="/login">Log in</Link>
          </Button>
          <Button asChild>
            <Link to="/signup">Get started</Link>
          </Button>
        </nav>
      </div>
    </header>
  );
}
```

Adjust the nav links to match the product's authentication setup. If there is no authentication, replace with a single CTA or remove nav links entirely.

## SiteFooter

`app/components/landing/SiteFooter.tsx`

A minimal footer with the product name, copyright year, and links to legal pages. Include Impressum and Privacy Policy links when `legal_pages=yes`; omit them otherwise.

```tsx
import { Link } from "react-router";

export function SiteFooter() {
  return (
    <footer className="border-t py-8">
      <div className="container flex flex-col items-center justify-between gap-4 sm:flex-row">
        <p className="text-sm text-muted-foreground">
          © {new Date().getFullYear()} {/* Product name */}. All rights
          reserved.
        </p>
        <nav className="flex gap-4 text-sm text-muted-foreground">
          {/* Add <Link to="/impressum">Impressum</Link> when legal_pages=yes */}
          {/* Add <Link to="/privacy-policy">Privacy Policy</Link> when legal_pages=yes */}
        </nav>
      </div>
    </footer>
  );
}
```

Use React Router `<Link>` (not `<a>` tags) for all footer navigation. When `adding-legal-pages` is run afterward, update `SiteFooter` to add the Impressum and Privacy Policy links.

## Hero

`app/components/landing/Hero.tsx`

A full-width section with headline, subheadline, and a primary CTA button. Use the product name and tagline from `docs/vision.md`.

```tsx
import { Link } from "react-router";
import { Button } from "~/components/ui/button";

export function Hero() {
  return (
    <section className="container flex flex-col items-center gap-6 py-24 text-center md:py-32">
      <h1 className="text-4xl font-bold tracking-tight sm:text-5xl md:text-6xl">
        {/* Headline from docs/vision.md */}
      </h1>
      <p className="max-w-2xl text-lg text-muted-foreground">
        {/* Subheadline / value proposition */}
      </p>
      <div className="flex gap-4">
        <Button asChild size="lg">
          <Link to="/signup">{/* Primary CTA label */}</Link>
        </Button>
      </div>
    </section>
  );
}
```

## Features

`app/components/landing/Features.tsx`

A grid of 3–6 feature cards, each with an icon, title, and short description. Use real features from `docs/vision.md`.

```tsx
const features = [
  {
    title: "", // Feature title from docs/vision.md
    description: "", // One-sentence description
  },
  // ... repeat for each feature
];

export function Features() {
  return (
    <section className="container py-24">
      <h2 className="mb-12 text-center text-3xl font-bold">
        {/* Section heading, e.g. "Everything you need" */}
      </h2>
      <div className="grid gap-8 sm:grid-cols-2 lg:grid-cols-3">
        {features.map((feature) => (
          <div key={feature.title} className="rounded-lg border p-6">
            <h3 className="mb-2 text-lg font-semibold">{feature.title}</h3>
            <p className="text-sm text-muted-foreground">
              {feature.description}
            </p>
          </div>
        ))}
      </div>
    </section>
  );
}
```

## CTASection

`app/components/landing/CTASection.tsx`

A closing call-to-action section that repeats the primary CTA. Place it at the bottom of the landing page.

```tsx
import { Link } from "react-router";
import { Button } from "~/components/ui/button";

export function CTASection() {
  return (
    <section className="border-t bg-muted/50 py-24">
      <div className="container flex flex-col items-center gap-6 text-center">
        <h2 className="text-3xl font-bold">{/* Closing headline */}</h2>
        <p className="max-w-xl text-muted-foreground">
          {/* Supporting copy */}
        </p>
        <Button asChild size="lg">
          <Link to="/signup">{/* CTA label */}</Link>
        </Button>
      </div>
    </section>
  );
}
```

## Implementation Notes

- All copy must come from `docs/vision.md` or the user's brief. Ask before using placeholder text.
- Use shadcn/ui `Button`, `Link`, and layout primitives. Do not add new UI libraries.
- The `container` class centers content with consistent horizontal padding — use it on every section.
- Icons are optional. If you add icons, use `lucide-react` (already in the shadcn/ui stack); do not install icon libraries.
- Keep component files focused on a single section. Do not combine Hero and Features into one file.

## Expected Results

- `app/components/landing/` contains `SiteHeader.tsx`, `SiteFooter.tsx`, `Hero.tsx`, `Features.tsx`, and `CTASection.tsx`.
- All copy reflects real product content.
- Components use only shadcn/ui and Tailwind for styling.
