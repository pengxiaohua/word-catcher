# WordCatcher / 词光里

WordCatcher is a Flutter MVP for photo-based object recognition and
multilingual vocabulary learning.

## Flutter App

The app currently includes:

- photo capture / gallery picking with `image_picker`
- API layer with `dio`
- scan state management with Riverpod
- result card with word, UK/US phonetics, audio playback hooks, translation,
  and three bilingual examples
- long-press shadowing recording skeleton with `record`
- history vocabulary page and dictation test flow

Run in local mock mode:

```bash
flutter run
```

Run against the Next.js service:

```bash
flutter run \
  --dart-define=WORD_CATCHER_USE_MOCK_API=false \
  --dart-define=WORD_CATCHER_API_BASE_URL=http://localhost:3000
```

For Android emulator, use `http://10.0.2.2:3000` as the API base URL.
For a physical iPhone, run the service on your Mac with `npm run dev -- -H
0.0.0.0`, find your Mac IP with `ipconfig getifaddr en0`, then use
`http://<MAC_IP>:3000` as the API base URL.

## Backend Service

The Next.js backend lives next to this Flutter project:
`../word-catcher-service`.

It contains:

- `prisma/schema.prisma`
- `lib/prisma.ts`
- `app/api/analyze-image/route.ts`
- `app/api/history/route.ts`
- mock TTS and Qwen Vision LLM integration
- reserved Alibaba Cloud OSS adapter in `lib/oss.ts`

Setup:

```bash
cd ../word-catcher-service
cp .env.example .env
npm install
npx prisma generate
npx prisma migrate dev --name init
npm run dev
```

Set `MOCK_AI=false`, configure `QWEN_API_KEY`, `MINIMAX_API_SECRET`, and OSS in
the service `.env` when you are ready to call real recognition and TTS services.
