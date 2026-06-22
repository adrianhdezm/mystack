# 02 - Legal Content

## Important

Legal text must be provided by the user or reviewed by them before going live. This reference provides structural guidance only — it does not supply ready-made legal text. Fill the content blocks with the information collected from the user.

## Impressum

Required for operators based in Germany, Austria, and Switzerland (Impressumspflicht). Include at minimum:

- Full name of the responsible individual or company
- Full postal address (street, city, postal code, country)
- Contact email address
- Phone number (required in Germany)
- VAT ID or trade register number (if applicable)
- Responsible person for editorial content (if the product publishes editorial content)

```tsx
export default function ImpressumPage() {
  return (
    <div className="container max-w-3xl py-16">
      <h1 className="mb-8 text-3xl font-bold">Impressum</h1>
      <div className="prose prose-neutral dark:prose-invert">
        <h2>Angaben gemäß § 5 TMG</h2>
        <p>
          {/* OPERATOR_NAME */}
          <br />
          {/* Street, House Number */}
          <br />
          {/* Postal Code, City */}
          <br />
          {/* Country */}
        </p>
        <h2>Kontakt</h2>
        <p>
          E-Mail: {/* OPERATOR_EMAIL */}
          <br />
          Telefon: {/* Phone number */}
        </p>
        {/* Add VAT ID section if applicable */}
      </div>
    </div>
  );
}
```

Use the `prose` Tailwind plugin class for readable legal text typography. If `@tailwindcss/typography` is not installed, use `space-y-4 text-sm leading-relaxed text-muted-foreground` instead.

## Privacy Policy

Structure the Privacy Policy to cover at minimum:

1. Who is responsible for data processing (controller)
2. What personal data is collected and why
3. Legal basis for processing (GDPR Art. 6 if applicable)
4. Data retention periods
5. User rights (access, correction, deletion, portability)
6. Whether cookies or analytics tools are used
7. Contact for data protection inquiries

```tsx
export default function PrivacyPolicyPage() {
  return (
    <div className="container max-w-3xl py-16">
      <h1 className="mb-8 text-3xl font-bold">Privacy Policy</h1>
      <div className="prose prose-neutral dark:prose-invert">
        <p className="text-sm text-muted-foreground">
          Last updated: {/* date */}
        </p>
        <h2>1. Controller</h2>
        <p>
          {/* OPERATOR_NAME */}, {/* OPERATOR_ADDRESS */}
          <br />
          Contact: {/* OPERATOR_EMAIL */}
        </p>
        <h2>2. Data We Collect</h2>
        <p>{/* Describe data collected — e.g. email, name, usage data */}</p>
        <h2>3. Purpose and Legal Basis</h2>
        <p>{/* Purpose of processing and legal basis */}</p>
        <h2>4. Your Rights</h2>
        <p>{/* Rights under GDPR or applicable law */}</p>
        {/* Add remaining sections as needed */}
      </div>
    </div>
  );
}
```

## Terms of Service

Structure Terms of Service to cover at minimum:

1. Who provides the service (operator details)
2. What the service is and who may use it
3. User obligations and prohibited conduct
4. Intellectual property
5. Limitation of liability
6. Governing law and jurisdiction
7. How to contact the operator

```tsx
export default function TermsPage() {
  return (
    <div className="container max-w-3xl py-16">
      <h1 className="mb-8 text-3xl font-bold">Terms of Service</h1>
      <div className="prose prose-neutral dark:prose-invert">
        <p className="text-sm text-muted-foreground">
          Last updated: {/* date */}
        </p>
        <h2>1. Provider</h2>
        <p>
          {/* OPERATOR_NAME */}
          <br />
          {/* OPERATOR_ADDRESS */}
          <br />
          {/* OPERATOR_EMAIL */}
        </p>
        <h2>2. Scope</h2>
        <p>{/* Describe the service and who may use it */}</p>
        {/* Add remaining sections as needed */}
      </div>
    </div>
  );
}
```

## Reminder

Remind the user in the commit message and `AGENTS.md` that legal content must be reviewed before the product goes live. The skill creates the structure; the operator owns the content.
