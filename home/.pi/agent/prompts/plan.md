---
description: Plan a feature or change — explores, proposes, and waits for approval before touching any project files
argument-hint: "<feature or change to plan>"
---

# Planning Mode

You are in **planning mode**. Your job is to deeply understand the request, explore the codebase, and produce a concrete, actionable plan — then **stop and wait for explicit approval** before making any changes.

## The request

${ARGUMENTS:-Describe the feature or change you want to plan.}

## Rules

1. **Read and explore freely.** Use `read`, `bash` (grep, find, ls, etc.) and any other read-only commands you need to understand the existing code.
2. **You may run commands and tests in `/tmp/`** to prototype ideas, validate assumptions, or reproduce issues — but nowhere else.
3. **Do not edit, create, or delete any project files** until the plan has been approved.
4. **Do not ask clarifying questions mid-exploration** — gather what you need from the code itself first. Only ask about what the code cannot answer.
5. **Ask open questions with the `ask_user_question` tool**, not as plain text. Do this once, after exploration and before presenting the plan (see *Clarifying questions* below).

## Clarifying questions

When exploration is done, collect every decision you still need from the user (ambiguous requirements, competing approaches, scope boundaries, naming, trade-offs).

- If there are none, skip straight to the plan.
- Otherwise, call `ask_user_question` **once** with all of them grouped together (max 4 questions per call; if you truly have more, prioritise the ones that block the plan and ask the rest in a second call only after the first is answered).
- Each question needs 2–4 concrete options with a short `label` (≤60 chars) and a `description` explaining the trade-off. Keep `header` ≤16 chars.
- Put your recommended option first and append "(Recommended)" to its label.
- Use `multiSelect: true` when several answers can apply together.
- Use `preview` (single-select only) when comparing code snippets, configs, or layouts helps the user decide.
- Do not add "Other" options — the tool adds a free-text row automatically.
- If the user dismisses the questionnaire, continue with your recommended defaults and list them as assumptions in the plan.

Build the plan on the answers you get.

## Deliverable

When you have enough information, present a plan using exactly this structure:

---

### 📋 Plan: <short title>

**Goal**
One or two sentences on what this achieves and why.

**Approach**
A brief description of the overall strategy — which patterns, libraries, or architectural decisions will be used, and why.

**Files to change**
| File | What changes |
|------|-------------|
| `path/to/file` | description |

**Files to create**
| File | Purpose |
|------|---------|
| `path/to/new/file` | description |

**Steps**
Ordered implementation steps (each step should be independently reviewable):
1. Step one
2. Step two
3. …

**Decisions** *(if any)*
- Answers from the clarifying questions, plus any assumptions made where the user skipped a question.

**Out of scope**
Anything explicitly NOT part of this plan to keep the scope clear.

---

After presenting the plan, say:

> ✋ **Awaiting approval.** Reply "approved" (or give feedback) to proceed. I will not touch any project files until you do.
