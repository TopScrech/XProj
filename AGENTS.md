# Repository Guidelines

## Project Structure & Module Organization
- `XProj/` holds the main macOS app sources and views
- Feature folders under `XProj/` include `Nav/`, `Proj Details/`, `Dependencies/`, `Smart Scan/`, `Settings/`, `Derived Data/`, `Models/`, and `Utils/`
- `XProj Widgets/` contains the widget extension sources
- `XProj Tests/` contains XCTest unit tests
- `XProj.xcodeproj/` stores the Xcode project configuration

## Architecture Overview
- Views and view models follow a lightweight MVVM pattern, with view models typically named `ThingVM` and kept near their feature views
- Navigation is centralized under `XProj/Nav/` with separate 2-column and 3-column layouts
- Widget UI and timelines live in `XProj Widgets/`, so new widget types should update the bundle, provider, and entry view files together

## Coding Style & Naming Conventions
- Indent Swift with 4 spaces and keep lines compact

## Testing Guidelines
- Tests live in `XProj Tests/` and use XCTest
- Name test types `ThingTests` and test methods `testThingDoesWork`
- Run tests via Xcode or the `xcodebuild test` command above
