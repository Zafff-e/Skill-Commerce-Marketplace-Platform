# Special Services: Image Prompt Pack (Google Flow)

Covers the 3 featured special services: **Court Companion**, **Hospital & Medical Escort**, **Office & Queue Errands**.
Total: **15 images** (per service: 1 card image, 1 hero image, 3 "typical situation" images).

---

## 0. Read this first

### About SVG
Google Flow generates **raster images** (PNG/JPG), not true SVG. These prompts ask for a **flat vector-illustration style**, so the result looks like SVG art. Recommendation:

- **Keep these scenes as WebP**, not traced SVG. Large multi-colour scenes become heavy and ugly when auto-traced. WebP at the sizes below is about 100-200 KB each.
- If you still want SVG for a *simple* image, run the PNG through Vectorizer.ai or Inkscape (Path > Trace Bitmap) and check the file size. If it exceeds about 300 KB, keep the WebP.

### Workflow that keeps all 15 images looking like one family
1. Generate **Image 1A (Court card)** first. Iterate until the characters and style feel right.
2. For every later image, **attach 1A as a reference image** if Flow offers that option. Also attach **one or two of your own avatars** so the people match your avatar style.
3. Always paste the **full prompt** for the image you want. Do not shorten the style paragraph.
4. Generate 3-4 variations per prompt, pick the best one.
5. Set the aspect ratio in Flow to the one listed. If the exact ratio is not offered, use the closest wider one and crop later.

### Hard rules (already built into every prompt)
- **No text anywhere** in the image: no letters, numbers, signage, logos. The website puts the text on top.
- Palette is fixed: parchment `#F3ECDF`, warm charcoal `#2E2A27`, terracotta `#B5523B`, turmeric `#E0A526`, pond green `#1F3B3A`, dusty sage `#AEBBA0`, blush `#EBC9B6`.
- People are Bangladeshi/South Asian, dressed modestly and realistically. The **helper** is always a calm, kind man or woman in neat everyday clothes with a **blank ID lanyard** (this signals "verified" without any text).
- The helper is a **practical assistant only**. Never show them as a lawyer, doctor or official (no black legal gowns, no white medical coats, no uniforms).

### Shared style (already pasted into each prompt below)
> Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

### Shared avoid list (already pasted into each prompt below)
> Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.

---

## 1. COURT COMPANION (`court-companion`)

### 1A. Card image
**File:** `court-companion.webp` | **Aspect:** 4:3 | **Final size:** 1200x900

```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a kind Bangladeshi man in his 30s wearing a dusty-sage shirt and charcoal trousers, with a blank ID card on a lanyard around his neck, walks beside an elderly Bangladeshi woman in a cream cotton sari with a terracotta border and a light shawl, holding a wooden walking stick. He carries a manila document folder in one hand and gently supports her elbow with the other. They approach a stately courthouse with tall columns and a wide stone staircase; a small balance-scales emblem sits on the pediment (no text). A large turmeric sun disc glows flat behind the building. Warm late-afternoon mood, calm and reassuring.

Composition: the two people in the lower centre-right, courthouse behind them, plenty of breathing room. Keep the bottom 20% of the image calm and low-detail so a caption can sit over it. Aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

### 1B. Hero image
**File:** `court-companion-hero.webp` | **Aspect:** 16:9 | **Final size:** 1920x1080

```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a wide courthouse courtyard in warm morning light. On the right half, a stately courthouse with tall columns and a broad staircase, flanked by two paper-cut trees in pond green. A kind Bangladeshi helper in his 30s (sage shirt, charcoal trousers, blank ID lanyard, manila folder) walks with an elderly woman in a cream sari with a terracotta border toward the steps. A few small figures of other visitors wait near the stairs. A dashed running-stitch path in turmeric leads from the lower left toward the building.

Composition: the LEFT 45% of the image must be calm and mostly empty (soft parchment and a few gentle shapes) because website text will sit on top. All detail and subjects live in the right 55%. Keep the lower-right corner slightly simpler. Wide cinematic framing, aspect ratio 16:9.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

### 1C. Situation images (3)

**1C-1** `court-companion-situation-1.webp` | 4:3 | 800x600 | *Holding your place in line*
```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a long courthouse corridor with arched windows and a wooden bench along the wall. An elderly Bangladeshi woman in a cream sari rests comfortably on the bench with a small water bottle. A kind Bangladeshi helper in his 30s (sage shirt, blank ID lanyard) stands in the queue ahead of her holding a manila folder and a paper slip, looking back at her with a reassuring smile. Four other people wait in the line in muted clothing. A round wall clock without numerals hangs above.

Composition: centred, medium-wide, aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

**1C-2** `court-companion-situation-2.webp` | 4:3 | 800x600 | *Submitting documents*
```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a court clerk's service window with a wooden counter and a brass-coloured grille. A kind Bangladeshi helper in his 30s (sage shirt, blank ID lanyard) hands a neat stack of stapled papers and a manila folder through the window to a clerk whose face is partly visible, wearing a plain shirt. Stacks of file bundles tied with red cloth fill the shelves behind the clerk. A rubber stamp and an ink pad sit on the counter.

