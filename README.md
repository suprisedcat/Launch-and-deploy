# Activity 20 — Deploy Ready

> **🛠️ Stack for this lesson** — Expo SDK 57 / React Native 0.86 + EAS Build · runs in Expo Go on a real phone before the production build.
> 📥 Template: [/learn/m1/template/activity-20-deploy-ready](/learn/m1/template/activity-20-deploy-ready)

A deployment-shaped scaffold: a working demo app, an `eas.json` with the three build profiles, placeholder images in `assets/` and a `verify-setup.sh` check script. Your job is to make it *yours*: replace the images, fill in the identity fields in `app.json`, then build it.

**Time:** about 45 minutes for the core path (TODOs 1 and 2, no build credits needed); the EAS build (TODO 3) is a second sitting · **Concept:** Concept 20 — Launch and Deployment

---

## What You'll Build

| # | Outcome | File |
|---|---------|------|
| 1 | The three images are your own designs: an icon (1024 by 1024), a splash (2048 by 2732) and an adaptive icon | `assets/` |
| 2 | `app.json` carries your real `name`, `slug`, version, description, iOS bundle ID, Android package, permission explanations that give a real reason, and splash and adaptive-icon background colours that you picked | `app.json` |
| 3 | An EAS production build finishes for the platform you can sign for, and you open the result on a device | terminal |

`scripts/generate-assets.sh` derives the three asset sizes from a single source PNG if you have ImageMagick installed. `eas.json` already defines `development`, `preview` and `production` profiles.

## Run It

```bash
npm install --legacy-peer-deps
npm install -g eas-cli
eas login
eas build:configure
```

For a smoke run with your customized app.json before TODO #3:

```bash
npx expo start
```

For TODO #3 itself:

```bash
eas build --profile production --platform <ios or android>
```

Build for the platform you can sign for. The build runs on EAS servers (about 15 to 30 minutes) and the result lands in the EAS dashboard.

## Verify

Your activity is done when:

- [ ] the three images are yours, with no placeholder stripes left
- [ ] `name`, `slug`, bundle ID and package no longer say `My Mobile App` or `com.yourcompany`
- [ ] each permission message names a real reason your app needs it
- [ ] the splash and adaptive-icon background colours are not the default `#4A90E2`
- [ ] the EAS build completes, and you installed and opened it on a real device

## Stretch

Pick one and write what you tried in your Notes Doc:

- **Your theme.** Brand the app for a real or imagined project: a name, a colour pair, an icon idea and a short store description.
- Add a privacy manifest entry for an iOS API your app uses.
- Push a small text change over the air with `eas update` and check that it arrives.
- Set up separate development, staging and production profiles in `eas.json`.

## Show It

In a Notes Doc named `Activity 20 write-up`, answer three prompts: **what I built**, **how I know it works** (name your phone and OS), and **one thing I would change**. Add one AI-use line: "I asked the tutor ___. I decided ___ myself." The lesson page has the full prompts and your Explore question.

## 🪞 Reflect on Your Work

Answer in 2-3 sentences each, in your Notes doc. Your tutor reads these as part of grading.

1. **What did you learn that you didn't know before?** Name the most surprising thing — a bug you hit, a syntax quirk, a way the simulator and real device differ.
2. **How did you collaborate with AI?** If you used Claude / ChatGPT / Cursor / Copilot, what part of the work did *you* contribute — the prompt, the verification, the design decision, the bug-fix? If you didn't use AI, what was the hardest thing to figure out alone?
3. **How do you know your code works?** Describe one specific thing you did to confirm — a test you ran, a screenshot you took, a behavior you watched on the device.

> AI is a great collaborator. Owning your thinking, verifying the output, and explaining your design choices is what *learning* looks like in this course.

## Submit

When the Verify checklist is green, submit the link to your Notes doc, then Mark as Complete.

<!-- claude-template-fix: readme-v3 -->
