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
4. **Do not ask clarifying questions mid-exploration** — gather what you need from the code itself, then surface open questions in the plan.

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

**Open questions** *(if any)*
- Questions that require your input before implementation can begin.

**Out of scope**
Anything explicitly NOT part of this plan to keep the scope clear.

---

After presenting the plan, say:

> ✋ **Awaiting approval.** Reply "approved" (or give feedback) to proceed. I will not touch any project files until you do.
