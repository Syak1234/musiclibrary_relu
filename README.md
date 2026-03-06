# 🎵 Music Library Relu

A premium, high-performance music discovery application built with Flutter, focusing on flagship-grade UI/UX and robust architecture.

## 🏗️ Architecture: MVVM + BLoC

The project strictly follows the **MVVM (Model-View-ViewModel)** design pattern using **BLoC** for state management. This ensures a clean separation between UI, business logic, and data.

### BLoC Flow Summary
- **Events**: Unique triggers from the UI (e.g., `LoadNextPage`, `SearchQueryChanged`, `ShareTrack`).
- **States**: Immutable snapshots of the UI data including `status` (initial, loading, loaded, error), list of tracks, and pagination info.
- **Connection Bloc**: A global listener that monitors device connectivity and updates the entire app UI in real-time.

---

## 🚀 Why This Approach Works

### 1. Lazy Build & Paging Strategy
Instead of fetching thousands of tracks at once, we use an **Infinite Scroll Paging Strategy**. 
- **Lazy Loading**: Using `ListView.builder`, the app only builds tiles that are currently visible on the screen.
- **Proactive Fetching**: The `LibraryBloc` detects when the user is 800px away from the end of the scroll and proactively fetches the next 50 items. This ensures a "zero-wait" experience for the user.

### 2. Debounced Search Strategy
To avoid overloading the Deezer API and ensure a smooth UI, search queries are **debounced**. We integrated a `Timer` in the `LibraryBloc` that waits for 400ms of inactivity before firing the API call, preventing "stutter" during typing.

### 3. Off-Thread Processing
Sorting 500+ items by Title or Artist can cause frame drops (jank). We use Flutter's `compute` function to move data parsing and sorting to a separate **Isolate**, keeping the UI at a buttery-smooth 60/120 FPS.

---

## 🎨 3 Key Design Decisions

1.  **Glassmorphism & Ambient Depth**: We avoided flat backgrounds in favor of radial gradients and "Glass Shell" search bars. This provides a sense of depth similar to flagship OS interfaces (iOS/OxygenOS).
2.  **Sticky Group Headers**: To help users navigate large libraries, we implemented sorting-based grouping. Letter-based sticky headers provide a clear "landmark" as the user scrolls.
3.  **Declarative Navigation (GoRouter)**: Using `GoRouter` allows us to handle deep links and pass complex objects between screens with a clean, path-based URL structure, rather than fragile manual Navigator stacks.

---

## 🛠️ Issue Faced + Fix

**The Problem**: During the development of the "Sticky Headers," we encountered a critical `SliverGeometry` crash where the `layoutExtent` exceeded the `paintExtent`. This happened because we were trying to pin a custom filter bar below a pinned AppBar manually.

**The Fix**: I refactored the layout to use the native `SliverAppBar`'s `bottom` property for the Search and Filter bars. This leveraged Flutter's internal "Pinned Header" engine, which automatically handles the math for layout offsets, eliminating the crash permanently.

---

## 📉 What Breaks at 100k Items?

If this app scaled to **100k items**, the following would likely happen:

1.  **Memory Pressure**: Storing 100k `Track` models in RAM would increase memory usage significantly, potentially causing background kills on entry-level devices.
2.  **Sorting Latency**: Even in an Isolate, sorting a list of 100,000 objects every time the user toggles "Artist" would take several hundred milliseconds, feeling sluggish.
3.  **Layout Passes**: While `ListView.builder` is efficient, the initial scroll math for a list of 100k items can occasionally cause "Layout Spikes."

### Optimization Next Steps:
*   **Local Database (Isar/Hive)**: Move from in-memory lists to a local DB with **Indexing**. This allows for O(1) lookups and avoids loading everything into RAM.
*   **Server-Side Sorting**: Delegate sorting and grouping to the API instead of doing it on the client.
*   **Virtual Grid/List**: Use even more aggressive virtualization and image caching limits.
