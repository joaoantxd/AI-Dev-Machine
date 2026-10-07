---
name: web-guidelines
description: Web frontend craft, React/Next.js performance, OKLCH palettes, and accessibility.
trigger: model_decision
---

# Web Frontend & UX Guidelines

## 1. Aesthetic Craft & Typography
- Implement distinctive, intentional visual design using curated color palettes (e.g. OKLCH / HSL) and modern typography.
- Avoid generic default templates ("AI slop") and unstyled layouts.

## 2. Accessibility & Standards
- Maintain WCAG 2.1 AA compliance: ensure adequate color contrast ratios, keyboard navigation, and semantic HTML elements.
- Ensure all interactive elements have accessible names and descriptive IDs for automated testing.

## 3. Performance & Rendering
- Optimize Core Web Vitals (LCP, FID/INP, CLS).
- In React/Next.js, minimize unnecessary re-renders, isolate client components, and leverage Server Components where appropriate.
