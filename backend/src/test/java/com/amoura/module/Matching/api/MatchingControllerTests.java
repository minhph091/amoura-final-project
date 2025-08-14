package com.amoura.module.Matching.api;

import com.amoura.module.matching.dto.UserRecommendationDTO;
import com.amoura.common.LoginAndGetToken;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;


import java.util.List;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.*;

public class MatchingControllerTests {

    static String jwtToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;
        jwtToken = LoginAndGetToken.execute();
    }

    @Test
    @DisplayName("Swipe user thành công")
    public void swipeUser() {
        String requestBody = """
            {
                "targetUserId": 5,
                "isLike": true
            }
        """;

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/matching/swipe")
                .then()
                .log().ifValidationFails()
                .extract().response();

        System.out.println(response.asPrettyString());

    }

    @Test
    @DisplayName("Swipe user thất bại do token không hợp lệ")
    public void swipeUserWithInvalidToken() {
        String invalidToken = "invalidToken";
        String requestBody = """
            {
                "targetUserId": 5,
                "isLike": true
            }
        """;

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + invalidToken)
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/matching/swipe")
                .then()
                .log().all().statusCode(403)
                .extract().response();


    }


    @Test
    @DisplayName("Swipe user không tồn tại")
    public void swipeNonExistentUser() {
        String requestBody = """
        {
            "targetUserId": 999999,
            "isLike": true
        }
    """;

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/matching/swipe")
                .then()
                .log().all()
                .extract().response();


        assertEquals(404, response.statusCode());
        assertEquals("Target user not found", response.jsonPath().getString("message"));
    }


    @Test
    @DisplayName("Lấy danh sách người dùng gợi ý - Token hợp lệ")
    void getRecommendations() {
        Response response = RestAssured .
                given()
                .header("Authorization", "Bearer " + jwtToken)
                .accept(ContentType.JSON)
                .when()
                .get("/matching/recommendations")
                .then()
                .log().all()
                .statusCode(200)
                .extract().response();

        UserRecommendationDTO[] users = response.as(UserRecommendationDTO[].class);
    }
    @Test
    @DisplayName("Lấy danh sách người dùng gợi ý - Token không hợp lệ")
    void getRecommendationsWithInvalidToken() {
        String invalidToken = "invalidToken";
        Response response = RestAssured .
                given()
                .header("Authorization", "Bearer " + invalidToken)
                .accept(ContentType.JSON)
                .when()
                .get("/matching/recommendations")
                .then()
                .log().all()
                .statusCode(403)
                .extract().response();

    }

    @Test
    @DisplayName("Lấy danh sách người dùng với token hợp lệ")
    public void testReceivedWithValidToken() {

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .accept(ContentType.JSON)
                .when()
                .get("/matching/received")
                .then()
                .statusCode(200)
                .extract()
                .response();

        List<?> users = response.jsonPath().getList("$");
        assertFalse(users.isEmpty(), "Response rỗng!");
    }


    @Test
    @DisplayName("Lấy danh sách người dùng đã like với token không hợp lệ")
    public void testReceivedWithInvalidToken() {
        String invalidToken = "invalidToken";

        RestAssured
                .given()
                .header("Authorization", "Bearer " + invalidToken)
                .accept(ContentType.JSON)
                .when()
                .get("/matching/received")
                .then()
                .statusCode(403);
    }


}
