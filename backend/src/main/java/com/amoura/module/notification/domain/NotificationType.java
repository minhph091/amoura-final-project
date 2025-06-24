package com.amoura.module.notification.domain;

public enum NotificationType {
    MATCH("match"),
    MESSAGE("message"),
    SYSTEM("system"),
    MARKETING("marketing"),
    PROFILE_UPDATE("profile_update"),
    SECURITY_ALERT("security_alert");
    
    private final String value;
    
    NotificationType(String value) {
        this.value = value;
    }
    
    public String getValue() {
        return value;
    }
    
    public static NotificationType fromString(String text) {
        for (NotificationType type : NotificationType.values()) {
            if (type.value.equalsIgnoreCase(text)) {
                return type;
            }
        }
        throw new IllegalArgumentException("No constant with text " + text + " found");
    }
} 