# Copilot Instructions for SourcePawn Shop Plugin Development

## Repository Overview

This repository contains **Shop_OnlineCredits**, a SourcePawn plugin for SourceMod that extends the Shop plugin ecosystem. The plugin displays online players' credits and gold in a menu interface, integrating with the Shop Core plugin system.

**Key Facts:**
- **Language**: SourcePawn
- **Platform**: SourceMod 1.11+ (specified in sourceknight.yaml)
- **Build System**: SourceKnight (not manual spcomp)
- **Plugin Type**: Shop ecosystem extension
- **Complexity**: Simple menu-based plugin (~83 lines)

## Project Structure

```
├── .github/
│   ├── workflows/ci.yml          # Automated build, test, and release pipeline
│   └── dependabot.yml            # Dependency updates for GitHub Actions
├── addons/sourcemod/scripting/
│   └── Shop_OnlineCredits.sp     # Main plugin source file
├── sourceknight.yaml             # Build configuration and dependencies
└── .gitignore                    # Excludes build artifacts (.smx, .sourceknight/, etc.)
```

## Build System: SourceKnight

**IMPORTANT**: This project uses SourceKnight, not manual compilation with spcomp.

### Build Configuration (`sourceknight.yaml`)
- **Output Directory**: `/addons/sourcemod/plugins`
- **Dependencies**: SourceMod 1.11.0-git6934 + Shop Core plugin
- **Target**: `Shop_OnlineCredits` (produces Shop_OnlineCredits.smx)

### Build Commands
```bash
# Build the plugin (use in CI or local development)
sourceknight build

# The build system automatically:
# 1. Downloads SourceMod and Shop Core dependencies
# 2. Compiles Shop_OnlineCredits.sp to Shop_OnlineCredits.smx
# 3. Places output in /addons/sourcemod/plugins/
```

### Dependency Management
- **SourceMod**: Auto-downloaded from AlliedMods (version locked)
- **Shop Core**: Auto-downloaded from srcdslab/sm-plugin-Shop-Core
- Include files are automatically linked from dependencies

## Shop Plugin Ecosystem Context

This plugin is part of the **Shop plugin ecosystem** developed by srcdslab:

### Core Integration
```cpp
#include <shop>                    // Main Shop API
Shop_IsStarted()                   // Check if Shop Core is loaded
Shop_AddToFunctionsMenu()          // Register menu function
Shop_GetClientCredits(client)      // Get player credits
Shop_GetClientGold(client)         // Get player gold (optional)
Shop_IsAuthorized(client)          // Check if player is authenticated
```

### Plugin Lifecycle
1. `OnPluginStart()`: Check Shop status, register optional natives
2. `Shop_Started()`: Register with Shop menu system
3. `OnPluginEnd()`: Cleanup Shop integration
4. `AskPluginLoad2()`: Mark optional natives (for backwards compatibility)

## Code Style & Standards

### SourcePawn Best Practices (Already Followed)
```cpp
#pragma newdecls required          // Enforce new declaration syntax
#pragma semicolon 1               // Require semicolons

// Variable naming
bool canUseGold;                   // camelCase for local/global vars
int client, credits, gold;         // descriptive names

// Function naming  
public void OnPluginStart()        // PascalCase for public functions
public int PlayerList_Handler()    // PascalCase with descriptive names

// Memory management
Menu PlayerList = new Menu();      // Create objects
PlayerList.Close();                // Always clean up (done in MenuAction_End)
```

### Style Specifics for This Project
- **Indentation**: Use tabs (4 spaces equivalent)
- **Variables**: camelCase, descriptive names
- **Functions**: PascalCase, action-oriented names
- **No g_ prefix**: This simple plugin doesn't use global variables
- **Consistent formatting**: Follow existing patterns in Shop_OnlineCredits.sp

## Development Workflow

### Making Changes
1. **Edit Source**: Modify `/addons/sourcemod/scripting/Shop_OnlineCredits.sp`
2. **Build Locally**: Run sourceknight build (if available)
3. **Test**: Deploy .smx to test server with Shop Core plugin
4. **Commit**: Changes trigger CI/CD pipeline

### Testing Requirements
- **Functional Test**: Plugin loads without errors
- **Shop Integration**: Menu appears in Shop functions menu
- **Display Test**: Player credits/gold display correctly
- **No Test Framework**: This project doesn't have automated tests

### Version Management
- Update `#define PLUGIN_VERSION` in source file
- Use semantic versioning (MAJOR.MINOR.PATCH)
- CI automatically creates releases on tags

## CI/CD Pipeline (`.github/workflows/ci.yml`)

### Automated Workflow
1. **Build**: SourceKnight compiles plugin on Ubuntu
2. **Package**: Creates distribution package
3. **Tag**: Auto-creates 'latest' tag on main/master
4. **Release**: Uploads .tar.gz with compiled plugin

### Triggering Releases
- **Latest Release**: Push to main/master branch
- **Versioned Release**: Create git tag (e.g., `v1.6.0`)
- **Manual Trigger**: Use workflow_dispatch

