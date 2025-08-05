package com.amoura.module.user.api;

import com.amoura.common.LoginAndGetToken;
import io.restassured.RestAssured;
import io.restassured.response.Response;
import org.junit.jupiter.api.*;

import static io.restassured.RestAssured.given;
import com.amoura.common.LoginAndGetToken;


public class AuthControllerTests {

    static String jwtToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;
        jwtToken = LoginAndGetToken.execute();
    }



    @Test
    @DisplayName(" Đăng nhập với tài khoản hợp lệ")
    public void testLoginWithValidCredentials() {
        String body = """
        {
            "email": "user1@gmail.com",
            "password": "Amoura123@",
            "loginType": "EMAIL_PASSWORD"
        }
        """;

        Response response = given()
                .contentType("application/json")
                .body(body)
                .when()
                .post("/auth/login");

        Assertions.assertEquals(200, response.getStatusCode(), "Sai mã trạng thái");
        Assertions.assertNotNull(response.jsonPath().getString("accessToken"), "accessToken không được null");
    }

    @Test
    @DisplayName("Thiếu email")
    public void testLoginMissingEmail() {
        String body = """
        {
            "password": "Amoura123@",
            "loginType": "EMAIL_PASSWORD"
        }
        """;

        Response response = given()
                .contentType("application/json")
                .body(body)
                .when()
                .post("/auth/login");

        Assertions.assertEquals(400, response.getStatusCode(), "API phải trả về 400 khi thiếu email");
        Assertions.assertEquals("EMAIL_REQUIRED", response.jsonPath().getString("errorCode"));

    }

    @Test
    @DisplayName("Sai định dạng email")
    public void testLoginWithInvalidEmailFormat() {
        String body = """
        {
            "email": "abc123",
            "password": "Amoura123@",
            "loginType": "EMAIL_PASSWORD"
        }
        """;

        Response response = given()
                .contentType("application/json")
                .body(body)
                .when()
                .post("/auth/login");


        Assertions.assertEquals(400, response.getStatusCode(), "Sai định dạng email phải trả về 400");
        Assertions.assertEquals("VALIDATION_ERROR", response.jsonPath().getString("errorCode"));
    }

    @Test
    @DisplayName("Thiếu mật khẩu")
    public void testLoginMissingPassword() {
        String body = """
    {
        "email": "nguyen.van.an@example.com",
        "loginType": "EMAIL_PASSWORD"
    }
    """;

        Response response = given()
                .contentType("application/json")
                .body(body)
                .when()
                .post("/auth/login");


        Assertions.assertEquals(400, response.getStatusCode(), "Thiếu mật khẩu phải trả về 400");
        Assertions.assertEquals("PASSWORD_REQUIRED", response.jsonPath().getString("errorCode"));

        String message = response.jsonPath().getString("message");
        Assertions.assertEquals("Password is required", message);
    }


}