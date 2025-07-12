package com.amoura.module.chat.api;

import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.hamcrest.Matchers.*;
import static org.junit.jupiter.api.Assertions.*;

public class ChatControllerTests {

    private static final String BASE_URI = "http://localhost:8080";
    private static final String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyODFAZ21haWwuY29tIiwidXNlcklkIjo4MSwicm9sZXMiOlsiUk9MRV9VU0VSIl0sImlhdCI6MTc1MjMxMjM0MywiZXhwIjoxNzUyMzk4NzQzfQ.hsE9_ddmahxj5SMhm6IHcuHOFfvXoDgFiMyEB8GqkYw";

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = BASE_URI;
    }

    @Test
    @DisplayName("Lấy danh sách chat room với token hợp lệ")
    public void getChatRooms_WithValidToken_ShouldReturnChatRooms() {
        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .when()
                .get("/api/chat/rooms")
                .then()
                .log().all()
                .statusCode(200)
                .extract()
                .response();

    }

    @Test
    @DisplayName("Lấy chat room theo ID với token hợp lệ")
    public void getChatRoomById_WithValidToken() {
        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .when()
                .get("/api/chat/rooms/2700")
                .then()
                .log().all()
                .statusCode(200)
                .extract()
                .response();
    }

    @Test
    @DisplayName("Lấy chat room theo ID không tồn tại")
    public void getChatRoomById_WithInvalidToken() {
        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .when()
                .get("/api/chat/rooms/27050")
                .then()
                .log().all()
                .statusCode(404)
                .extract()
                .response();
        String message = response.jsonPath().getString("message");
        assertEquals("Chat room not found", message);
    }

    @Test
    @DisplayName("Truy cập ChatRoom không thuộc quyền truy cập")
    public void getChatRoomById_WithoutPermission() {
        String jwtToken = "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJ1c2VyODFAZ21haWwuY29tIiwidXNlcklkIjo4MSwicm9sZXMiOlsiUk9MRV9VU0VSIl0sImlhdCI6MTc1MjMxMjM0MywiZXhwIjoxNzUyMzk4NzQzfQ.hsE9_ddmahxj5SMhm6IHcuHOFfvXoDgFiMyEB8GqkYw";

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .when()
                .get("/api/chat/rooms/9999")
                .then()
                .log().all()
                .statusCode(403)
                .extract()
                .response();

        String message = response.jsonPath().getString("message");
        assertEquals("Access denied to this chat room", message);
    }
    @Test
    @DisplayName("Gửi tin nhắn văn bản thành công vào ChatRoom")
    public void sendTextMessage() {
        String requestBody = """
                    {
                        "chatRoomId": 2682,
                        "content": "gud morning",
                        "messageType": "TEXT"
                    }
                """;

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/api/chat/messages")
                .then()
                .log().all()
                .statusCode(200)
                .extract()
                .response();
    }
    @Test
    @DisplayName("Gửi tin nhắn với nội dung trống ")
    public void sendEmptyMessage() {
        String requestBody = """
        {
            "chatRoomId": 2682,
            "content": "",
            "messageType": "TEXT"
        }
    """;
        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/api/chat/messages")
                .then()
                .log().all()
                .statusCode(400)
                .extract()
                .response();

        List<String> errorMessages = response.jsonPath().getList("errors.message");
        System.out.println("Validation errors: " + errorMessages);
        assertTrue(errorMessages.contains("Message content is required"));
    }

    @Test
    @DisplayName("Gửi tin nhắn vào chat room không tồn tại ")
    public void sendMessageToNonExistentChatRoom() {
        String requestBody = """
        {
            "chatRoomId": 989899,
            "content": "hello",
            "messageType": "TEXT"
        }
    """;

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/api/chat/messages")
                .then()
                .log().all()
                .statusCode(404)
                .extract()
                .response();

        String message = response.jsonPath().getString("message");
        assertEquals("Chat room not found", message);
    }

    @Test
    @DisplayName("Gửi tin nhắn thiếu messageType ")
    public void sendMessage_MissingMessageType() {
        String requestBody = """
                    {
                        "chatRoomId": 2682,
                        "content": "test missing type"
                         "messageType": "IMAGE"
                    }
                """;

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/api/chat/messages")
                .then()
                .log().all()
                .statusCode(400)
                .extract()
                .response();

        String message = response.jsonPath().getString("message");
        assertEquals("Invalid request body format", message);
    }

}
