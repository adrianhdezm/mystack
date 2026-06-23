# 03 - Vite, Linting, and Formatting

## Steps

1. Check the latest Prettier and Prettier plugin package versions, then install Prettier as an exact dependency and the plugins with `@latest`.

```sh
pnpm view prettier version
pnpm view @trivago/prettier-plugin-sort-imports version
pnpm view prettier-plugin-tailwindcss version
pnpm add -D --save-exact prettier@latest
pnpm add -D @trivago/prettier-plugin-sort-imports@latest prettier-plugin-tailwindcss@latest
```

2. Create `.prettierrc` with this configuration.

```json
{
  "singleQuote": true,
  "printWidth": 140,
  "trailingComma": "none",
  "importOrder": [
    "^~/routes/(.*)$",
    "^~/components/(.*)$",
    "^~/(.*)$",
    "^@/(.*)$",
    "^[./]"
  ],
  "importOrderSeparation": true,
  "importOrderSortSpecifiers": true,
  "plugins": [
    "@trivago/prettier-plugin-sort-imports",
    "prettier-plugin-tailwindcss"
  ]
}
```

3. Add the `format` script to `package.json`.

```json
{
  "scripts": {
    "format": "prettier --write ."
  }
}
```

4. Check the latest Vite package version and confirm it is at least version 8 before installing.

```sh
pnpm view vite version
pnpm add -D vite@latest
```

5. Create `vite.config.ts` with this content:

```ts
import { defineConfig } from "vite";

export default defineConfig({
  plugins: [],
  resolve: {
    tsconfigPaths: true,
  },
});
```

6. Check and install the latest linting packages. Pin `eslint` and `@eslint/js` to `^9` — do not install v10 or higher.

```sh
pnpm view @eslint/js version
pnpm view eslint version
pnpm view eslint-config-prettier version
pnpm view eslint-plugin-jsx-a11y version
pnpm view eslint-plugin-prettier version
pnpm view eslint-plugin-react version
pnpm view eslint-plugin-react-hooks version
pnpm view globals version
pnpm view typescript-eslint version
pnpm add -D @eslint/js@^9 eslint@^9 eslint-config-prettier@latest eslint-plugin-jsx-a11y@latest eslint-plugin-prettier@latest eslint-plugin-react@latest eslint-plugin-react-hooks@latest globals@latest typescript-eslint@latest @types/eslint-plugin-jsx-a11y@latest
```

7. Create `eslint.config.js` with this content:

```js
import js from "@eslint/js";
import pluginjsxA11y from "eslint-plugin-jsx-a11y";
import pluginPrettierRecommended from "eslint-plugin-prettier/recommended";
import pluginReact from "eslint-plugin-react";
import pluginReactHooks from "eslint-plugin-react-hooks";
import { defineConfig } from "eslint/config";
import globals from "globals";
import tseslint from "typescript-eslint";

export default defineConfig([
  {
    ignores: [
      "**/.cache/**",
      "**/node_modules/**",
      "**/build/**",
      "**/public/**",
      "**/*.json",
      "**/coverage/**",
      "**/*.tsbuildinfo",
      "**/.react-router/**",
      "**/.wrangler/**",
      "**/worker-configuration.d.ts",
      "eslint.config.js",
    ],
  },
  {
    files: ["**/*.{js,mjs,cjs,ts,jsx,tsx}"],
    plugins: { js },
    extends: ["js/recommended"],
  },
  { files: ["**/*.js"], languageOptions: { sourceType: "script" } },
  {
    files: ["**/*.{js,mjs,cjs,ts,mts,cts,jsx,tsx}"],
    settings: {
      react: {
        version: "detect",
      },
    },
    languageOptions: {
      globals: { ...globals.browser, ...globals.node, React: true },
    },
  },
  tseslint.configs.recommendedTypeChecked,
  {
    languageOptions: {
      parserOptions: {
        projectService: {
          defaultProject: "tsconfig.json",
        },
        tsconfigRootDir: import.meta.dirname,
        sourceType: "module",
      },
    },
  },
  pluginReact.configs.flat.recommended,
  pluginReact.configs.flat["jsx-runtime"],
  pluginReactHooks.configs.flat.recommended,
  pluginjsxA11y.flatConfigs.recommended,
  pluginPrettierRecommended,
  // React Router loaders/actions throw Response objects for redirects and error handling,
  // which violates @typescript-eslint/only-throw-error expecting only Error instances.
  {
    files: ["app/routes/**/*.tsx"],
    rules: {
      "@typescript-eslint/only-throw-error": "off",
    },
  },
  // shadcn/ui generated components render generic wrapper elements that cannot satisfy
  // jsx-a11y/label-has-associated-control at the definition site.
  {
    files: ["app/components/ui/**/*.tsx"],
    rules: {
      "jsx-a11y/label-has-associated-control": "off",
    },
  },
  {
    rules: {
      curly: "error",
      "no-unused-vars": "off",
      "@typescript-eslint/consistent-type-imports": [
        "error",
        { prefer: "type-imports", fixStyle: "inline-type-imports" },
      ],
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          destructuredArrayIgnorePattern: "^_",
          ignoreRestSiblings: true,
        },
      ],
    },
  },
]);
```

8. Add the `lint` script to `package.json`.

```json
{
  "scripts": {
    "lint": "eslint ."
  }
}
```

## Expected Results

- `prettier`, `@trivago/prettier-plugin-sort-imports`, and `prettier-plugin-tailwindcss` are installed as development dependencies.
- `.prettierrc` exists with single quotes, 140-column print width, no trailing commas, ordered imports, and Tailwind class sorting enabled.
- `vite` at least version 8 is installed as a development dependency.
- `vite.config.ts` exists with an empty plugin list and `resolve.tsconfigPaths` enabled.
- `@eslint/js` (v9), `eslint` (v9), `eslint-config-prettier`, `eslint-plugin-jsx-a11y`, `eslint-plugin-prettier`, `eslint-plugin-react`, `eslint-plugin-react-hooks`, `globals`, `typescript-eslint`, and `@types/eslint-plugin-jsx-a11y` are installed as development dependencies.
- `eslint.config.js` exists with React, React Hooks, JSX accessibility, TypeScript, and Prettier recommended configuration.
- `eslint.config.js` disables `@typescript-eslint/only-throw-error` for `app/routes/**/*.tsx` and `jsx-a11y/label-has-associated-control` for `app/components/ui/**/*.tsx`.
- `package.json` includes `format` and `lint` scripts.
