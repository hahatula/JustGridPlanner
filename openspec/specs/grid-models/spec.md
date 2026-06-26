# grid-models Specification

## Purpose
TBD - created by archiving change add-core-models. Update Purpose after archive.
## Requirements
### Requirement: Grid type enumeration
The system SHALL define a `GridType` enumeration with exactly two cases — `posts` and `reels` — representing the two independent grids. `GridType` MUST be `Codable` with stable string raw values (`"posts"`, `"reels"`) and MUST be iterable over all cases.

#### Scenario: Both grid types exist
- **WHEN** code references `GridType`
- **THEN** exactly two cases are available, `.posts` and `.reels`, and no other case

#### Scenario: Stable serialized values
- **WHEN** a `GridType` value is encoded
- **THEN** `.posts` encodes to the string `"posts"` and `.reels` encodes to the string `"reels"`, and decoding those strings restores the original case

### Requirement: Grid item source enumeration
The system SHALL define a `GridItemSource` enumeration with exactly two cases — `instagram` and `local` — distinguishing already-posted Instagram media from manually planned local media. `GridItemSource` MUST be `Codable` with stable string raw values (`"instagram"`, `"local"`).

#### Scenario: Both sources exist
- **WHEN** code references `GridItemSource`
- **THEN** exactly two cases are available, `.instagram` and `.local`, and no other case

#### Scenario: Stable serialized values
- **WHEN** a `GridItemSource` value is encoded
- **THEN** `.instagram` encodes to `"instagram"` and `.local` encodes to `"local"`, and decoding those strings restores the original case

### Requirement: Grid item model
The system SHALL define a `GridItem` model carrying the fields defined in `/docs/05-data-model.md`: `id`, `source` (`GridItemSource`), `gridType` (`GridType`), `localImagePath` (optional), `instagramMediaId` (optional), `thumbnailURL` (optional), `createdAt`, and `orderIndex`. `GridItem` MUST be `Codable` and `Identifiable`, and SHALL be `Equatable` so later phases can diff and merge items.

#### Scenario: Local planned item shape
- **WHEN** a `GridItem` is created with `source == .local`
- **THEN** it can carry a `localImagePath` and an `orderIndex`, and its `instagramMediaId` MAY be absent

#### Scenario: Instagram posted item shape
- **WHEN** a `GridItem` is created with `source == .instagram`
- **THEN** it can carry an `instagramMediaId` and a `thumbnailURL`, and its `localImagePath` MAY be absent

#### Scenario: Identity is stable across encoding
- **WHEN** a `GridItem` is encoded to data and decoded back
- **THEN** the decoded item is equal to the original, including its `id`, `source`, `gridType`, `orderIndex`, and `createdAt`

### Requirement: Derived locked behavior
The locked/unlocked state of a `GridItem` SHALL be derived solely from its `source` and MUST NOT be a stored or separately settable field. `GridItem` MUST expose `isLocked` as a computed value where `source == .instagram` yields `true` and `source == .local` yields `false`. The business rule MUST live in the model, not in UI components.

#### Scenario: Instagram items are locked
- **WHEN** a `GridItem` has `source == .instagram`
- **THEN** its `isLocked` value is `true`

#### Scenario: Local items are unlocked
- **WHEN** a `GridItem` has `source == .local`
- **THEN** its `isLocked` value is `false`

#### Scenario: Locked state is not persisted independently
- **WHEN** a `GridItem` is encoded
- **THEN** the encoded representation does not contain a stored `isLocked` field, so the rule cannot drift from `source`

### Requirement: Development sample data
The system SHALL provide development-only sample data exposing static collections of `GridItem` values for the Posts grid and the Reels grid, each containing a mix of locked Instagram items and unlocked local items ordered by `orderIndex`. The sample data MUST be plain in-memory fixtures and MUST NOT perform any network, file, or Instagram-sync behavior.

#### Scenario: Sample data is available for both grids
- **WHEN** a developer requests the sample data
- **THEN** a non-empty collection of `GridItem` values is available for `GridType.posts` and a non-empty collection is available for `GridType.reels`

#### Scenario: Sample data exercises both sources
- **WHEN** the sample collection for a grid is inspected
- **THEN** it contains at least one item with `source == .instagram` (locked) and at least one item with `source == .local` (unlocked)

#### Scenario: Sample data has no side effects
- **WHEN** the sample data is accessed
- **THEN** no network request, file read/write, or Instagram-sync call is performed

