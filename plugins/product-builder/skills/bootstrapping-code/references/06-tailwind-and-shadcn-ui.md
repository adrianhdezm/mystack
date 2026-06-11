# 06 - Tailwind and shadcn/ui

## Steps

1. Check the latest Tailwind package versions.

```sh
pnpm view tailwindcss version
pnpm view @tailwindcss/vite version
```

2. Install the Tailwind Vite toolchain as development dependencies.

```sh
pnpm add -D tailwindcss@latest @tailwindcss/vite@latest
```

3. Check the latest shadcn/ui dependency versions.

```sh
pnpm view class-variance-authority version
pnpm view clsx version
pnpm view tailwind-merge version
pnpm view lucide-react version
pnpm view tw-animate-css version
pnpm view @base-ui/react version
```

4. Install the shadcn/ui dependencies.

```sh
pnpm add class-variance-authority@latest clsx@latest tailwind-merge@latest lucide-react@latest tw-animate-css@latest @base-ui/react@latest
```

5. Confirm `tsconfig.json` and `tsconfig.cloudflare.json` use the app path alias.

```json
{
  "compilerOptions": {
    "paths": {
      "~/*": ["./app/*"]
    }
  }
}
```

6. Create `app/app.css` with the Tailwind and shadcn/ui theme styles.

