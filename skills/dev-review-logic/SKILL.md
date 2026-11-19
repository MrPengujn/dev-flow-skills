---
name: dev-review-logic
description: Business logic and functionality review phase of dev-flow. Launches reviewer subagents that check what was actually implemented against its requirements and report only demonstrable issues. Use when dev-flow reaches its review phase or when the user explicitly invokes "/dev-review-logic" on existing changes. Do not load it for ordinary coding requests.
---

# Dev Review: Logic

If the dev-flow core rules are not loaded in this session, load the dev-flow skill first and apply its core rules.

The purpose is to catch real defects in what was built. A review that invents problems is worse than none: every false finding costs a fix cycle and can damage working code. "No issues found" is a normal, acceptable result.

If the security review is also due on this change, check "Light review" in dev-flow first: a small change gets one combined reviewer for both.

## 1. Scope
Review what was actually implemented, nothing else.
- In the pipeline: the plan's tasks and the files they changed.
- Invoked alone: the changes the user names (a diff, a branch, files). If the scope or the requirements are unclear, ask.

## 2. Reviewers
- Economy: one reviewer.
- Fast: up to 3 in parallel, split by area so they do not overlap. A small change gets one reviewer in either mode.
- Model opus, effort by the importance of the feature (core table).

## 3. The reviewer prompt

```
Review the implementation of <feature> for functional correctness. Do not modify any file.
Requirements: <.dev-flow/plan.md "Decisions" and tasks <ids> | the requirements stated here>.
In scope: <files / diff command>. Read surrounding code as needed to understand them, but review only the changes.

Check:
- Each requirement and acceptance criterion is met.
- Logic errors, wrong state or data flow, broken error handling.
- Edge cases that can really occur with this code's inputs.
- Integration: existing callers and behaviour still work.
- If the project has tests: the new tests exercise the new logic and would fail if it broke.

Report only issues you have verified. For each one give: severity, file:line, what is wrong, a concrete scenario (input or state, and the wrong result), and a suggested fix. Confirm each by reading the relevant code path or running a test before you report it.

Not findings: style or naming preferences, refactoring ideas, features nobody asked for, hypothetical future needs, "consider adding", things this project does not do anywhere else, and security issues (a separate stage covers them).

Severity: critical = the feature does not work on its main path, crashes, or corrupts/loses data. high = wrong behaviour in a realistic case, or a requirement not met. medium = a real bug in an unusual case with limited impact. low = minor but real.

If the implementation is correct, say "No issues found" and list what you verified. Do not pad the report.
Do not spawn subagents.
```

## 4. Findings
Handle them as described in dev-flow, "Handling review findings".

## 5. Finish
Tell the user the result in a line or two (counts by severity, what was fixed). Continue to dev-review-security if the pipeline is running and it is installed. Otherwise ask about any held medium/low findings and give the final report.
