# AGENTS.md

## Product Context

This is a Flutter app for students and photography-oriented English learners.

The app lets users:
- take or upload a photo
- recognize an object
- learn the English word
- listen to US/UK pronunciation
- learn 3 example sentences
- practice read-aloud scoring
- save word history
- generate beautiful shareable word photo cards

The product should feel like a polished English learning camera app, not a raw AI tool.

## Visual Direction

The UI should feel:
- clean
- bright
- literary
- student-friendly
- photography-inspired
- rounded
- card-based
- polished

Avoid:
- enterprise dashboard style
- raw API result layout
- dense forms
- cold gray UI
- tiny icons
- inconsistent spacing
- random colors
- excessive borders

## Design System Rules

- Do not hardcode colors, radius, text styles, or spacing in page widgets.
- Use shared tokens from `lib/core/theme`.
- Use reusable components from `lib/core/widgets`.
- Repeated UI must be extracted into widgets.
- Pages should use clear visual hierarchy.
- Each screen should have one main action.
- All screens must be safe on small Android devices.
- Use friendly Chinese copy for learning feedback.

## Share Card Rules

The share card is not a screenshot of the result page.
It must be a dedicated exportable visual component.

Share cards should feel like:
- postcard
- magazine cover
- film note
- literary photo card

Each share card should include:
- user photo
- English word
- phonetic text if available
- Chinese meaning if enabled
- one selected example sentence
- optional date
- subtle app watermark

## Done Definition

A UI task is done only when:
1. Dart files are formatted.
2. Flutter analyze is run.
3. UI uses design system tokens.
4. No obvious overflow risk exists.
5. Components are reusable.
6. Loading, empty, error, and success states are considered.
7. Codex provides a short UI self-review.