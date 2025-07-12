package com.amoura.common;

import io.restassured.RestAssured;
import io.restassured.response.Response;

public class LoginAndGetToken {
    String jwtToken = LoginAndGetToken.execute();
    private static String cachedToken;

    public static String execute() {
        if (cachedToken != null) return cachedToken;

        String requestBody = """
    {
      "email": "user1@gmail.com",
      "password": "Amoura123@",
      "loginType": "EMAIL_PASSWORD"
    }
""";


        Response response = RestAssured
                .given()
                .contentType("application/json")
                .body(requestBody)
                .when()
                .post("/auth/login");

        response.then().log().ifValidationFails().statusCode(200);

        cachedToken = response.jsonPath().getString("accessToken");
        return cachedToken;
    }

    public static void reset() {
        cachedToken = null;
    }
}
