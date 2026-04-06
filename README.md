# Wrike Native Desktop Client: Project Plan

## 1. Project Overview

This project is a cross-platform native desktop client for Wrike, built in C# with Avalonia.

The motivation is straightforward: Wrike's existing web interface is slow, clunky, and poorly suited to day-to-day use, and the official desktop app does not solve that problem because it is effectively just an Electron wrapper around the web app. The goal is to build a faster, more focused replacement for the workflows that matter most.

This application is not intended to reproduce the entire Wrike product. That is neither realistic nor desirable, especially because the Wrike API does not expose everything the web application can do. Instead, the goal is to deliver a high-quality native client that supports the most important daily operations.

## 2. Product Goal

The end-state product should allow a power user to work with Wrike efficiently from a native desktop application.

The intended capabilities include:

* Browsing spaces and related task structures
* Viewing tasks and task details
* Creating and editing tasks
* Reading and adding comments
* Editing comments where supported
* Supporting common day-to-day interactions such as reactions, status changes, and similar actions exposed by the API

The product should prioritize speed, clarity, and responsiveness over breadth of features.

## 3. Initial Scope

The project should start small.

The first phase is not "build the whole client." The first phase is to establish a proof of concept, define the rules of engagement for development, and set up a foundation that keeps the project maintainable while AI is doing most of the implementation work.

Initial work should focus on:

1. Understanding the Wrike API well enough to know what is realistically possible
2. Defining project rules, coding standards, and architectural boundaries
3. Building a minimal proof of concept that validates the stack and development approach
4. Establishing strong automated testing from the beginning
5. Creating a reliable workflow for AI-assisted development

## 4. Core Constraints

Several constraints should shape the design from the start.

### API limitations

The Wrike API does not expose every capability available in the web application. The application must therefore be designed around what the API can actually support, not around feature parity with the web client.

### Rate limits

Wrike API usage is rate-limited, reportedly around 500 requests per minute. That means the client cannot behave like a naive web form that aggressively writes on every tiny change.

This has direct consequences:

* Batching is essential
* Caching is essential
* Save behavior must be deliberate
* Test suites must never depend on real API traffic

### AI-driven development

Because Codex will be doing most of the implementation work, the project needs unusually strong guardrails. Development discipline is not optional here; it is part of the architecture.

## 5. Development Principles

These principles should govern the project from the beginning.

### Start small

Do the minimum necessary to prove value. Avoid building infrastructure for hypothetical future needs.

### YAGNI

Do not introduce abstractions, layers, or extension points unless there is a concrete and immediate reason for them.

### Keep room for growth

Avoid overengineering, but do not paint the project into a corner. The architecture should stay simple while still allowing future enhancement.

### Prefer elegant, practical code

The codebase should be clean and thoughtful, but not "clever." Maintainability matters more than theoretical purity.

### Reusable components where appropriate

UI and application components should be designed so they can be reused in multiple contexts when that reuse is realistic and near-term. For example, a text entry component should not be unnecessarily tied to one screen if it is clearly a shared interaction pattern.

That said, reusability should emerge from good design, not from premature abstraction.

## 6. Quality Standards

Quality has to be enforced continuously, not added later.

### Testing

Testing is a first-class requirement.

Goals:

* Nearly 100% test coverage
* Unit test everything that can reasonably be unit tested
* Run tests constantly, including after every meaningful change
* Treat broken or missing tests as a serious issue, not a cleanup item for later

### Mockability

The Wrike API must be easy to mock. All business logic should be structured so tests can run without making real API calls.

Desired outcomes:

* API access isolated behind well-defined interfaces
* Tests default to mocks or fakes
* Core logic remains testable without network dependencies
* UI and application logic are tested independently from the live API whenever possible

Where feasible, components should be designed so that they can be tested without needing API mocking at all, by keeping domain logic separate from transport concerns.

## 7. Source Control and Safety Rules

Because AI will be making many changes, repository safety rules are critical.

### Commit discipline

All meaningful changes should be committed. Work should progress in small, reviewable increments.

### No force pushes

