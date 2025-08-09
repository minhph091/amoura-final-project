# Admin Dashboard - Build Instructions

## Quick Start Commands

### For PNPM users (Recommended):
```bash
cd admin_dashboard
pnpm install
pnpm build
```

### For NPM users:
```bash
cd admin_dashboard
npm run install:force
npm run build
```

### Alternative for NPM (if above fails):
```bash
cd admin_dashboard
npm install --legacy-peer-deps
npm run build
```

## Build Commands

| Command | Description |
|---------|-------------|
| `pnpm build` | Build with PNPM (recommended) |
| `npm run build:force` | Build with NPM (handles React conflicts) |
| `npm run build` | Standard build |
| `npm run build:static` | Static export build |

## Troubleshooting

### React Version Conflicts
If you see `ERESOLVE` errors with React dependencies:

1. **Use PNPM (Recommended):**
   ```bash
   pnpm install
   pnpm build
   ```

2. **Use NPM with legacy peer deps:**
   ```bash
   npm install --legacy-peer-deps
   npm run build
   ```

3. **Force installation:**
   ```bash
   npm run install:force
   npm run build
   ```

### Common Issues
- **vaul@0.9.9 React compatibility**: Fixed with `.npmrc` and overrides
- **Radix UI conflicts**: Handled by package overrides
- **Different React versions**: Supported 18.x and 19.x

## Production Build
The app supports both React 18 and React 19. Static files will be generated in the `out/` directory.
