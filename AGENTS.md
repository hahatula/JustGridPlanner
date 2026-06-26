# Agent Instructions

Before doing any work, read all files in `/doc`.

Read them in this order:

1. `/doc/00-project-brief.md`
2. `/doc/01-business-logic.md`
3. `/doc/02-tech-stack.md`
4. `/doc/03-requirements.md`
5. `/doc/04-architecture.md`
6. `/doc/05-data-model.md`
7. `/doc/06-ui-ux-rules.md`
8. `/doc/07-agent-workflow.md`
9. `/doc/08-task-breakdown.md`
10. `/doc/09-testing-strategy.md`
11. `/doc/10-decisions.md`
12. `/doc/11-out-of-scope.md`

After reading, summarize:
- Product goal
- Current task scope
- Relevant constraints
- Files likely to change

Do not implement before producing a short plan.

Rules:

- Do not implement before writing a short plan.
- Do not add features outside `/doc/03-requirements.md`.
- Do not implement anything listed in `/doc/11-out-of-scope.md`.
- Work in small changes.
- After each change, explain files changed and manual test steps.

## Existing Code Awareness

Before proposing, modifying, or implementing anything, agents must inspect the current codebase.

Agents must not rely only on `/docs` or `/openspec`.

Before implementation, agents must identify:

- Existing app structure
- Existing models
- Existing services
- Existing views
- Existing storage approach
- Existing naming conventions
- Any already implemented related functionality

Agents must prefer extending existing code over rewriting it.

Agents must not duplicate functionality that already exists.

Agents must not refactor unrelated code unless explicitly approved.

Before coding, agents must state:

- What relevant code already exists
- What files they expect to change
- Whether the change extends or replaces existing code

## Clarification Rule

If something is unclear, ambiguous, missing, or conflicting, ask a clarification question before proposing or implementing.

Do not guess when the decision affects:
- Product behavior
- Data model
- Architecture
- Storage
- Instagram integration
- Security/privacy
- User-facing UI/UX
- Scope boundaries

If the uncertainty is minor and does not affect behavior, make a small reasonable assumption and state it clearly.

Before coding, list:
- Open questions, if any
- Assumptions, if any
- Blockers, if any
