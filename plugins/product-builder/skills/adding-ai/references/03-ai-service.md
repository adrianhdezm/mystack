# 03 - AI Service

## Steps

1. Create `app/services/ai.service.ts`.

Use the repository's existing import style. Keep the service server-only; do not import it from client components.

```ts
import { createOpenAI } from "@ai-sdk/openai";

export class AIService {
  private readonly openai: ReturnType<typeof createOpenAI>;
  private readonly modelId: string;
  private readonly imageModelId: string;

  constructor(
    apiKey: string,
    openaiModelId: string,
    openaiImageModelId: string,
  ) {
    this.openai = createOpenAI({ apiKey });
    this.modelId = openaiModelId;
    this.imageModelId = openaiImageModelId;
  }

  get model() {
    return this.openai(this.modelId);
  }

  get imageModel() {
    return this.openai.image(this.imageModelId);
  }
}
```

## Implementation Notes

- `AIService` is the single boundary for all AI SDK usage. Routes call service methods, never the SDK directly.
- AI SDK imports (`generateText`, `streamText`, `generateImage`, `Output`) must only appear inside `ai.service.ts`.
- Model IDs are configured via `OPENAI_MODEL_ID` and `OPENAI_IMAGE_MODEL_ID` environment variables in `wrangler.jsonc`, not hardcoded in source.
- The foundation skill creates the base service with provider configuration and model getters. Feature implementations extend the service with domain-specific methods that use the SDK internally.
- The service can be extended with additional providers later by adding more properties.

## Extending the Service

Feature implementations add domain-specific methods to `AIService`. Each method uses AI SDK functions internally and exposes a clean interface to routes.

### Text generation

```ts
// in ai.service.ts
import { createOpenAI } from "@ai-sdk/openai";
import { generateText } from "ai";

export class AIService {
  // ... constructor and model getters

  async generateText(prompt: string) {
    const { text } = await generateText({
      model: this.model,
      prompt,
    });
    return text;
  }
}
```

```ts
// in a route action
const text = await ai.generateText("What is love?");
```

### Structured output

```ts
// in ai.service.ts
import { generateText, Output } from "ai";
import { z } from "zod";

const characterSchema = z.object({
  name: z.string(),
  age: z.number(),
});

export type Character = z.infer<typeof characterSchema>;

export class AIService {
  // ... constructor and model getters

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

```ts
// in a route action
const character = await ai.generateCharacter("Generate a hero.");
```

### Image generation

```ts
// in ai.service.ts
import { generateImage } from "ai";

export class AIService {
  // ... constructor and model getters

  async generateImage(prompt: string, size = "1024x1024") {
    const { image } = await generateImage({
      model: this.imageModel,
      prompt,
      size,
    });
    return image;
  }
}
```

```ts
// in a route action
const image = await ai.generateImage("A sunset over mountains.");
```

### Streaming text

```ts
// in ai.service.ts
import { streamText } from "ai";

export class AIService {
  // ... constructor and model getters

  streamText(prompt: string) {
    return streamText({
      model: this.model,
      prompt,
    });
  }
}
```

```ts
// in a route action
const { textStream } = ai.streamText("Tell me a story.");
```

### Image editing

In Cloudflare Workers there is no `fs` — read image bytes from the request body, a fetch response, or R2 (when `adding-file-storage` is present).

```ts
// in ai.service.ts
import { generateImage } from "ai";

export class AIService {
  // ... constructor and model getters

  async editImage(imageData: Uint8Array, prompt: string) {
    const { image } = await generateImage({
      model: this.imageModel,
      prompt: {
        text: prompt,
        images: [imageData],
      },
    });
    return image;
  }
}
```

```ts
// in a route action
const formData = await request.formData();
const file = formData.get("image") as File;
const imageData = new Uint8Array(await file.arrayBuffer());
const image = await ai.editImage(imageData, "Turn the cat into a dog");
```

### Inpainting with mask

Transparent areas in the mask indicate where the image should be edited.

```ts
// in ai.service.ts
import { generateImage } from "ai";

export class AIService {
  // ... constructor and model getters

  async inpaint(imageData: Uint8Array, maskData: Uint8Array, prompt: string) {
    const { image } = await generateImage({
      model: this.imageModel,
      prompt: {
        text: prompt,
        images: [imageData],
        mask: maskData,
      },
    });
    return image;
  }
}
```

```ts
// in a route action
const formData = await request.formData();
const file = formData.get("image") as File;
const mask = formData.get("mask") as File;
const imageData = new Uint8Array(await file.arrayBuffer());
const maskData = new Uint8Array(await mask.arrayBuffer());
const image = await ai.inpaint(
  imageData,
  maskData,
  "Add a flamingo to the pool",
);
```

### Background removal

```ts
// in ai.service.ts
import { generateImage } from "ai";
import type { OpenAIImageModelEditOptions } from "@ai-sdk/openai";

export class AIService {
  // ... constructor and model getters

  async removeBackground(imageData: Uint8Array) {
    const { image } = await generateImage({
      model: this.imageModel,
      prompt: {
        text: "do not change anything",
        images: [imageData],
      },
      providerOptions: {
        openai: {
          background: "transparent",
          outputFormat: "png",
        } satisfies OpenAIImageModelEditOptions,
      },
    });
    return image;
  }
}
```

```ts
// in a route action
const formData = await request.formData();
const file = formData.get("image") as File;
const imageData = new Uint8Array(await file.arrayBuffer());
const image = await ai.removeBackground(imageData);
```

### Multi-image combining

Supports up to 16 input images. Each image must be a png, webp, or jpg under 50 MB.

```ts
// in ai.service.ts
import { generateImage } from "ai";

export class AIService {
  // ... constructor and model getters

  async combineImages(images: Uint8Array[], prompt: string) {
    const { image } = await generateImage({
      model: this.imageModel,
      prompt: {
        text: prompt,
        images,
      },
    });
    return image;
  }
}
```

```ts
// in a route action
const formData = await request.formData();
const files = formData.getAll("images") as File[];
const images = await Promise.all(
  files.map(async (file) => new Uint8Array(await file.arrayBuffer())),
);
const image = await ai.combineImages(images, "Combine into a group photo");
```

Input images can be provided as `Uint8Array`, `ArrayBuffer`, or base64-encoded strings. When `adding-file-storage` is present, images can also be read from R2 via the files service.

### Convention

These examples show how to extend the service during feature implementation. The foundation skill only creates the base service with provider configuration and model getters. Domain-specific methods are added as features require them. Document each new method in `docs/conventions/ai-service.md`.

## Expected Results

- `app/services/ai.service.ts` exports `AIService` with a configured OpenAI provider.
- The service is a thin wrapper that does not duplicate AI SDK functionality.
