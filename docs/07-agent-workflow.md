# Agent Workflow

Agents must follow this workflow.

## Before Planning

1. Read all files in /docs.
2. Treat /docs/03-requirements.md as the source of truth for required functionality.
3. Do not assume that Instagram sync is optional or out of scope.
4. Do not implement features listed in /docs/11-out-of-scope.md.
5. Do not change the tech stack without explicit approval.

## Planning Rules

Before coding, produce a short implementation plan.

The plan must include:

- The exact requirement being implemented
- Files expected to be created or changed
- Any assumptions
- Manual test steps
- Risks or blockers

Do not code before the plan is approved.

## Implementation Rules

Implement one small task at a time.

After implementation, report:

1. What changed
2. Files changed
3. How to test manually
4. Known limitations
5. Any requirement that remains incomplete

## Scope Control

Agents must not add:

- Backend services
- Cloud database
- Account system
- Analytics
- Scheduling
- Auto-posting
- Caption generation
- Hashtag generation
- AI image editing
- Multi-account support
- App Store release logic

Unless explicitly requested.

## Instagram Rules

Instagram integration must use safe and approved approaches only.

Allowed:

- Official Instagram API integration
- Mock Instagram service for development
- Manual fallback/import flow if official API access is blocked

Not allowed:

- Storing Instagram password
- Browser login automation
- Scraping Instagram pages
- Unofficial private APIs
- Anything that risks account security

## Code Style

- Keep SwiftUI views small
- Put business logic in ViewModels and services
- Keep models Codable where possible
- Keep storage logic separate from UI
- Avoid unnecessary dependencies
- Avoid premature abstraction
- Prefer readable code over clever code

## Development Strategy

The app may be implemented gradually, but the required first complete product includes:

- Posts grid
- Reels grid
- Local gallery import
- Local persistence
- Drag reorder for local items
- Remove local items
- Locked Instagram items
- Refresh behavior
- Instagram media sync or approved fallback path

## Questions and Ambiguity

Agents must ask additional questions when requirements are unclear, incomplete, or conflicting.
Agents must not silently invent product behavior.
If a question blocks implementation, stop and ask.
If a small assumption is safe, state it explicitly before implementation.
