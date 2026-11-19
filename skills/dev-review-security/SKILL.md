---
name: dev-review-security
description: Security review phase of dev-flow. Decides whether the implemented change has a security-relevant surface, and if so launches reviewer subagents that report only vulnerabilities exploitable in the code as implemented. Use when dev-flow reaches its security review phase or when the user explicitly invokes "/dev-review-security" on existing changes. Do not load it for ordinary coding requests.
---

# Dev Review: Security

If the dev-flow core rules are not loaded in this session, load the dev-flow skill first and apply its core rules.

The purpose is to find vulnerabilities that exist in the code that was written, not to produce a hardening checklist. "No vulnerabilities found" is a normal, acceptable result.

If the logic review is also due on this change and has not run yet, check "Light review" in dev-flow first: a small change gets one combined reviewer for both.

## 1. Decide whether to run
Run when the change touches any of:
- authentication, authorization, sessions, tokens, password or account flows
- user-controlled input reaching a query, shell command, file path, template, HTML output or deserializer
- data access rules, tenant or user boundaries, personal or sensitive data
- secrets, keys, cryptography, randomness used for security
- file upload/download, outbound requests, webhooks, CORS, redirects
- new or upgraded dependencies, payment or money flows

Otherwise skip the review, tell the user in one line why (for example "Security review skipped: change is internal date formatting, no input or data-access surface"), and go straight to step 5. When the user invoked this skill directly, run it on the scope they named.

## 2. Reviewers
- Economy: one reviewer. Fast: up to 3 in parallel, split by attack surface. A small change gets one reviewer in either mode.
- Model and effort: opus by the importance of the feature (core table). For an important feature, Fable at `medium` or `high` is an option; use it only with the user's approval (asked during planning, or ask now if it was not).

## 3. The reviewer prompt

```
Security review of the implementation of <feature>. Do not modify any file.
In scope: <files / diff command>. Read surrounding code (middleware, framework config, callers) as needed, but review only the changes.
Relevant surface: <what from the list above this change touches>.

For the changed code, trace untrusted input from where it enters to where it is used, and check the controls that apply to this surface (validation, authorization on every path, output encoding, parameterization, token generation/expiry/single use, secret handling, error and log content, rate or abuse limits where the feature needs them).

Report only vulnerabilities exploitable in this code as implemented. For each one give: severity, file:line, the entry point, the path to the weakness, the missing or broken control, the impact, and a suggested fix. Before reporting, check that an existing protection (framework default, middleware, a caller) does not already cover it.

Not findings: generic best-practice or hardening advice not tied to a concrete weakness in the change, issues that need the attacker to already hold equivalent access, and problems in code this change did not touch. If you notice a serious pre-existing problem, mention it in one separate line marked "pre-existing, out of scope".

Severity: critical = exploitable without authentication, or leads to auth bypass, code execution or broad data exposure. high = exploitable by an ordinary authenticated user, privilege escalation, or exposure of sensitive data. medium = real but limited impact or hard to exploit. low = a concrete defence-in-depth gap.

If there are none, say "No vulnerabilities found" and list what you verified. Do not pad the report.
Do not spawn subagents.
```

## 4. Findings
Handle them as described in dev-flow, "Handling review findings". Pass any "pre-existing, out of scope" notes to the user unchanged; do not fix them.

## 5. Finish
Tell the user the result in a line or two. This is the last review stage: ask once about all held medium/low findings (from both reviews), delegate the ones the user picks, then give the final report.
