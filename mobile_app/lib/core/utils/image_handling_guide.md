# Image Handling Guide

## Overview

This document outlines the standardized approach for handling images throughout the Amoura app to prevent issues like image jumping and ensure smooth user experience.

## PhotoModel URL Methods

### Available Methods:

- `photo.rawUrl` - Raw URL from server (without transformation)
- `photo.displayUrl` - Transformed URL for display (localhost -> 10.0.2.2)
- `photo.cacheUrl` - URL for caching purposes (same as displayUrl)
- `photo.url` - Legacy getter (returns displayUrl for backward compatibility)

### Usage Guidelines:

#### 1. For Display (CachedNetworkImage, Image.network):

```dart
// ✅ CORRECT
CachedNetworkImage(
  imageUrl: photo.displayUrl,
  // ...
)

// ❌ WRONG - Double transformation
CachedNetworkImage(
  imageUrl: UrlTransformer.transform(photo.url),
  // ...
)
```

#### 2. For Pre-caching:

```dart
// ✅ CORRECT
final provider = CachedNetworkImageProvider(photo.cacheUrl);
precacheImage(provider, context);

// ❌ WRONG - Inconsistent caching
final provider = CachedNetworkImageProvider(photo.url);
precacheImage(provider, context);
```

#### 3. For Debugging/Logging:

```dart
// ✅ CORRECT
print('Raw URL: ${photo.rawUrl}');
print('Display URL: ${photo.displayUrl}');
```

## Pre-caching Strategy

### Initial Load:

- Pre-cache first 4 profiles (index 0-3) for smooth initial experience
- Use `_ensureImagesReady()` method

### During Swiping:

- Pre-cache next 2 profiles when user swipes
- Use `_precacheNextImageOnSwipe()` method

### Cache Management:

- Use `RecommendationCache.instance.ensurePrecacheForProfiles()` for bulk operations
- Clear cache when force refreshing

## Widget Keys

### ImageCarousel:

```dart
ImageCarousel(
  key: ValueKey('profile_${profile.userId}_carousel'),
  // ...
)
```

### ProfileCard:

```dart
ProfileCard(
  key: ValueKey('profile_${profile.userId}'),
  // ...
)
```

## Common Issues and Solutions

### 1. Image Jumping:

- **Cause**: Inconsistent URL usage between caching and display
- **Solution**: Always use `photo.displayUrl` for display and `photo.cacheUrl` for caching

### 2. Double Transformation:

- **Cause**: Transforming URL multiple times
- **Solution**: Use the appropriate getter method, don't manually transform

### 3. Cache Miss:

- **Cause**: Different URLs used for caching vs display
- **Solution**: Use `photo.cacheUrl` consistently for all caching operations

## Best Practices

1. **Always use the appropriate getter method** - Don't manually transform URLs
2. **Pre-cache aggressively** - Cache more profiles than needed for smooth experience
3. **Use unique keys** - Ensure Flutter doesn't confuse widgets between profiles
4. **Consistent URL usage** - Use the same URL for caching and display
5. **Error handling** - Always provide placeholder and error widgets for images

## Migration Notes

If you're updating existing code:

1. Replace `UrlTransformer.transform(photo.url)` with `photo.displayUrl`
2. Replace `UrlTransformer.transform(photo.path)` with `photo.cacheUrl`
3. Update pre-caching logic to use `photo.cacheUrl`
4. Add unique keys to ImageCarousel widgets
