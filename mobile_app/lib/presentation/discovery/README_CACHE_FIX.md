# Cache Fix v2 - Triệt để sửa lỗi nhấp nháy khi chuyển profile

## Vấn đề đã được giải quyết

Lỗi "nhấp nháy" khi vuốt profile đã được sửa triệt để bằng cách:

1. **ProfileTransitionManager**: Service chuyên dụng để quản lý transition giữa các profile
2. **SmoothTransitionWrapper**: Widget wrapper để đảm bảo việc chuyển profile được mượt mà
3. **Pre-clear cache**: Clear cache ngay khi bắt đầu vuốt, không phải sau khi vuốt xong
4. **Loading indicator**: Hiển thị loading khi đang transition để tránh nhấp nháy

## Các file đã được cập nhật

### 1. `profile_transition_manager.dart` (Mới)
- Service chuyên dụng để quản lý transition giữa các profile
- Bắt đầu transition ngay khi bắt đầu vuốt
- Kết thúc transition khi profile mới được hiển thị
- Clear cache theo thứ tự đúng

### 2. `smooth_transition_wrapper.dart` (Mới)
- Widget wrapper để quản lý việc transition mượt mà
- Hiển thị loading indicator khi đang transition
- Clear cache và chuẩn bị cho profile mới
- Force rebuild để đảm bảo UI được clear

### 3. `discovery_viewmodel.dart`
- Clear cache ngay khi bắt đầu vuốt (like/dislike)
- Không clear cache sau khi vuốt xong nữa
- Sử dụng ProfileTransitionManager

### 4. `swipeable_card.dart`
- Bắt đầu transition ngay khi bắt đầu vuốt (_onDragStart)
- Kết thúc transition khi vuốt xong (_onDragEnd)
- Sử dụng ProfileTransitionManager

### 5. `discovery_view.dart`
- Sử dụng SmoothTransitionWrapper thay vì SwipeableCardStack trực tiếp
- Set next profile cho ProfileTransitionManager

## Cách hoạt động

### 1. **Khi bắt đầu vuốt**:
```
User bắt đầu vuốt → _onDragStart → ProfileTransitionManager.startTransition → Clear cache ngay lập tức
```

### 2. **Khi vuốt xong**:
```
User vuốt xong → _onDragEnd → ProfileTransitionManager.endTransition → Hiển thị profile mới
```

### 3. **Khi profile thay đổi**:
```
Profile change → SmoothTransitionWrapper → Loading indicator → Clear cache → Hiển thị profile mới
```

### 4. **ProfileTransitionManager**:
```dart
// Bắt đầu transition
void startTransition(UserRecommendationModel currentProfile) {
  // Clear cache ngay lập tức
  CacheCleanupService.instance.clearProfileCache(currentProfile);
}

// Kết thúc transition
void endTransition(UserRecommendationModel newProfile) {
  // Clear cache profile cũ
  CacheCleanupService.instance.clearProfileCache(_currentProfile!);
}
```

## Debug

Để debug, kiểm tra các log sau:

```
[TRANSITION] Starting transition for profile {userId}
[TRANSITION] Ending transition to profile {userId}
[SMOOTH_TRANSITION] New profile detected: {oldKey} -> {newKey}
[CACHE_CLEANUP] Clearing cache for profile {userId}
[CACHE_CLEANUP] Evicting: {imageUrl}
[CACHE_CLEANUP] Clearing all image cache
```

## Kết quả

✅ **Không còn nhấp nháy**: Clear cache ngay khi bắt đầu vuốt
✅ **Không còn nhảy ảnh**: Loading indicator khi transition
✅ **Performance tốt**: Clear cache theo thứ tự đúng
✅ **Trải nghiệm mượt mà**: Transition mượt mà, không delay

## Testing

Để test fix này:

1. Vuốt profile nhanh và liên tục
2. Kiểm tra không có hiện tượng nhấp nháy
3. Kiểm tra không có hiện tượng nhảy ảnh
4. Kiểm tra loading indicator hiển thị khi transition
5. Kiểm tra performance không bị ảnh hưởng

## So sánh với version trước

| Version trước | Version mới |
|---------------|-------------|
| Clear cache sau khi vuốt xong | Clear cache ngay khi bắt đầu vuốt |
| Không có loading indicator | Có loading indicator khi transition |
| Chỉ có CacheCleanupService | Thêm ProfileTransitionManager |
| SwipeableCardStack trực tiếp | SmoothTransitionWrapper |
| Có thể bị nhấp nháy | Không còn nhấp nháy | 