The GitHub repository has already been configured to disallow force pushes. This is an important protection against destructive mistakes by tools or automation.

### Strong recovery posture

The workflow should assume that the AI may occasionally produce damaging or chaotic changes. The repository setup and commit strategy should make recovery straightforward.

## 8. Architectural Direction

The architecture should be simple, explicit, and test-friendly.

Key characteristics:

* Clear separation between API integration, domain/application logic, and UI
* Minimal coupling between components
* Easy substitution of mocked API implementations
* Limited abstraction until repeated patterns justify it
* Focus on composable building blocks rather than large monolithic screens or services

The architecture should be designed for present needs first, but with enough discipline that future additions do not require a rewrite.

## 9. UX and Interaction Considerations

This client is intended for power-user workflows, so the UX should optimize for efficiency rather than mimicking Wrike's web experience.

Important considerations include:

### Performance

The native client should feel substantially faster and lighter than the existing web-based experience.

### Save behavior

Wrike's web frontend appears to do aggressive autosaving, possibly even close to per-keystroke in some cases. That may not be practical here because of API rate limits.

The client may need a more controlled approach, such as:

* Explicit save actions
* Debounced saves
* Background save queues
* Clear unsaved-change indicators

The exact solution should be chosen based on API behavior and practical usability, not by trying to copy the web UI.

### Collaboration behavior

The web client includes collaborative editing behavior. It is not yet clear whether this is feasible or worthwhile to reproduce using the public API. This should be treated as an open question, not an early requirement.

### Rate-limit visibility

Because this tool is for a power user, it may be useful to expose API rate-limit information in the UI. This is a minor feature, but potentially valuable.

## 10. AI Enablement and Project Documentation

A major early deliverable should be an `agents.md` file.

Its purpose is to give Codex and future work sessions a stable, high-quality project briefing so the AI can ramp up quickly and make better decisions.

This document should include:

* A summary of the project goals
* The development principles and constraints
* The agreed coding standards
* Testing requirements
* Architectural boundaries
* Known Wrike API capabilities and limitations
* Links to relevant Wrike API documentation
* Guidance on what not to build yet
* Rules for commits, test execution, and change size

This file should become the operational handbook for AI-assisted development on the project.

## 11. Proposed Phases

### Phase 0: Research and project rules

* Review the Wrike API carefully
* Identify realistic MVP capabilities
* Produce `agents.md`
* Define architecture rules and coding standards
* Define testing requirements and mocking strategy

### Phase 1: Technical proof of concept

* Create the Avalonia application skeleton
* Establish the project structure
* Implement a thin Wrike API integration layer
* Validate authentication and a minimal read flow
* Confirm testing infrastructure works as intended

### Phase 2: Minimal usable workflow

* Browse a space or task list
* View task details
* Create and edit a task
* Read and add comments

This phase should produce something genuinely usable, even if narrow in scope.

### Phase 3: Iterative expansion

* Improve navigation and performance
* Add batching and caching strategies
* Expand supported task operations
* Add comment editing, reactions, and similar supported features
* Improve UX for power-user workflows

## 12. Non-Goals for Early Development

To keep the project on track, the following should not be early priorities unless the API review proves they are trivial and valuable:

* Full Wrike feature parity
* Recreating every collaborative web behavior
* Deep abstraction for speculative future features
* Fancy infrastructure before the basic workflows work
* Real API usage in automated tests

## 13. Definition of Success

This project is successful if it produces a native desktop client that is materially better than Wrike's existing desktop and web experience for common daily workflows, while remaining maintainable under heavy AI-assisted development.

More specifically, success means:

* The application is fast and pleasant to use
* The most important Wrike workflows are supported
* The codebase stays disciplined and understandable
* Tests are comprehensive and reliable
* API usage is controlled and efficient
* The project can continue to grow without becoming brittle or chaotic

# Condensed Guiding Statement

Build a focused native Wrike client for power-user task workflows, using C# and Avalonia, with strict development guardrails, near-total automated test coverage, aggressive mockability, careful API usage, and a deliberate bias toward small, maintainable increments over premature complexity.
