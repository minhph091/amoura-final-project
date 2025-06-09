package com.amoura.infrastructure.mail;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.Context;

import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmailService {

    private final JavaMailSender mailSender;
    private final TemplateEngine templateEngine;

    @Value("${spring.mail.username}")
    private String fromEmail;

    @Async
    public void sendEmail(String to, String subject, String template, Map<String, Object> variables) {
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");

            Context context = new Context();
            context.setVariables(variables);
            String htmlContent = templateEngine.process(template, context);

            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(htmlContent, true);

            mailSender.send(message);
            log.info("Email sent to: {}", to);
        } catch (MessagingException e) {
            log.error("Failed to send email to: {}", to, e);
        }
    }

    @Async
    public void sendOtpEmail(String to, String otp, String purpose) {
        String subject;
        String template;

        switch (purpose) {
            case "REGISTRATION":
                subject = "Verify your account on Amoura";
                template = "otp-registration";
                break;
            case "PASSWORD_RESET":
                subject = "Reset your password on Amoura";
                template = "otp-password-reset";
                break;
            case "LOGIN":
                subject = "Login verification for Amoura";
                template = "otp-login";
                break;
            default:
                subject = "Verification code for Amoura";
                template = "otp-general";
        }

        Map<String, Object> variables = Map.of(
                "otp", otp,
                "expiresInMinutes", 5,
                "purpose", purpose
        );

        sendEmail(to, subject, template, variables);
    }

    @Async
    public void sendEmailChangeOtpEmail(String to, String otp, int expiresInMinutes) {
        Map<String, Object> variables = Map.of(
                "otp", otp,
                "expiresInMinutes", expiresInMinutes
        );

        sendEmail(to, "Change Your Email Address", "email-change-otp", variables);
    }
}