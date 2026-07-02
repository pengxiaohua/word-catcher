---
name: flutter-share-card
description: Use this skill when implementing the shareable word photo card feature, share card templates, export image logic, and social sharing UI.
---

You are a Flutter engineer and visual designer implementing a shareable word photo card feature.

## Feature Goal

Users can turn a recognized photo and English word into a beautiful shareable image card, like a literary postcard or travel photo card.

## Product Context

The card should be generated from:
- user photo
- English word
- phonetic text
- Chinese meaning
- one selected example sentence
- optional date
- optional app watermark

## Important Rule

The share card must be a dedicated visual component. Do not simply screenshot the result page.

## Templates

Implement a flexible template system.

Start with 3 templates:

1. Postcard Template
   - photo on top
   - white lower content area
   - word, phonetic, meaning, sentence
   - literary postcard style

2. Magazine Template
   - full photo background
   - large English word overlay
   - short sentence as subtitle
   - high visual impact

3. Film Note Template
   - photo with film or polaroid-like frame
   - small labels
   - warm, personal, photography-inspired style

## Suggested Structure

Create or update:

- `features/share_card/models/share_card_data.dart`
- `features/share_card/models/share_card_template.dart`
- `features/share_card/pages/share_card_editor_page.dart`
- `features/share_card/widgets/share_card_preview.dart`
- `features/share_card/widgets/postcard_template.dart`
- `features/share_card/widgets/magazine_template.dart`
- `features/share_card/widgets/film_template.dart`
- `features/share_card/widgets/template_selector.dart`
- `features/share_card/services/share_card_export_service.dart`

## UI Requirements

The editor page should include:
- card preview
- template selector
- display options
- save button
- share button

Display options:
- show/hide Chinese meaning
- show/hide phonetic text
- show/hide sentence
- show/hide date
- show/hide watermark

## Export Requirements

Export the card as an image suitable for social sharing.
Keep export logic isolated in a service.
Avoid coupling export logic to the result page.

## Final Review

After implementation, check:
1. Is the card beautiful enough to share?
2. Does it feel like a postcard, not an app screenshot?
3. Is the feature modular?
4. Can more templates be added later?
5. Does it preserve good image quality?
6. Are permissions and failure states handled?