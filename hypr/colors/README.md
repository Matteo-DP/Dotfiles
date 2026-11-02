# Hypr Colors Theme Manager

This project provides a modular framework for managing and generating color themes for Hyprland and related applications. It allows you to easily switch, generate, and apply color schemes across your desktop environment.

The project generates `current-theme/*` files which contain the formatted color definitions. Then, a symlink is generated. The source is in the `.config` folder for the program that uses the colors, and the target goes to `current-theme/<filename>`. The theme colors which can be formatted reside in `themes/<theme>/colors.sh`. This projects aims to centralize theme management using symlinks.

## Features
- Centralized theme management
- Easy theme switching via shell scripts
- Hook system for custom actions during theme changes
- Support for multiple color schemes
- Extensible with custom hooks and utilities

## Directory Structure
```
.
├── generate-theme.sh           # Main script to generate/apply themes
├── current-theme/              # Symlinks and generated configs for the active theme
│   ├── colors.sh
│   ├── hypr.conf
│   └── kitty.conf
├── hooks/                      # Hook scripts for theme application
│   ├── hyprland.sh
│   └── kitty.sh
├── themes/                     # Available color themes
│   └── catpuccin-frappe/
│       └── colors.sh
├── utils/                      # Utility scripts
│   └── hook-framework.sh
```

## Usage
1. **Add a new theme:**
   - Place your theme's `colors.sh` in the `themes/<theme-name>/` directory.
2. **Generate and apply a theme:**
   - Run `./generate-theme.sh <theme-name>` to generate configs and apply the theme.
3. **Hooks:**
   - Custom actions (e.g., reloading Hyprland, updating Kitty colors) are handled by scripts in the `hooks/` directory.

## Example
```sh
./generate-theme.sh catpuccin-frappe
```

## Extending
- Add new hooks in the `hooks/` directory for other applications.
- Add new themes in the `themes/` directory.

## Requirements
- Hyprland
- A shell
- Thats it.
