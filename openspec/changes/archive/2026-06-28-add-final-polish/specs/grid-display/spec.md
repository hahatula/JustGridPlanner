## ADDED Requirements

### Requirement: Empty grid shows a hint
When a grid has no items to show, the app SHALL display a clear empty-state message inviting the user to add photos (e.g. "Add photos from your gallery to plan your grid." — `/docs/06-ui-ux-rules.md`) instead of a blank screen.

#### Scenario: Empty grid
- **WHEN** a grid has no items
- **THEN** it shows an empty-state message prompting the user to add photos from their gallery

#### Scenario: Non-empty grid shows no hint
- **WHEN** a grid has at least one item
- **THEN** the empty-state message is not shown and the grid is displayed normally
