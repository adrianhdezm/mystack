# Auth Routes and Forms

## Route config

Add auth routes to `app/routes.ts` while preserving existing app routes:

```ts
import { type RouteConfig, index, route } from '@react-router/dev/routes';

export default [
  index('routes/home.tsx'),
  route('api/auth/*', 'routes/auth.tsx'),
  route('login', 'routes/login.tsx'),
  route('logout', 'routes/logout.tsx'),
  route('signup', 'routes/signup.tsx')
] satisfies RouteConfig;
```

If the home route or existing route list differs, merge these entries rather
than replacing the full route array.

## Auth API route

Create `app/routes/auth.tsx`:

```tsx
import { appContext } from '~/context';

import type { Route } from './+types/auth';

export function loader({ context, request }: Route.LoaderArgs) {
  const { auth } = context.get(appContext);
  return auth.handler(request);
}

export function action({ context, request }: Route.ActionArgs) {
  const { auth } = context.get(appContext);
  return auth.handler(request);
}
```

## Logout route

Create `app/routes/logout.tsx`:

```tsx
import { redirect } from 'react-router';

import { appContext } from '~/context';

import type { Route } from './+types/logout';

export async function action({ context, request }: Route.ActionArgs) {
  const { auth } = context.get(appContext);
  return auth.api.signOut({ headers: request.headers, asResponse: true });
}

export function loader() {
  return redirect('/login');
}
```

Use a `Form method="post" action="/logout"` for logout buttons or menus.

## Safe redirects

If the app does not already have a safe redirect helper, add one to the existing
utility module, commonly `app/lib/utils.ts`:

```ts
export function safeRedirectTo(to: FormDataEntryValue | string | null | undefined, defaultRedirect = '/') {
  if (!to || typeof to !== 'string') {
    return defaultRedirect;
  }

  if (!to.startsWith('/') || to.startsWith('//')) {
    return defaultRedirect;
  }

  return to;
}
```

Keep any existing `cn` helper intact.

## Login route

Create `app/routes/login.tsx`. Use the project's existing UI imports and app
name. If an icon package is already present, an alert icon is fine; otherwise
render plain text errors.

```tsx
import { useForm } from '@conform-to/react';
import { parseWithZod } from '@conform-to/zod/v4';
import { APIError } from 'better-auth/api';
import { Form, data, redirect, useSearchParams } from 'react-router';
import { z } from 'zod';

import { Button } from '~/components/ui/button';
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from '~/components/ui/card';
import { Input } from '~/components/ui/input';
import { Label } from '~/components/ui/label';
import { appContext } from '~/context';
import { cn, safeRedirectTo } from '~/lib/utils';

import type { Route } from './+types/login';

const schema = z.object({
  email: z.email('Please enter a valid email address'),
  password: z.string(),
  redirectTo: z.string().optional()
});

export async function loader({ context, request }: Route.LoaderArgs) {
  const { auth } = context.get(appContext);
  const session = await auth.api.getSession({ headers: request.headers });
  if (session) {
    return redirect('/');
  }
  return null;
}

export async function action({ context, request }: Route.ActionArgs) {
  const { auth } = context.get(appContext);
  const formData = await request.formData();
  const submission = parseWithZod(formData, { schema });

  if (submission.status !== 'success') {
    return data(submission.reply(), { status: 400 });
  }

  const { email, password, redirectTo } = submission.value;

  try {
    const { headers } = await auth.api.signInEmail({
      returnHeaders: true,
      body: { email, password },
      headers: request.headers
    });

    return redirect(safeRedirectTo(redirectTo), { headers });
  } catch (error) {
    if (error instanceof APIError) {
      return data(
        submission.reply({
          formErrors: ['Incorrect username or password']
        }),
        { status: 400 }
      );
    }
    throw error;
  }
}

export default function Login({ actionData }: Route.ComponentProps) {
  const [searchParams] = useSearchParams();
  const [form, fields] = useForm({
    shouldValidate: 'onBlur',
    lastResult: actionData,
    onValidate({ formData }) {
      return parseWithZod(formData, { schema });
    }
  });

  return (
    <div className="flex min-h-screen items-center justify-center p-4">
      <Form method="post" className="w-full max-w-md" id={form.id} onSubmit={form.onSubmit}>
        <Card>
          <CardHeader className="space-y-1 text-center">
            <CardTitle className="text-2xl font-bold">Welcome back</CardTitle>
            <CardDescription>Log in to your account</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            {form.errors && (
              <div className="rounded-md border border-red-200 bg-red-50 px-4 py-3 text-red-700" role="alert">
                {form.errors}
              </div>
            )}
            <input type="hidden" name="redirectTo" value={searchParams.get('redirectTo') ?? undefined} />
            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                name={fields.email.name}
                type="email"
                placeholder="name@example.com"
                required
                className={cn({
                  'border-red-500 focus-visible:ring-red-500': fields.email.errors
                })}
              />
              {fields.email.errors && <p className="text-sm text-red-500">{fields.email.errors}</p>}
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input id="password" name={fields.password.name} type="password" required className={cn({ 'border-red-500': fields.password.errors })} />
              {fields.password.errors && <p className="text-sm text-red-500">Please enter a valid password</p>}
            </div>
          </CardContent>
          <CardFooter className="flex flex-col space-y-4">
            <Button type="submit" className="w-full">Log in</Button>
            <div className="text-center text-sm">
              <span>Do not have an account? </span>
              <a
                className="text-primary font-semibold"
                href={`/signup${searchParams.get('redirectTo') ? `?redirectTo=${encodeURIComponent(searchParams.get('redirectTo')!)}` : ''}`}
              >
                Sign up
              </a>
            </div>
          </CardFooter>
        </Card>
      </Form>
    </div>
  );
}
```

## Signup route

Create `app/routes/signup.tsx` with the same form structure as login and this
server behavior:

```tsx
const schema = z
  .object({
    name: z.string().min(1, 'Name is required'),
    email: z.email('Please enter a valid email address'),
    password: z.string().min(8, 'Password must be at least 8 characters'),
    confirmPassword: z.string(),
    redirectTo: z.string().optional()
  })
  .refine((data) => data.password === data.confirmPassword, {
    message: 'Passwords do not match',
    path: ['confirmPassword']
  });

export async function loader({ context, request }: Route.LoaderArgs) {
  const { auth } = context.get(appContext);
  const session = await auth.api.getSession({ headers: request.headers });
  if (session) {
    return redirect('/');
  }
  return null;
}

export async function action({ context, request }: Route.ActionArgs) {
  const { auth } = context.get(appContext);
  const formData = await request.formData();
  const submission = parseWithZod(formData, { schema });

  if (submission.status !== 'success') {
    return data(submission.reply(), { status: 400 });
  }

  const { name, email, password, redirectTo } = submission.value;

  try {
    const { headers } = await auth.api.signUpEmail({
      returnHeaders: true,
      body: { name, email, password },
      headers: request.headers
    });

    return redirect(safeRedirectTo(redirectTo), { headers });
  } catch (error) {
    if (error instanceof APIError) {
      return data(
        submission.reply({
          formErrors: ['Could not create account. Please try again.']
        }),
        { status: 400 }
      );
    }
    throw error;
  }
}
```

Build the JSX fields for `name`, `email`, `password`, and `confirmPassword`
using the login route's Conform and shadcn/ui pattern.
