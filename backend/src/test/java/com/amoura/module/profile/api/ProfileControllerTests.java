package com.amoura.module.profile.api;

import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.Map;

import static io.restassured.RestAssured.given;
import static org.junit.jupiter.api.Assertions.*;
import com.amoura.common.LoginAndGetToken;

public class ProfileControllerTests {
    static String jwtToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;
        jwtToken = LoginAndGetToken.execute();
    }


    @Test
    @DisplayName("Lấy profile người dùng hiện tại - Token hợp lệ")
    public void getCurrentUserProfile_WithValidToken() {
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
        int userId = 1;
        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .pathParam("userId", userId)
                .when()
                .get("/profiles/{userId}");
        response.then().log().all();

        int statusCode = response.getStatusCode();
        Assertions.assertEquals(200, statusCode, "Mã trạng thái phải là 200");
        int returnUserID = response.jsonPath().getInt("userId");
        Assertions.assertEquals(userId, returnUserID, "Phải trả về thông tin của ID được yêu cầu");
    }

    @Test
    @DisplayName("Lấy profile theo userId - Không có token")
    public void getCurrentUserProfileById_WithoutToken() {
        int userId = 1;
        Response response = RestAssured
                .given()
                .pathParam("userId", userId)
                .when()
                .get("/profiles/{userId}");

        int statusCode = response.getStatusCode();
        Assertions.assertEquals(403, statusCode, "Phải trả về mã lỗi 403 khi không có token");
    }


    @Test
    @DisplayName("Lấy profile theo userId không tồn tại - Token hợp lệ ")
    public void getProfileById_WithValidTokenButUserNotFound() {
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
    @Test
    @DisplayName("Ngày sinh dưới 18 tuổi - Không hợp lệ")
    public void updateProfile_Under18YearsOld() {
        String requestBody = """
            {
              "dateOfBirth": "2010-01-01"
            }
            """;

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType("application/json")
                .body(requestBody)
                .when()
                .patch("/profiles/me");

        response.
                then()
                .log().all()
                .statusCode(400);
        int statusCode = response.getStatusCode();
        Assertions.assertEquals(400, statusCode,"Người dùng phải từ 18 tuổi trở lên");

    }


}


