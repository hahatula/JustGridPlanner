## REMOVED Requirements

### Requirement: Display-only grid in this phase
**Reason**: Phase 4 (gallery import) makes the grid interactive: the user can now add local planned items from a control outside the grid, and cells read local image files from storage to display imported images. The blanket "no add affordance / no storage access" constraint from Phase 3 no longer holds.

**Migration**: The add behavior is governed by the new `gallery-import` capability (add via an out-of-grid control, copy to local storage, insert at top, display the image). Remove/reorder affordances and Instagram sync are still not present and will be specified by their own capabilities in Phases 6, 7, and 9.
