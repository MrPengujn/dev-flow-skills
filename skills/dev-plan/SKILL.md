---
name: dev-plan
description: Planning phase of dev-flow. Reads the project, asks clarifying questions until the request is understood, writes a task plan with file ownership and model/effort per task, and asks the user for economy or fast mode. Use when dev-flow reaches its planning phase or when the user explicitly invokes "/dev-plan". Do not load it for ordinary coding requests.
---

# Dev Plan

If the dev-flow core rules are not loaded in this session, load the dev-flow skill first and apply its core rules (do not start its pipeline unless the user asked for it).

A good plan is what makes delegation work: subagents start with no context, so everything they would otherwise guess must be settled here.

## 1. Read the project
Read what the feature depends on: README and agent instruction files, the manifest, the files the feature touches, one neighbouring feature to copy patterns from, and how checks are run (test, lint, type-check, build). Note whether the project has tests at all.

If answering needs a sweep over many files or an unfamiliar area, launch one exploration subagent with specific questions and ask for conclusions with file paths, not file dumps.

## 2. Ask until about 95% sure
Follow core rule 2. Cover whatever applies:
- Behaviour and scope: what exactly happens, what is explicitly out.
- Edge cases and errors: invalid input, empty states, failures, limits.
- Data and interfaces: shapes, names, storage, API contracts, migrations.
- Fit: compatibility with existing behaviour, UI/UX expectations.

You are done when you could brief an implementer without inventing anything. If the request is already fully specified, say so and move on; do not ask filler questions.

## 3. Draft the plan
Split the work so each task is a coherent unit one subagent can finish and verify alone.
- **No shared files**: a file is owned by exactly one task. When several tasks need the same file (a router, an index, a config), give that file to one task and make the others depend on it, or add a final wiring task.
- **Contracts first**: types, interfaces, schemas and function signatures that several tasks rely on are written into the plan itself, or built by a first task the others depend on.
- **Waves**: group tasks so everything in a wave is independent. Waves run in order; tasks inside a wave can run in parallel.
- **Right size**: every subagent costs tens of thousands of tokens before it does any work, so a small feature is often a single task. Split only when a task would be too large for one subagent, or when the split buys real parallelism in fast mode. Fold tiny jobs (wiring, docs) into a neighbouring task when file ownership allows.
- **Tests**: if the project already has tests, each task adds tests for its logic in the existing style. If the project has no tests, no task adds any.
- **Model and effort** per task from the core table. Mark any task or review you would give to Fable.
- **Security review**: note whether you expect one to be relevant, and why.

## 4. Get the user's decisions
Show the plan compactly (per task: id, what, files, wave, model/effort) and ask in one round:
1. Approve or change the plan.
2. Mode: economy or fast (describe both in one line each, as in dev-flow).
3. Git for this feature: no git actions, a commit per task, one commit at the end, and whether to use a new branch.
4. Fable approval, only if you proposed it: which task or review, and why.

## 5. Write the plan file
If the user chose economy, first merge tasks that were split only to run in parallel. Then write the approved plan to `.dev-flow/plan.md`. It is temporary: never commit it; it is deleted at wrap-up. Subagents read their task from it, so write it for a reader with no context.

```markdown
# <feature>
Mode: economy | fast
Git: <what the user chose>
Checks: <exact commands>
Tests: add in <style/location> | project has no tests, add none
Security review expected: yes/no, <reason>

## Decisions
<every answer from the Q&A that affects implementation, as plain statements>

## Contracts
<shared types, signatures, schemas>

## Tasks
### T1 <title>  [wave 1 | opus/high | status: todo]
Goal: ...
Owns: <files to create or modify>
Depends on: none
Acceptance: <verifiable criteria>
```

Then hand over to dev-implement if the pipeline is running. If dev-plan was invoked alone, stop here and tell the user the plan is ready.