Composition: close-medium framing from slightly to the side, aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

**1C-3** `court-companion-situation-3.webp` | 4:3 | 800x600 | *Never alone on court day*
```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a courthouse staircase. An elderly Bangladeshi man in a white panjabi and a prayer cap climbs the steps slowly with a wooden stick while a kind Bangladeshi helper in his 30s (sage shirt, blank ID lanyard) walks one step below him, one hand ready near his back, carrying a folder in the other. Soft warm sunlight, tall columns on the left, a paper-cut tree on the right.

Composition: three-quarter view, aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

---

## 2. HOSPITAL & MEDICAL ESCORT (`hospital-escort`)

### 2A. Card image
**File:** `hospital-escort.webp` | **Aspect:** 4:3 | **Final size:** 1200x900

```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a kind Bangladeshi woman helper in her 30s wearing a dusty-sage salwar kameez with a blank ID card on a lanyard gently pushes a wheelchair carrying an elderly Bangladeshi man in a white panjabi with a light blanket on his lap. She carries a bag of medical report folders on her shoulder. They move toward the glass entrance of a hospital building marked only by a large terracotta cross symbol (no text). A small flat ambulance silhouette sits in the background. Calm, caring, reassuring mood.

Composition: subjects in the lower centre-right, hospital entrance behind, bottom 20% calm and low-detail for a caption overlay. Aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

### 2B. Hero image
**File:** `hospital-escort-hero.webp` | **Aspect:** 16:9 | **Final size:** 1920x1080

```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a wide view of a modern but modest hospital building on the right half, with a wheelchair ramp, glass doors and a large terracotta cross symbol on the facade (no text). In front, a kind Bangladeshi woman helper in her 30s (sage salwar kameez, blank ID lanyard) pushes an elderly man in a white panjabi in a wheelchair along a dashed turmeric running-stitch path toward the ramp. A green-roofed rickshaw and a small CNG auto wait at the kerb. Two paper-cut trees in pond green frame the scene.

Composition: the LEFT 45% of the image must be calm and mostly empty (soft parchment and a few gentle shapes) because website text will sit on top. All detail and subjects live in the right 55%. Wide cinematic framing, aspect ratio 16:9.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

### 2C. Situation images (3)

**2C-1** `hospital-escort-situation-1.webp` | 4:3 | 800x600 | *Through the corridors*
```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a long, bright hospital corridor with floor markings as simple coloured stripes (terracotta and sage lines leading to different departments, shown only as shapes and icons, no text). A kind Bangladeshi helper in her 30s (sage salwar kameez, blank ID lanyard) walks beside an elderly woman in a cream sari who uses a walking stick, holding her arm gently. Simple pictogram icons on the walls: a heart, a bone, an eye (no letters).

Composition: one-point perspective down the corridor, aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

**2C-2** `hospital-escort-situation-2.webp` | 4:3 | 800x600 | *Registration and reports*
```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a hospital registration counter. A kind Bangladeshi helper in her 30s (sage salwar kameez, blank ID lanyard) stands at the counter handing a folder of reports to a receptionist in a plain blouse. Behind her, on a waiting-room chair, an elderly Bangladeshi man in a white panjabi sits calmly with his hands on his knees, relaxed, watching her. A water dispenser and a potted plant sit in the corner.

Composition: medium shot slightly from the side, aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

**2C-3** `hospital-escort-situation-3.webp` | 4:3 | 800x600 | *Pharmacy and the ride home*
```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a pharmacy counter with shelves of boxes shown as plain coloured rectangles and a terracotta cross symbol above (no text). A kind Bangladeshi helper in her 30s (sage salwar kameez, blank ID lanyard) receives a small paper bag of medicines from the pharmacist, while an elderly man in a white panjabi waits just behind her holding a walking stick, smiling. Through the open door on the right, a rickshaw waits outside in warm light.

Composition: medium-wide, aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

---

## 3. OFFICE & QUEUE ERRANDS (`office-errands`)

### 3A. Card image
**File:** `office-errands.webp` | **Aspect:** 4:3 | **Final size:** 1200x900

```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: inside a busy government service office. A kind Bangladeshi man in his 30s (sage shirt, charcoal trousers, blank ID lanyard) stands patiently in a queue holding a manila folder and a paper token slip, looking calm and prepared. Behind him, five other people wait in line in muted clothing, some fanning themselves with papers. Ahead is a service counter with a glass window and a round wall clock without numerals. A ceiling fan turns overhead.

Composition: subject in the lower centre-right, the queue curving back into the room, bottom 20% calm and low-detail for a caption overlay. Aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

### 3B. Hero image
**File:** `office-errands-hero.webp` | **Aspect:** 16:9 | **Final size:** 1920x1080

```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a wide street view of a government office building on the right half, a long snaking queue of people spilling out of its doors and along the pavement under a flat turmeric awning. A kind Bangladeshi helper in his 30s (sage shirt, blank ID lanyard, manila folder) stands near the front of the queue, relaxed. Across the road, a small paper-cut rickshaw and a tea stall. Two paper-cut trees in pond green frame the scene.

