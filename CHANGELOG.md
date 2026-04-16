# Changelog

All notable changes to **Poketra Vy** will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.2.0] - 2026-04-16

### Added
- **Data Portability Suite**: Full support for importing and exporting data in both JSON and Excel (.xlsx) formats for easy backup and migration.
- **JSON Import/Export**: Securely backup your entire expense history to a JSON file or restore it with a single tap.
- **Excel Import**: Import records directly from Excel files (matching the format of our existing Excel export).
- **Delete All Records**: New maintenance option in Settings to safely clear all expense data while preserving custom categories.
- **Production-Grade Test Suite**: Massive expansion of automated tests covering Onboarding, Categories, Home, and Expense management to ensure maximum stability.
- **Category Management**: Add, edit, and remove categories through a dedicated screen from now on. Making Settings screen more organized.
- **App Credit**: Added developer credit footer in the Help & Information screen.
- **Automated Dependency Updates**: Integrated Dependabot for checking and updating dependencies automatically.

### Changed
- **Settings UI Enhancement**: Grouped data management tools under a new "Data Import & Export" section for better organization.
- **Architecture Refactoring**: Inner-workings cleanup to support robust data parsing during imports.
- **Enhanced Code Quality**: Added strict code rules and applied static analysis fixes for better maintainability.

### Fixed
- **Minor UI Inconsistencies**: Polished various glassmorphism elements and alignment issues.
- **Performance Fixes**: Optimized data loading and chart rendering for larger datasets.
- **Static Analysis Issues**: Fixed analysis warnings from static analysis.

---

## [1.1.0] - 2026-03-23

### Added
- **Help Section**: In-app help guide accessible from Settings, covering app usage, parsing logic, and data privacy
- **Daily Reminder Notifications**: Configurable daily notification with time-picker and toggle to remind users to log expenses
- **Voice Visualizer**: Real-time waveform animation during voice recording for visual audio feedback
- **Unified Expense Form Dialog**: Single reusable dialog for both voice-based expense confirmation and manual editing
- **Fading AppBar**: Smooth scroll-aware app bar that fades on scroll for a polished navigation experience
- **CI Pipeline**: GitHub Actions workflow running regression tests on `dev` and `main` branch pushes
- **Regression Test Suite**: Comprehensive tests for expense parser, date utilities, Riverpod providers, and data models

### Changed
- **Glassmorphism UI Overhaul**: Premium frosted-glass design across the entire app
- **12-Hour Time Format**: Time picker and displays now use 12-hour format
- **Expense Edit Flow**: Replaced bottom sheet editing with a unified form dialog, enabling edit from both voice entry and expense list
- **Code Refactoring**: Major architecture cleanup for faster development and easier maintenance

### Fixed
- **Navigation Bug**: Resolved silent navigation error in route tree that caused slow performance
- **Duplicate GlobalKey**: Fixed `StatefulNavigationShellRoute` duplicate key error in GoRouter
- **Timezone Handling**: Corrected timezone issues in notification scheduling
- **Android Dependencies**: Fixed dependency conflicts for local notifications on Android

---

## [1.0.0] - 2025-12-01

### Added
- **Voice Expense Entry**: Record expenses using natural language (e.g., "10000 for lunch")
- **Smart Parsing**: Heuristic-based parser to extract amount, category, date, and description
- **Interactive Pie Chart**: Monthly spending visualization by category
- **Expense List**: Date-grouped expense history with dynamic category filters
- **Category Management**: Add, edit, and remove categories with icon selection
- **Swipe-to-Delete**: Quick expense removal with confirmation dialog
- **Onboarding Flow**: Welcome tour for new users
- **Local Storage**: Hive-based NoSQL persistence — data stays on device
- **Splash Screen**: Custom branded splash screen
