## ADDED Requirements

### Requirement: Import shows progress while processing
While a picked screenshot is being cropped, split, and saved, the app SHALL show a loading indicator and SHALL prevent the split action from being started again until it finishes.

#### Scenario: Splitting shows progress
- **WHEN** the user confirms the crop and the tiles are being produced
- **THEN** a loading indicator is shown and the confirm action is disabled until it completes

### Requirement: Import surfaces errors clearly
If a picked image cannot be loaded or the aligned region cannot be split into tiles, the app SHALL show a clear, recoverable error message and SHALL NOT produce an incomplete or empty set of tiles.

#### Scenario: Unprocessable image
- **WHEN** the chosen image cannot be loaded or split
- **THEN** the app shows a clear error and lets the user pick a different screenshot, and no tiles are produced