## Common Tasks & Patterns

### Adding New Features
```cpp
// 1. Add to OnFuncSelect if menu-related
public bool OnFuncSelect(int client) {
    // Create menu logic
    Menu menu = new Menu(MenuHandler);
    // Remember: menu.Close() in MenuAction_End
}

// 2. Add new menu handlers following pattern
public int NewMenuHandler(Menu menu, MenuAction action, int client, int slot) {
    switch (action) {
        case MenuAction_Cancel: Shop_ShowFunctionsMenu(client);
        case MenuAction_End: menu.Close();
    }
}
```

### Working with Shop API
```cpp
// Always check authorization
if (!Shop_IsAuthorized(client)) return;

// Handle optional features safely  
if (CanTestFeatures() && GetFeatureStatus(FeatureType_Native, "Shop_GetClientGold") == FeatureStatus_Available) {
    // Use optional gold feature
}

// Get player data
int credits = Shop_GetClientCredits(client);
int gold = Shop_GetClientGold(client);  // If available
```

### Error Handling Patterns
```cpp
// Client validation (existing pattern)
if (!IsClientInGame(i) || IsFakeClient(i) || !Shop_IsAuthorized(i)) continue;

// Menu safety (existing pattern)
if (client > 0 && IsClientInGame(client) && !IsFakeClient(client) && Shop_IsAuthorized(client)) {
    Shop_ShowFunctionsMenu(client);
}
```

## File Organization

### Current Structure (Single File Plugin)
- **Main Logic**: All in `Shop_OnlineCredits.sp`
- **No Includes**: Plugin doesn't define natives
- **No Configs**: No configuration files needed
- **No Translations**: Uses hardcoded English strings

### If Expanding Plugin
- **Add Translations**: Create `addons/sourcemod/translations/shop_onlinecredits.phrases.txt`
- **Add Configs**: Create `addons/sourcemod/configs/` files if needed
- **Split Code**: Create includes in `addons/sourcemod/scripting/include/` if defining natives

## Performance Considerations

### Current Implementation (Efficient)
- **O(n) iteration**: Over connected clients (unavoidable)
- **Minimal memory**: Menu created/destroyed per use
- **No timers**: Event-driven only
- **Lazy loading**: Optional features checked once at startup

### If Adding Features
- **Cache results**: For expensive Shop API calls
- **Avoid loops**: In frequently called functions
- **Memory cleanup**: Always use `delete` for handles
- **Async operations**: For any database queries

## Debugging & Troubleshooting

### Common Issues
1. **Shop Core Missing**: Plugin won't register menu items
2. **Permission Errors**: Check `Shop_IsAuthorized()` calls
3. **Build Failures**: Check sourceknight.yaml dependencies
4. **Menu Errors**: Ensure `menu.Close()` in `MenuAction_End`

### Debugging Tools
- **SourceMod Logs**: Check error.log for plugin errors
- **Console Output**: Use `PrintToServer()` for debugging
- **Client Console**: Use `PrintToChat()` for client debugging

## Dependencies & Compatibility

### Required Dependencies
- **SourceMod**: 1.11+ (automatically managed)
- **Shop Core**: Latest from srcdslab (automatically managed)

### Optional Dependencies
- **Shop Gold System**: Auto-detected via `CanTestFeatures()`

### Compatibility Notes
- **Backwards Compatible**: Uses `MarkNativeAsOptional()` for gold features
- **Forward Compatible**: Standard Shop API calls
- **Game Support**: All Source engine games supported by SourceMod

## Release Management

### Version Updates
1. Update `#define PLUGIN_VERSION` in source
2. Commit changes to trigger CI
3. Create git tag for versioned release
4. CI automatically builds and releases

### Distribution
- **Automatic**: CI creates .tar.gz with compiled plugin
- **Manual**: Build locally and copy .smx to server
- **Package Contents**: `/addons/sourcemod/plugins/Shop_OnlineCredits.smx`

---

## Quick Reference Commands

```bash
# Build plugin locally (if SourceKnight available)
sourceknight build

# Check git status
git status

# Check CI status
# View: https://github.com/srcdslab/sm-plugin-Shop_OnlineCredits/actions

# Test plugin deployment
# Copy .smx to: addons/sourcemod/plugins/
# Restart server or: sm plugins reload Shop_OnlineCredits
```

## Important Notes for AI Coding Agents

1. **Build System**: Always use SourceKnight, never manual spcomp commands
2. **Dependencies**: Don't modify sourceknight.yaml unless adding new dependencies
3. **Code Style**: Follow existing patterns exactly (tabs, naming, structure)
4. **Testing**: No automated tests - verify by deploying to test server
5. **Minimal Changes**: This is a simple, working plugin - avoid over-engineering
6. **Shop Integration**: Always maintain Shop API compatibility
7. **Memory Management**: Follow existing menu cleanup patterns
8. **CI/CD**: Trust the automated pipeline - don't manually manage releases