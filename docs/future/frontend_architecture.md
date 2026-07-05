# Frontend Architecture (TalentOS)

## Phase 4: Flutter Platform Foundation
The frontend utilizes a multi-package Flutter monorepo managed by **Melos**.

### API Abstraction Layer
`Feature Repository` -> `RemoteDataSource` -> `ApiClient Wrapper (Auth interceptor)` -> `Generated Dio Client` -> `Dio`.

## Phase 5: Reusable Frontend Frameworks
1. **Component Gallery**: `apps/component_gallery` is the official Design System Explorer.
2. **TalentOS Form Framework**: Uses custom controllers (`TalentFormController`, `TalentFieldController`).
3. **AppShell & Navigation**: Global scaffold for authenticated modules, wrapped over `NavigationService`.

## Phase 6: Vertical Slice Architecture

### 1. State Management (`TalentState<T>`)
Riverpod providers **must not** expose raw `AsyncValue` or nullable sprawls. All providers must expose the `TalentState<T>` sealed class:
- `TalentStateInitial`
- `TalentStateLoading`
- `TalentStateRefreshing` (Holds previous data during background pull)
- `TalentStateSuccess` (Holds non-null `T`)
- `TalentStateEmpty` (Explicitly empty dataset)
- `TalentStateError`
Each state retains `timestamp`, `requestId`, and `isOffline` metadata.

### 2. Domain Result Pattern (`Result<T>`)
Repositories must never throw raw exceptions into the UI layer. They must catch exceptions and return a `Result<T>`:
- `Success<T>`
- `Failure` (Contains a strongly-typed `DomainError` e.g., `NetworkError`, `UnauthorizedError`).
The `TalentStateError` maps directly from this domain failure.

### 3. Draft Persistence Architecture
Candidate Applications support offline browser autosave. 
- Form layers push JSON to the `DraftService`.
- `DraftService` writes to `HiveDraftRepository`.
- **Hive** acts as the local NoSQL store tracking multiple drafts by `PositionId`.

### 4. Provider Debug Logging
The `TalentProviderObserver` hooks into Riverpod globally to log transition metadata (previous state -> new state) to the developer console for debugging state cycles.