```css
@import "tailwindcss";
@import "tw-animate-css";

@custom-variant dark (&:is(.dark *));

@theme inline {
  --breakpoint-3xl: 1600px;
  --breakpoint-4xl: 2000px;

  --radius-sm: calc(var(--radius) * 0.6);
  --radius-md: calc(var(--radius) * 0.8);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) * 1.4);
  --radius-2xl: calc(var(--radius) * 1.8);
  --radius-3xl: calc(var(--radius) * 2.2);
  --radius-4xl: calc(var(--radius) * 2.6);

  --color-background: var(--background);
  --color-foreground: var(--foreground);
  --color-card: var(--card);
  --color-card-foreground: var(--card-foreground);
  --color-popover: var(--popover);
  --color-popover-foreground: var(--popover-foreground);
  --color-primary: var(--primary);
  --color-primary-foreground: var(--primary-foreground);
  --color-secondary: var(--secondary);
  --color-secondary-foreground: var(--secondary-foreground);
  --color-muted: var(--muted);
  --color-muted-foreground: var(--muted-foreground);
  --color-accent: var(--accent);
  --color-accent-foreground: var(--accent-foreground);
  --color-destructive: var(--destructive);
  --color-destructive-foreground: var(--destructive-foreground);
  --color-border: var(--border);
  --color-input: var(--input);
  --color-ring: var(--ring);

  --color-chart-1: var(--chart-1);
  --color-chart-2: var(--chart-2);
  --color-chart-3: var(--chart-3);
  --color-chart-4: var(--chart-4);
  --color-chart-5: var(--chart-5);

  --color-sidebar: var(--sidebar);
  --color-sidebar-foreground: var(--sidebar-foreground);
  --color-sidebar-primary: var(--sidebar-primary);
  --color-sidebar-primary-foreground: var(--sidebar-primary-foreground);
  --color-sidebar-accent: var(--sidebar-accent);
  --color-sidebar-accent-foreground: var(--sidebar-accent-foreground);
  --color-sidebar-border: var(--sidebar-border);
  --color-sidebar-ring: var(--sidebar-ring);

  --color-surface: var(--surface);
  --color-surface-foreground: var(--surface-foreground);
  --color-code: var(--code);
  --color-code-foreground: var(--code-foreground);
  --color-code-highlight: var(--code-highlight);
  --color-code-number: var(--code-number);
  --color-selection: var(--selection);
  --color-selection-foreground: var(--selection-foreground);
}

:root {
  --radius: 0.625rem;

  --background: oklch(1 0 0);
  --foreground: oklch(0% 0 0);

  --card: oklch(1 0 0);
  --card-foreground: oklch(0% 0 0);

  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0% 0 0);

  --primary: oklch(0% 0 0);
  --primary-foreground: oklch(0.985 0 0);

  --secondary: oklch(0.97 0 0);
  --secondary-foreground: oklch(0.205 0 0);

  --muted: oklch(0.97 0 0);
  --muted-foreground: oklch(0.556 0 0);

  --accent: oklch(0.97 0 0);
  --accent-foreground: oklch(0.205 0 0);

  --destructive: oklch(0.577 0.245 27.325);
  --destructive-foreground: oklch(0.97 0.01 17);

  --border: oklch(0.922 0 0);
  --input: oklch(0.922 0 0);
  --ring: oklch(0.708 0 0);

  --chart-1: var(--color-blue-300);
  --chart-2: var(--color-blue-500);
  --chart-3: var(--color-blue-600);
  --chart-4: var(--color-blue-700);
  --chart-5: var(--color-blue-800);

  --sidebar: oklch(0.985 0 0);
  --sidebar-foreground: oklch(0% 0 0);
  --sidebar-primary: oklch(0.205 0 0);
  --sidebar-primary-foreground: oklch(0.985 0 0);
  --sidebar-accent: oklch(0.97 0 0);
  --sidebar-accent-foreground: oklch(0.205 0 0);
  --sidebar-border: oklch(0.922 0 0);
  --sidebar-ring: oklch(0.708 0 0);

  --surface: oklch(0.98 0 0);
  --surface-foreground: var(--foreground);

  --code: var(--surface);
  --code-foreground: var(--surface-foreground);
  --code-highlight: oklch(0.96 0 0);
  --code-number: oklch(0.56 0 0);

  --selection: oklch(0% 0 0);
  --selection-foreground: oklch(1 0 0);
}

.dark {
  --background: oklch(0.145 0 0);
  --foreground: oklch(0.985 0 0);

  --card: oklch(0.205 0 0);
  --card-foreground: oklch(0.985 0 0);

  --popover: oklch(0.205 0 0);
  --popover-foreground: oklch(0.985 0 0);

  --primary: oklch(0.922 0 0);
  --primary-foreground: oklch(0.205 0 0);

  --secondary: oklch(0.269 0 0);
  --secondary-foreground: oklch(0.985 0 0);

  --muted: oklch(0.269 0 0);
  --muted-foreground: oklch(0.708 0 0);

  --accent: oklch(0.371 0 0);
  --accent-foreground: oklch(0.985 0 0);

  --destructive: oklch(0.704 0.191 22.216);
  --destructive-foreground: oklch(0.58 0.22 27);

  --border: oklch(1 0 0 / 10%);
  --input: oklch(1 0 0 / 15%);
  --ring: oklch(0.556 0 0);

  --chart-1: var(--color-blue-300);
  --chart-2: var(--color-blue-500);
  --chart-3: var(--color-blue-600);
  --chart-4: var(--color-blue-700);
  --chart-5: var(--color-blue-800);

  --sidebar: oklch(0.205 0 0);
  --sidebar-foreground: oklch(0.985 0 0);
  --sidebar-primary: oklch(0.488 0.243 264.376);
  --sidebar-primary-foreground: oklch(0.985 0 0);
  --sidebar-accent: oklch(0.269 0 0);
  --sidebar-accent-foreground: oklch(0.985 0 0);
  --sidebar-border: oklch(1 0 0 / 10%);
  --sidebar-ring: oklch(0.439 0 0);

  --surface: oklch(0.2 0 0);
  --surface-foreground: oklch(0.708 0 0);

  --code: var(--surface);
  --code-foreground: var(--surface-foreground);
  --code-highlight: oklch(0.27 0 0);
  --code-number: oklch(0.72 0 0);

  --selection: oklch(0.922 0 0);
  --selection-foreground: oklch(0.205 0 0);
}

@layer base {
  * {
    @apply border-border outline-ring/50;
  }

  body {
    @apply bg-background text-foreground;
  }

  ::selection {
    background-color: var(--selection);
    color: var(--selection-foreground);
  }
}
```

