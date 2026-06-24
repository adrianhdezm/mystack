# 03 - AI Service (SAP AI Core)

## Steps

1. Create `app/services/ai.service.ts`.

Use the repository's existing import style. Keep the service server-only; do not import it from client components.

```ts
import { createSapAiCoreProvider } from "@ai-foundry/sap-aicore-provider";
import type { LanguageModel } from "ai";

export class AIService {
  private readonly provider: ReturnType<typeof createSapAiCoreProvider>;
  private readonly modelId: string;

  constructor(
    baseUrl: string,
    accessTokenUrl: string,
    clientId: string,
    clientSecret: string,
    modelId: string,
    resourceGroup?: string,
  ) {
    this.provider = createSapAiCoreProvider({
      baseUrl,
      accessTokenUrl,
      clientId,
      clientSecret,
      ...(resourceGroup ? { resourceGroup } : {}),
    });
    this.modelId = modelId;
  }

  get model(): LanguageModel {
    return this.provider(this.modelId);
  }
}
```

## Implementation Notes

- SAP AI Core does not support image generation. Do not add an `imageModel` getter.
- `AIService` is the single boundary for all AI SDK usage. Routes call service methods, never the SDK directly.
- AI SDK imports (`generateText`, `streamText`, `Output`) must only appear inside `ai.service.ts`.
- The provider caches OAuth tokens internally until expiration — no manual token management is needed.
- The foundation skill creates the base service with provider configuration and model getter. Feature implementations extend the service with domain-specific methods.

## Extending the Service

Feature implementations add domain-specific methods to `AIService`. Each method uses AI SDK functions internally and exposes a clean interface to routes.

### Text generation

```ts
import { createSapAiCoreProvider } from "@ai-foundry/sap-aicore-provider";
import { generateText } from "ai";

export class AIService {
  // ... constructor and model getter

  async generateText(prompt: string) {
    const { text } = await generateText({
      model: this.model,
      prompt,
    });
    return text;
  }
}
```

### Structured output

```ts
import { generateText, Output } from "ai";
import { z } from "zod";

const characterSchema = z.object({
  name: z.string(),
  age: z.number(),
});

export type Character = z.infer<typeof characterSchema>;

export class AIService {
  // ... constructor and model getter

  async generateCharacter(prompt: string): Promise<Character> {
    const { output } = await generateText({
      model: this.model,
      output: Output.object({ schema: characterSchema }),
      prompt,
    });
    return output;
  }
}
```

### Streaming text

```ts
import { streamText } from "ai";

export class AIService {
  // ... constructor and model getter

  streamText(prompt: string) {
    return streamText({
      model: this.model,
      prompt,
    });
  }
}
```

### Convention

These examples show how to extend the service during feature implementation. The foundation skill only creates the base service with provider configuration and model getter. Domain-specific methods are added as features require them. Document each new method in `docs/conventions/ai-service.md`.

## Expected Results

- `app/services/ai.service.ts` exports `AIService` with a configured SAP AI Core provider.
- The service has no `imageModel` getter.
- The service is a thin wrapper that does not duplicate AI SDK functionality.
