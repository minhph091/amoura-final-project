package com.amoura.module.Notification.api;

import io.restassured.RestAssured;
import io.restassured.path.json.JsonPath;
import io.restassured.response.Response;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static io.restassured.RestAssured.given;
import static org.junit.jupiter.api.Assertions.*;

public class NotificationControllerTests {

    private static String jwtToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;
        jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUyMTQ5NzYyLCJleHAiOjE3NTIyMzYxNjJ9.qnQWY2tb-9a4-ULcg16MSOW827adGnx9Q14W0t3AQkw";

    }

    @Test
    @DisplayName("lấy thông báo ")
    void getNotifications(){
        Response response = given()
                .header("Authorization", "Bearer " + jwtToken)
                .queryParam("limit", 5)
                .queryParam("direction", "NEXT")
                .when()
                .get("/notifications")
                .then()
                .statusCode(200)
                .log().all()
                .extract().response();

        JsonPath json = response.jsonPath();
    }
    @Test
    @DisplayName("lấy thông báo chưa đọc")
    void getUnreadNotifications() {
        Response response = given()
                .header("Authorization", "Bearer " +jwtToken)
                .log().all()
                .when()
                .get("/notifications/unread")
                .then()
                .log().all()
                .statusCode(200)
                .extract()
                .response();
    }
    @Test
    @DisplayName("lấy số lượng thông báo chưa đọc")
    void countUnreadNotifications() {
        Response response = given()
                .header("Authorization", "Bearer " + jwtToken)
                .when()
                .get("/notifications/unread")
                .then()
                .statusCode(200)
                .extract().response();


        int unreadCount = response.jsonPath().getList("$").size();

        System.out.println("Số lượng thông báo chưa đọc: " + unreadCount);
        assertTrue(unreadCount >= 0);
    }
    @Test
    @DisplayName("Đánh dấu 1 thông báo là đã đọc")
    void markNotificationAsRead() {
        long notificationId = 1;
        given()
                .header("Authorization", "Bearer " + jwtToken)
                .log().all()
                .when()
                .put("/notifications/{id}/read", notificationId)
                .then()
                .log().all()
                .statusCode(200);
    }
    @Test
    @DisplayName("Đánh dấu tất cả thông báo là đã đọc")
    void markAllNotificationsAsRead() {
        given()
                .header("Authorization", "Bearer " + jwtToken)
                .log().all()
                .when()
                .put("/notifications/read-all")
                .then()
                .log().all()
                .statusCode(200);
    }

}
