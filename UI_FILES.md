# UI Files Analysis

This document outlines the UI files used in the Docker Analytics Sandbox project.

## Currently Used Files

The following files are part of the active UI implementation:

- **App.js** - Main entry point for the React application
- **DataComponent.js** - Component for data visualization and SQL queries
- **ReposComponent.js** - Component for file management
- **index.css** - Primary stylesheet with Tailwind CSS imports
- **index.js** - React application bootstrap file
- **index.html** - HTML entry point
- **package.json** - Project dependencies
- **postcss-config.js** - PostCSS configuration for Tailwind
- **tailwind-config.js** - Tailwind CSS configuration

## Prototype Files

These files contain a prototype design for a Databricks-inspired UI:

- **databricks-ui-component.js** - Early prototype for Databricks-style UI
- **rds-ui-prototype.tsx** - TypeScript React prototype (not currently used in production)

## Dependencies

The package.json files contain the following key dependencies:

- React 18
- Tailwind CSS
- PostCSS
- Autoprefixer

## Implementation Notes

1. The current application uses the standard React structure with App.js as the main component.

2. There are two UI implementations:
   - The main React app at port 3001
   - The RDS UI app at port 3000

3. The Databricks-style UI prototype shows a design direction but is not fully implemented in the current version.

4. Files like manifest.json are standard React files used for PWA capabilities.

## File Usage Table

| File | Status | Purpose |
|------|--------|---------|
| app-js.js | Used | Main application component |
| databricks-ui-component.js | Reference | Prototype UI design |
| index-css.css | Used | Main stylesheet with Tailwind imports |
| index-html.html | Used | HTML entry point |
| index-js.js | Used | JavaScript entry point |
| manifest-json.json | Used | Web app manifest |
| package-json.json | Used | NPM dependencies |
| postcss-config.js | Used | PostCSS configuration |
| rds-ui-prototype.tsx | Reference | TypeScript UI prototype |
| package.json | Used | Root dependencies |
| package-lock.json | Used | Dependency lock file |
| report-web-vitals.js | Used | Performance monitoring |
| tailwind-config.js | Used | Tailwind CSS configuration | 