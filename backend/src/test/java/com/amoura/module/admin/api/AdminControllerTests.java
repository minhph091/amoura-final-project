package com.amoura.module.admin.api;

import com.amoura.common.AdminLoginAndGetToken;
import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

public class AdminControllerTests {

    static String jwtToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;
        jwtToken = AdminLoginAndGetToken.execute();
    }

    @Test
    @DisplayName("Lấy admin dashboard - Token hợp lệ")
    void getAdminDashboard_WithValidAdminToken() {
        RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .when()
                .get("/admin/dashboard")
                .then()
                .log().all()
                .statusCode(200);
    }
}
