---
name: dev-implement
description: Implementation phase of dev-flow. Hands the approved plan's tasks to implementation subagents (one at a time in economy mode, up to 3 in parallel in fast mode), verifies their results and handles failures. Use when dev-flow reaches its implementation phase or when the user explicitly invokes "/dev-implement". Do not load it for ordinary coding requests.
---

# Dev Implement

If the dev-flow core rules are not loaded in this session, load the dev-flow skill first and apply its core rules.

Needs an approved plan at `.dev-flow/plan.md`. If there is none, run dev-plan first when it is installed; otherwise ask the user for the tasks and decisions before delegating anything.

## 1. Dispatch
Work through the plan wave by wave.
- **Economy**: one subagent at a time, in dependency order. Adjacent easy tasks in the same area may share one subagent to save startup cost.
- **Fast**: up to 3 subagents at once, only tasks from the same wave. Launch them in a single message so they actually run in parallel.

Never run two subagents that own the same file.

## 2. The implementer prompt
Keep it to what the task needs. The task text lives in the plan file, so point to it instead of retyping it.

```
Implement task <id> of the plan at .dev-flow/plan.md. Read the header, "Decisions", "Contracts" and your task; skip the other tasks.
You own: <files>. Do not edit other files; if a change elsewhere is needed, report it.
Follow the project's existing conventions; <neighbouring file> is a good pattern.
Tests: <add tests like <example> | this project has no tests, do not add any>.
Before reporting, run: <checks, scoped to your files when tasks run in parallel>. Fix what you broke.
If anything is ambiguous or blocked, stop and report it. Do not guess.
Do not spawn subagents. Do not commit. Do not edit the plan file.
Report: status (done / blocked / failed), files changed, check results, any deviation from the plan, anything a later task needs to know.
```

Add task-specific context only when the plan does not already carry it.

## 3. After each report
- **Done**: set the task's status in the plan file.
- **Deviation**: if it affects later tasks, update the plan. If it changes what the user approved, ask the user.
- **Blocked on an ambiguity**: ask the user, then re-dispatch with the answer.
- **Failed, or checks failing**: core rule 6 (one retry with the failure details, then ask the user).

## 4. Verify
After each parallel wave, and once when all tasks are done, run the full checks yourself with quiet output so only the summary reaches your context. Subagent self-reports are not proof, and parallel work can break at the seams. Any failure goes to a subagent, never fixed by you.

## 5. Git
Do what the user chose in the plan. You make the commits, not the subagents, so parallel work cannot collide. Never commit `.dev-flow/`.

## 6. Finish
Tell the user in a line or two that implementation is complete and checks pass, then continue with the review phases if the pipeline is running. If dev-implement was invoked alone, give the final report and stop.