7. Update `app/root.tsx` to include the app stylesheet.

```tsx
import "./app.css";
```

Keep the existing React Router imports, layout, outlet, and error boundary.

8. Update `vite.config.ts` to use the Tailwind Vite plugin.

```ts
import { cloudflare } from "@cloudflare/vite-plugin";
import { reactRouter } from "@react-router/dev/vite";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [
    cloudflare({ viteEnvironment: { name: "ssr" } }),
    tailwindcss(),
    reactRouter(),
  ],
  resolve: {
    tsconfigPaths: true,
  },
});
```

9. Create `app/lib/utils.ts` with the `cn` helper.

```ts
import { clsx, type ClassValue } from "clsx";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}
```

10. Create `components.json` in the project root.

```json
{
  "$schema": "https://ui.shadcn.com/schema.json",
  "style": "base-nova",
  "rsc": false,
  "tsx": true,
  "tailwind": {
    "config": "",
    "css": "app/app.css",
    "baseColor": "neutral",
    "cssVariables": true,
    "prefix": ""
  },
  "rtl": false,
  "aliases": {
    "components": "~/components",
    "utils": "~/lib/utils",
    "ui": "~/components/ui",
    "lib": "~/lib",
    "hooks": "~/hooks"
  },
  "iconLibrary": "lucide"
}
```

11. Add the required shadcn/ui components using the shadcn CLI.

```sh
pnpm dlx shadcn@latest add button
pnpm dlx shadcn@latest add input
pnpm dlx shadcn@latest add label
pnpm dlx shadcn@latest add card
```

Use only `pnpm dlx shadcn@latest` for shadcn/ui component installation. Do not install components with `pnpm shadcn`, `npx shadcn`, or a locally installed `shadcn` binary.

`app/components/ui/button.tsx` must import Button primitives from `@base-ui/react/button`.

`app/components/ui/input.tsx` must import Input primitives from `@base-ui/react/input`.

12. Update `app/routes/home.tsx` to use the Button component.

```tsx
import { Button } from "~/components/ui/button";
import { appContext } from "~/context";
import type { Route } from "./+types/home";

export function meta() {
  return [
    { title: "<project-name>" },
    { name: "description", content: "<project-description>" },
  ];
}

export function loader({ context }: Route.LoaderArgs) {
  const app = context.get(appContext);
  return { message: `Welcome to ${app.cloudflare.env.APP_NAME}` };
}

export default function Home({ loaderData }: Route.ComponentProps) {
  return (
    <main className="mx-auto flex min-h-screen max-w-3xl flex-col items-center justify-center gap-6 px-6 text-center">
      <div className="space-y-3">
        <h1 className="text-4xl font-semibold tracking-tight">
          {loaderData.message}
        </h1>
        <p className="text-muted-foreground">
          Your React Router app is running on Cloudflare Workers.
        </p>
      </div>
      <Button variant="outline">Click me</Button>
    </main>
  );
}
```

## Expected Results

- `tailwindcss` and `@tailwindcss/vite` are installed as development dependencies.
- `class-variance-authority`, `clsx`, `tailwind-merge`, `lucide-react`, `tw-animate-css`, and `@base-ui/react` are installed.
- `tsconfig.json` and `tsconfig.cloudflare.json` keep the `~/*` path alias mapped to `./app/*`.
- `app/app.css` exists with Tailwind, `tw-animate-css`, shadcn/ui theme variables, dark mode variables, and base styles.
- `app/root.tsx` imports `./app.css`.
- `vite.config.ts` imports `tailwindcss` from `@tailwindcss/vite` and includes `tailwindcss()` in the plugin list.
- `app/lib/utils.ts` exists with the `cn` helper.
- `components.json` exists with shadcn/ui aliases that match the `~/*` app path alias.
- The shadcn/ui Button, Input, Label, and Card components exist.
- The Button component imports primitives from `@base-ui/react/button`.
- The Input component imports primitives from `@base-ui/react/input`.
- `app/routes/home.tsx` renders a centered welcome page with a meaningful Button.
