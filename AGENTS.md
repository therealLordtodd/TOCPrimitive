# TOCPrimitive

> Claude Code loads this file automatically at the start of every session.

## Repositories & Local Paths

| Package | Repository | Local Path |
|---------|------------|------------|
| **TOCPrimitive** | https://github.com/therealLordtodd/TOCPrimitive.git | `/Users/todd/Building - Apple/Packages/TOCPrimitive` |

## Build & Test

- Build: `swift build`
- Test: `swift test`

## Package Purpose

`TOCPrimitive` owns the shared table-of-contents surface. `TOCController` loads TOC nodes from a `TOCProvider` conformance (defined in `ContentModelPrimitive`) and presents them with a consistent tree view. Renderer primitives (Markdown, PDF, EPUB, HTML) implement `TOCProvider`; this primitive renders whatever they return.

**Tech stack:** Swift 6.0 / SwiftUI.

## Key Types

- `TOCController` — `@MainActor` `ObservableObject`, per-document
- `TOCPresentationState` — typed state (isLoading, errorDescription, nodeCount)
- shared SwiftUI tree views for TOC presentation

## Dependencies

- `ContentModelPrimitive` — `TOCProvider`, `TOCNode`, `DocumentID`
- `ReaderChromeThemePrimitive` — theming via environment

## Architecture Rules

- **Per-document.** One `TOCController` per document. Multi-document readers hold multiple controllers.
- **Extraction lives in the renderer.** The primitive does not parse outlines; the renderer's `TOCProvider` does.
- **No host-specific navigation logic.** The tree view surfaces nodes and their anchors; the host or composer handles navigation.

## Security Posture

`TOCPrimitive` is a Cat 2 reader-navigation surface over a host/renderer-provided `TOCProvider`. It owns no credentials, network calls, filesystem access, database access, durable persistence, pasteboard access, logging facade, outline parser, document renderer, or AISeams surface.

The primitive invokes `TOCProvider.tableOfContents()`, stores the returned nodes in a per-document `TOCController`, renders TOC titles/anchors/children, and calls host selection closures. Renderers and hosts own PDF/EPUB/HTML/Markdown extraction, file access, sandbox/security-scoped bookmarks, parsing safety, document authorization, navigation side effects, persistence/sync of selected location, logging/audit, redaction, error-message hygiene, and any AI workflow that exposes or changes reader navigation.

## Primary Documentation

- Host-facing usage + API reference: `/Users/todd/Building - Apple/Packages/TOCPrimitive/README.md`
- Portfolio integration guide: `/Users/todd/Building - Apple/Packages/ReaderKit/docs/reader-stack-integration-guide.md`

## GitHub Repository Visibility

- This repository is **private**.

## Performance Posture

Hot paths are `TOCController.load()`, provider result assignment, `@Published` state updates, SwiftUI `List` / `OutlineGroup` row rendering, selected-node scrolling, and host selection callback dispatch. Extraction and parsing performance belong to the renderer's `TOCProvider`; keep this package focused on presentation and state handoff. Reviewed 2026-05-02 (Security follow-up correction).
