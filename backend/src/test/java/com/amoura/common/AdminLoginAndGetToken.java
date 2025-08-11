package com.amoura.common;

import io.restassured.RestAssured;
import io.restassured.response.Response;

public class AdminLoginAndGetToken {
    private static String cachedAdminToken;

    public static String execute() {
        if (cachedAdminToken != null) return cachedAdminToken;

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

        cachedAdminToken = response.jsonPath().getString("accessToken");
        return cachedAdminToken;
    }

}
