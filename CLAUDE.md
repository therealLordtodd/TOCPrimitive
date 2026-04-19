# TOCPrimitive

> Claude Code loads this file automatically at the start of every session.

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

## Primary Documentation

- Host-facing usage + API reference: `/Users/todd/Programming/Packages/TOCPrimitive/README.md`
- Portfolio integration guide: `/Users/todd/Programming/Packages/ReaderKit/docs/reader-stack-integration-guide.md`

## GitHub Repository Visibility

- This repository is **private**.
