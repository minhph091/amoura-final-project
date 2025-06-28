package com.amoura.module.profile.api;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.junit.jupiter.api.*;

import java.util.List;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

public class ProfileControllerTests {
    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;
    }
    @Test
    @DisplayName("Lấy profile người dùng hiện tại - Token hợp lệ")
    public void getCurrentUserProfile_WithValidToken() {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUxMTExMjM0LCJleHAiOjE3NTExOTc2MzR9.5tcooM25TcrUftkjEwRQcYPGirn8ORyGXptXK0jYZgw";

        RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .when()
                .get("/profiles/me")
                .then()
                .log().all()
                .statusCode(200);
    }

    @Test
    @DisplayName("Lấy profile người dùng hiện tại - Không có token")
    public void getCurrentUserProfile_WithInvalidToken() {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUxMTExMjM0LCJleHAiOjE3NTExOTc2MzR9.5tcooM25TcrUftkjEwRQcYPGirn8ORyGXptXK0jYZgw";

        RestAssured
                .given()
                .when()
                .get("/profiles/me")
                .then()
                .log().all()
                .statusCode(403);
    }

    @Test
    @DisplayName("Lấy profile theo userId - Token hợp lệ")
    public void getCurrentUserProfileById_WithValidToken() {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUxMTExMjM0LCJleHAiOjE3NTExOTc2MzR9.5tcooM25TcrUftkjEwRQcYPGirn8ORyGXptXK0jYZgw";
        int userId = 1;
        RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .pathParam("userId", userId)
                .when()
                .get("/profiles/{userId}")
                .then()
                .log().all()
                .statusCode(200);
    }

    @Test
    @DisplayName("Lấy profile theo userId - Không có token")
    public void getCurrentUserProfileById_WithInvalidToken() {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUwNzgwODA4LCJleHAiOjE3NTA4NjcyMDh9.5-BS72CYrwS-gVCTbbr0mtA7j8YIkXGR0KvNJW6sqkA";
        int userId = 1;
        RestAssured
                .given()
                .pathParam("userId", userId)
                .when()
                .get("/profiles/{userId}")
                .then()
                .log().all()
                .statusCode(403);
    }
    @Test
    @DisplayName("Lấy profile theo userId không tồn tại - Token hợp lệ ")
    public void getProfileById_WithValidTokenButUserNotFound () {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUxMTExMjM0LCJleHAiOjE3NTExOTc2MzR9.5tcooM25TcrUftkjEwRQcYPGirn8ORyGXptXK0jYZgw "; // token hợp lệ
        int nonExistentUserId = 99999;

        RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .pathParam("userId", nonExistentUserId)
                .when()
                .get("/profiles/{userId}")
                .then()
                .log().all()
                .statusCode(404);
    }
    @Test
    @DisplayName("Lấy các tùy chọn cấu hình profile - Token hợp lệ")
    public void getAllProfileOptions_WithValidToken() {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUxMTExMjM0LCJleHAiOjE3NTExOTc2MzR9.5tcooM25TcrUftkjEwRQcYPGirn8ORyGXptXK0jYZgw";
        RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .when()
                .get("/profiles/options")
                .then()
                .log().all()
                .statusCode(200);
    }
    @Test
    @DisplayName("Cập nhật profile người dùng - Dữ liệu hợp lệ ")
    public void updateProfile_WithFullValidData() {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJuZ3V5ZW4udmFuLmFuQGV4YW1wbGUuY29tIiwidXNlcklkIjoxLCJyb2xlcyI6WyJST0xFX1VTRVIiXSwiaWF0IjoxNzUxMTExMjM0LCJleHAiOjE3NTExOTc2MzR9.5tcooM25TcrUftkjEwRQcYPGirn8ORyGXptXK0jYZgw";

        String requestBody = """
{
  "dateOfBirth": "2004-08-05",
  "height": 160,
  "bodyTypeId": 2,
  "sex": "female",
  "orientationId": 3,
  "jobIndustryId": 7,
  "drinkStatusId": 2,
  "smokeStatusId": 1,
  "interestedInNewLanguage": true,
  "educationLevelId": 3,
  "dropOut": false,
  "locationPreference": 1,
  "bio": "Hello, I’m bé mi ",
  "location": {
    "latitude": 10.762622,
    "longitude": 106.660172,
    "country": "Vietnam",
    "state": "Ha Noi",
    "city": "District 1"
  },
  "interestIds": [4, 6],
  "languageIds": [3, 20],
  "petIds": [2, 3]
}
    """;

        RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType("application/json")
                .body(requestBody)
                .when()
                .patch("/profiles/me")
                .then()
                .log().all()
                .statusCode(200);
    }

}


