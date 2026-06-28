## ADDED Requirements

### Requirement: Show the last successful import time
The account settings SHALL show when posted media was last successfully imported (from the recorded last-import timestamp), or indicate that none has happened yet.

#### Scenario: Last import shown
- **WHEN** posted media has been imported at least once
- **THEN** the account settings show the time of the last successful import

#### Scenario: No import yet
- **WHEN** no import has happened
- **THEN** the account settings indicate that nothing has been imported yet
