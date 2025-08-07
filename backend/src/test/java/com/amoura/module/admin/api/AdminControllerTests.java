package com.amoura.module.admin.api;

import com.amoura.common.AdminLoginAndGetToken;
import com.amoura.common.LoginAndGetToken;
import io.restassured.RestAssured;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.hamcrest.Matchers.equalTo;
import static org.hamcrest.Matchers.notNullValue;
import static org.hamcrest.Matchers.*;


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

    @Test
    @DisplayName("Lấy thông tin user theo ID ")
    void getUserById_WithAdminToken_UserExists() {
        int userId = 1;

        RestAssured
                .given()
                .header("Authorization", "Bearer " + adminToken)
                .when()
                .get("/admin/users/" + userId)
                .then()
                .log().all()
                .statusCode(200)
                .body("id", equalTo(userId))
                .body("username", notNullValue());
    }

    @Test
    @DisplayName("Lấy thông tin user theo ID không tồn tại")
    void getUserById_WithAdminToken_UserNotFound() {
        int userId = 999999;

        RestAssured
                .given()
                .header("Authorization", "Bearer " + adminToken)
                .when()
                .get("/admin/users/" + userId)
                .then()
                .log().all()
                .statusCode(404);
    }

    @Test
    @DisplayName("Lấy thông tin user theo ID - Token user thường")
    void getUserById_WithUserToken() {
        int userId = 1;

        RestAssured
                .given()
                .header("Authorization", "Bearer " + userToken)
                .when()
                .get("/admin/users/" + userId)
                .then()
                .log().all()
                .statusCode(403);
    }




}
