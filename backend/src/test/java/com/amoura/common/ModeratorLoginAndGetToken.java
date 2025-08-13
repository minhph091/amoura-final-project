package com.amoura.common;

import io.restassured.RestAssured;
import io.restassured.response.Response;

public class ModeratorLoginAndGetToken {
    public static String cachedModeratorToken;
    public static String execute() {
        if (cachedModeratorToken != null) return cachedModeratorToken;

        String requestBody = """
        {
          "email": "admin@gmail.com",
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

        cachedModeratorToken = response.jsonPath().getString("accessToken");
        return cachedModeratorToken;
    }
}