Composition: the LEFT 45% of the image must be calm and mostly empty (soft parchment and a few gentle shapes) because website text will sit on top. All detail and subjects live in the right 55%. Wide cinematic framing, aspect ratio 16:9.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

### 3C. Situation images (3)

**3C-1** `office-errands-situation-1.webp` | 4:3 | 800x600 | *Waiting so you do not have to*
```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: split composition. On the left, a Bangladeshi woman in a blush-coloured sari relaxes at home on a sofa with a cup of tea. On the right, a kind Bangladeshi helper in his 30s (sage shirt, blank ID lanyard) waits in a bank queue holding a folder. A dashed turmeric running-stitch line joins the two halves like a thread.

Composition: two-panel composition in one image, aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

**3C-2** `office-errands-situation-2.webp` | 4:3 | 800x600 | *Submitting your papers*
```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a government office counter with a glass window. A kind Bangladeshi helper in his 30s (sage shirt, blank ID lanyard) slides a neatly arranged set of forms, a photograph and a copied identity card (shown as plain blank rectangles with a small portrait silhouette) under the window to an officer in a plain shirt. An open stapler, a stamp pad and a pen cup sit on the counter.

Composition: close-medium framing, aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

**3C-3** `office-errands-situation-3.webp` | 4:3 | 800x600 | *Delivered to your door*
```text
Flat vector illustration with a hand-cut paper-collage feel. Clean shapes with slightly irregular edges, subtle paper-grain texture, thin warm-charcoal ink outlines, and small dashed running-stitch details like nakshi kantha embroidery. Warm muted palette only: parchment cream #F3ECDF, warm charcoal #2E2A27, terracotta #B5523B, turmeric #E0A526, deep pond green #1F3B3A, dusty sage #AEBBA0, blush #EBC9B6. Soft flat shading only. No 3D, no gloss, no glow, no photorealism.

Scene: a doorstep in a residential building with a wooden door and a potted plant. A kind Bangladeshi helper in his 30s (sage shirt, blank ID lanyard) hands a sealed envelope and a stamped document to a smiling Bangladeshi woman in a blush sari who stands in the doorway. A small checkmark-shaped stamp in terracotta sits on the envelope (a shape, not a letter). Warm evening light from the stairwell window.

Composition: medium shot, aspect ratio 4:3.

Avoid: any text, letters, numbers, signage, logos, watermarks; purple, violet, neon or bright blue colours; glossy 3D; stock-photo look; distorted hands or faces; lawyer gowns, doctor coats, uniforms.
```

---

## 4. File checklist

| # | File (in `public/images/special/`) | Ratio | Final size |
|---|-----------------------------------|-------|------------|
| 1 | `court-companion.webp` | 4:3 | 1200x900 |
| 2 | `court-companion-hero.webp` | 16:9 | 1920x1080 |
| 3-5 | `court-companion-situation-1..3.webp` | 4:3 | 800x600 |
| 6 | `hospital-escort.webp` | 4:3 | 1200x900 |
| 7 | `hospital-escort-hero.webp` | 16:9 | 1920x1080 |
| 8-10 | `hospital-escort-situation-1..3.webp` | 4:3 | 800x600 |
| 11 | `office-errands.webp` | 4:3 | 1200x900 |
| 12 | `office-errands-hero.webp` | 16:9 | 1920x1080 |
| 13-15 | `office-errands-situation-1..3.webp` | 4:3 | 800x600 |

**Spec delta for the build agent:** `LANDING_PAGE_AGENT_SPEC.md` section 5.2 and 9.7 mention only `special/{slug}.webp`. For special services use `{slug}.webp` for the landing **card**, `{slug}-hero.webp` for the **/special/:slug hero**, and `{slug}-situation-{1..3}.webp` for the "Typical situations" list. This file takes priority for special-service images.

## 5. Quality check before you accept an image
- [ ] No text, numbers or logos anywhere (zoom in on walls, clocks, signs, papers).
- [ ] Only the palette colours; no purple, violet or neon.
- [ ] Hands and faces look natural; the helper has a blank ID lanyard; nobody wears a gown, coat or uniform.
- [ ] Hero: the left 45% is calm enough for white or dark text. Card: the bottom 20% is calm.
- [ ] Same helper look and same style across the set. If one image drifts, regenerate with 1A attached as reference.

## 6. Convert after generating
Put the originals in `public/images/special-src/`, then ask the build agent to add `scripts/build-images.mjs` (using `sharp`) that resizes each file to the sizes above and writes quality-80 WebP into `public/images/special/`.
