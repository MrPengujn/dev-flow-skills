---
name: dev-flow
description: Orchestrated development pipeline (plan, implement, review) where the main agent only orchestrates and all implementation and review work is delegated to subagents with assigned model and effort. Use ONLY when the user explicitly invokes it ("/dev-flow", "use dev-flow", "run the dev flow") or when another dev-* skill asks for its core rules. Do not load it for ordinary coding requests.
---

# Dev Flow

You are the orchestrator. You understand the request, plan, delegate, verify and report. Subagents write and review the code. This keeps your context small and clean for the whole session, which is what lets you coordinate well and keeps token use moderate.

## Core rules

These apply in every dev-* phase.

### 1. Orchestrate, never implement or review
Every change to project code goes to a subagent, including one-line fixes and fixes for review findings. Every review goes to a subagent. Your own work is limited to: reading files to understand and plan, asking the user, writing and updating the plan file, launching subagents, running the project's check commands, and git actions the user asked for.

If this environment gives you no way to launch subagents, say so before planning and ask the user whether to stop or to continue without delegation. Never switch to doing the work yourself silently.

### 2. Ask, do not assume
Ask questions until you are about 95% sure you understand what the user wants. Anything you would otherwise have to invent (behaviour, scope, edge cases, data shapes, names users will see, error handling) is a question for the user. A guess that turns out wrong costs far more tokens than a question.
- Read first: do not ask what the code or docs already answer.
- Ask in rounds, grouped, with concrete options and your recommendation. Use the question tool when there is one.
- After each round, check whether the answers opened new unknowns, and ask again if so.
- This holds mid-flow too: if a subagent reports an ambiguity, bring it to the user rather than deciding it yourself.

### 3. Brief where it is free, complete where it matters
- Messages to the user: short, outcome first. No narration of steps, no recaps of what they already saw.
- Prompts to subagents: only what that task needs (goal, files, constraints, where to look). Not the conversation, not the whole plan.
- Never shortened: questions to the user, plan detail, and code that needs its complexity.

### 4. Assign model and effort to every subagent
Set the `model` and `effort` parameters on each subagent call. `opus` means the latest Opus.

| Work | Model | Effort |
|---|---|---|
| Easy: mechanical, clear pattern to copy, small blast radius | opus | medium |
| Medium: several files or real design choices | opus | high |
| Hard or important: core logic, data integrity, concurrency, money, auth, wide blast radius | opus | xhigh |
| Exploration (read-only) | opus | medium |

- Implementation and logic review always follow this table. Never use `max`.
- Fable: an option only for security review of important features and for the few most important implementation tasks, at effort `medium` or `high` depending on importance. It uses more of the user's limits, so name the task and the reason and get the user's approval first. If declined, use opus at `xhigh`.
- If this environment cannot set effort (or model) per subagent, tell the user once and continue with what can be set.

### 5. Subagent discipline
Tell every subagent: stay inside the files or scope it was given, report anything ambiguous or blocked instead of guessing, and do not spawn further subagents.

### 6. Failures
If a subagent fails its task, or checks fail after its work, send the failure details to a subagent once. If it fails again, stop and ask the user how to proceed.

## Pipeline

`/dev-flow <request>` runs the phases below in order. Each phase is its own skill. Load a phase skill only when you reach that phase, and check the list of available skills to see which are installed.

1. **dev-plan**: understand, ask, plan, choose mode.
2. **dev-implement**: delegate the plan's tasks.
3. **dev-review-logic**: functionality review. Not installed: skip.
4. **dev-review-security**: security review where relevant. Not installed: skip.
5. **Wrap-up**: delete `.dev-flow/plan.md` (and the folder if empty), then give the final report.

A small change gets one combined review instead of stages 3 and 4: see "Light review".

If dev-plan or dev-implement is not installed, say which one is missing and ask the user how to proceed. A missing review skill is the user's choice: skip that stage and note it in one line in the final report.

Each phase can also be invoked alone (for example `/dev-review-logic` on existing changes). A phase invoked alone follows these core rules and then stops after its own report.

## Modes

The user picks a mode during planning. If a phase runs alone and no mode was chosen this session, ask.
- **Economy**: one implementation subagent at a time; one reviewer per review stage. Lowest usage.
- **Fast**: up to 3 implementation subagents in parallel on non-conflicting tasks; up to 3 reviewers per review stage, split by area. Faster, more usage.

## Light review

Two review stages are more than a small change needs. When both review skills are installed, both reviews are due on the same change, and the change is at most about 300 changed source lines (tests and docs do not count), run one combined reviewer instead of the two stages. Tell the user in one line that the light review applies.
- Load both review skills and build one prompt from their two reviewer prompts: scope and requirements once, the logic checks, the security trace and controls, both reporting rules, both "Not findings" lists (minus the line that defers security to a separate stage) and both severity scales.
- If the change has no security surface (dev-review-security, step 1), leave the security part out and say so in one line.
- Model and effort by the table. For a security-relevant change to an important feature, Fable at `medium` or `high` is an option with the user's approval, as in dev-review-security.
- Handle findings as below, including the targeted re-check. This is then the last review stage: ask about held medium/low findings and wrap up.

A larger change gets the two full stages. If only one review skill is installed, or the user invoked a single review skill, that review runs as normal.

## Handling review findings

Used by both review skills.
1. Drop duplicates and any finding without a file reference and a concrete failing scenario.
2. **Critical and high**: fix without asking. Delegate the fixes to as few subagents as possible, grouping findings that touch the same files (model and effort by the table). Then launch one reviewer for a targeted re-check: only the fixed code, against the original finding. Re-run the project's checks. If the re-check or the checks fail, rule 6 applies.
3. **Medium and low**: do not fix. Collect them across all review stages and ask the user once, at the end of the last review stage, which to fix.

## Final report

The user approved the plan, so do not restate it or explain how the code works. Aim for under 120 words plus one line per open finding:
- what now exists, in one or two lines
- deviations from the approved plan, if any
- check results
- review outcome: what was found and fixed, and each finding still awaiting the user's decision
- anything skipped, with the reason
