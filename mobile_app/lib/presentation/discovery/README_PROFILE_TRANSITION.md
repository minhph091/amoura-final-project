# Profile Transition Fix - Discovery View

## Vấn đề đã được giải quyết

Lỗi "nhảy ảnh" khi vuốt profile trong discovery view đã được sửa bằng cách:

1. **Quản lý cache thông minh**: Clear cache của profile cũ ngay lập tức khi chuyển profile
2. **Preload ảnh mới**: Preload ảnh của profile mới trước khi hiển thị
3. **State management**: Reset PageController và state đúng cách
4. **Transition service**: Service chuyên dụng để quản lý việc chuyển profile

## Các file đã được cập nhật

### 1. `image_carousel.dart`

- Thêm `_isLoadingNewProfile` flag để tránh preload conflict
- Cải thiện logic `didUpdateWidget` để detect profile change chính xác
- Clear cache triệt để khi chuyển profile

### 2. `swipeable_card.dart`

- Sử dụng `ProfileTransitionService` để clear cache
- Force clear image cache để đảm bảo không còn ảnh cũ

### 3. `discovery_viewmodel.dart`

- Thêm method `getNextProfile()` để chuẩn bị transition
- Cải thiện logic clear cache trong `_moveToNextProfile()`

### 4. `image_precache_service.dart`

- Cải thiện method `removeProfileFromCache()`
- Thêm method `clearCache()` để clear toàn bộ cache

### 5. `profile_transition_service.dart` (Mới)

- Service chuyên dụng để quản lý việc chuyển profile
- Preload ảnh mới và clear cache cũ
- Tracking trạng thái transition

### 6. `profile_transition_wrapper.dart` (Mới)

- Widget wrapper để đảm bảo profile được load đầy đủ trước khi hiển thị
- Loading indicator khi đang prepare transition

### 7. `discovery_view.dart`

- Sử dụng `ProfileTransitionWrapper` thay vì `SwipeableCardStack` trực tiếp
- Thêm logic prepare transition khi swipe

## Cách hoạt động

1. **Khi user vuốt profile**:

   - `_onSwiped()` được gọi
   - `_prepareNextProfileTransition()` preload ảnh profile tiếp theo
   - `ProfileTransitionService` quản lý việc preload

2. **Khi chuyển profile**:

   - `ProfileTransitionWrapper` detect profile change
   - Clear cache profile cũ ngay lập tức
   - Preload ảnh profile mới
   - Chỉ hiển thị khi ảnh đã sẵn sàng

3. **Cache management**:
   - Clear cache profile cũ: `CachedNetworkImage.evictFromCache()`
   - Force clear image cache: `imageCache.clear()`
   - Preload ảnh mới: `precacheImage()`

## Debug

Để debug, kiểm tra các log sau:

```
[TRANSITION_DEBUG] Clearing cache for profile {userId}
[TRANSITION_DEBUG] Evicting: {imageUrl}
[TRANSITION_DEBUG] Preloaded: {imageUrl}
[IMAGE_DEBUG] Profile change detected: {oldKey} -> {newKey}
[SWIPE_DEBUG] Profile changed from {oldUserId} to {newUserId}
```

## Performance Optimization

1. **Preload strategy**: Chỉ preload 3 ảnh đầu tiên của mỗi profile
2. **Cache cleanup**: Clear cache profile cũ ngay lập tức
3. **Memory management**: Giới hạn số profile được cache
4. **Lazy loading**: Chỉ load ảnh khi cần thiết

## Testing

Để test fix này:

1. Vuốt profile nhanh và liên tục
2. Kiểm tra không có hiện tượng nhảy ảnh
3. Kiểm tra performance không bị ảnh hưởng
4. Kiểm tra memory usage ổn định
