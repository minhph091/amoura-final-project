package com.amoura.module.profile.api;

import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

public class ProfileControllerTests {
    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;
    }

    @Test
    @DisplayName("Lấy thông tin người dùng tồn tại theo id")
    public void getProfileWithIdValidCredentials() {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUwNzgwODA4LCJleHAiOjE3NTA4NjcyMDh9.5-BS72CYrwS-gVCTbbr0mtA7j8YIkXGR0KvNJW6sqkA";
        int userId = 1;
        RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .pathParam("userId", userId)
                .when()
                .get("/profiles/{userId}")
                .then()
                .statusCode(200);
    }

    @Test
    @DisplayName("Lấy thông tin người dùng không xác thực")
    public void getProfileWithIdInvalidCredentials() {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUwNzgwODA4LCJleHAiOjE3NTA4NjcyMDh9.5-BS72CYrwS-gVCTbbr0mtA7j8YIkXGR0KvNJW6sqkA";
        int userId = 1;
        RestAssured
                .given()
                .pathParam("userId", userId)
                .when()
                .get("/profiles/{userId}")
                .then()
                .statusCode(403);
    }
}


