package com.amoura.module.Matching.api;

import com.amoura.module.matching.dto.UserRecommendationDTO;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.*;

public class MatchingControllerTests {

    private static String jwtToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;
        jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyODFAZ21haWwuY29tIiwidXNlcklkIjo4MSwicm9sZXMiOlsiUk9MRV9VU0VSIl0sImlhdCI6MTc1MjMxMjM0MywiZXhwIjoxNzUyMzk4NzQzfQ.hsE9_ddmahxj5SMhm6IHcuHOFfvXoDgFiMyEB8GqkYw";

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

}
