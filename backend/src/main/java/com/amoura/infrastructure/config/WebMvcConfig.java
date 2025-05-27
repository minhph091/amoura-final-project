package com.amoura.infrastructure.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
@Slf4j
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${file.storage.local.upload-dir}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        try {
            // Ensure the upload directory exists
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String uploadAbsolutePath = uploadPath.toFile().getAbsolutePath();
            log.info("Configuring static resource handler for upload directory: {}", uploadAbsolutePath);

            registry.addResourceHandler("/files/**")
                    .addResourceLocations("file:" + uploadAbsolutePath + "/");
        } catch (IOException e) {
            log.error("Failed to create upload directory: {}", e.getMessage());
            throw new RuntimeException("Failed to initialize upload directory", e);
        }
    }
} 