package com.amoura.module.admin.api;

import com.amoura.common.AdminLoginAndGetToken;
import com.amoura.common.LoginAndGetToken;
import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

public class AdminControllerTests {

    static String adminToken;
    static String userToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;

        adminToken = AdminLoginAndGetToken.execute();
        userToken = LoginAndGetToken.execute();
    }

    @Test
    @DisplayName("Lấy admin dashboard - Token hợp lệ")
    void getAdminDashboard_WithValidAdminToken() {
        RestAssured
                .given()
                .header("Authorization", "Bearer " + adminToken)
                .when()
                .get("/admin/dashboard")
                .then()
                .log().all()
                .statusCode(200);
    }

    @Test
    @DisplayName("Lấy admin dashboard - Token user thường ")
    void getAdminDashboard_WithUserToken() {
        RestAssured
                .given()
                .header("Authorization", "Bearer " + userToken)
                .when()
                .get("/admin/dashboard")
                .then()
                .log().all()
                .statusCode(403);
    }

}
