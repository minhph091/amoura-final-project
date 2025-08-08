package com.amoura.module.chat.api;

import com.amoura.common.LoginAndGetToken;
import io.restassured.RestAssured;
import io.restassured.http.ContentType;
import io.restassured.response.Response;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import com.amoura.common.LoginAndGetToken;


import java.util.List;

import static org.hamcrest.MatcherAssert.assertThat;
import static org.junit.jupiter.api.Assertions.*;

public class ChatControllerTests {

    static String jwtToken;

    @BeforeAll
    static void setup() {
        RestAssured.baseURI = "http://localhost/api";
        RestAssured.port = 8080;
        jwtToken = LoginAndGetToken.execute();
    }

    @Test
    @DisplayName("Lấy danh sách chat room với token hợp lệ")
    public void getChatRooms_WithValidToken_ShouldReturnChatRooms() {
        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .when()
                .get("/chat/rooms")
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
                .get("/chat/rooms/524")
                .then()
                .log().all()
                .statusCode(200)
                .extract()
                .response();
    }

    @Test
    @DisplayName("Lấy chat room theo ID không tồn tại")
    public void getChatRoomById_WithNonExistentChatRoomId() {
        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .when()
                .get("/chat/rooms/27050")
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
        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .when()
                .get("/chat/rooms/9999")
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
                        "chatRoomId": 524,
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
                .post("/chat/messages")
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
                .post("/chat/messages")
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
                .post("/chat/messages")
                .then()
                .log().all()
                .statusCode(404)
                .extract()
                .response();

        String message = response.jsonPath().getString("message");
        assertEquals("Chat room not found", message);
    }

    @Test
    @DisplayName("Gửi tin nhắn thiếu messageType")
    public void sendMessage_MissingMessageType() {
        String requestBody = """
        {
            "chatRoomId": 524,
            "content": "test missing type",
             "messageType": "string"
                
        }
    """;

        Response response = RestAssured
                .given()
                .header("Authorization", "Bearer " + jwtToken)
                .contentType(ContentType.JSON)
                .body(requestBody)
                .when()
                .post("/chat/messages")
                .then()
                .log().all()
                .statusCode(400)
                .extract()
                .response();

        String message = response.jsonPath().getString("message");
        System.out.println("Message returned: " + message);
        assertEquals("Invalid request body format", message);
    }

}
