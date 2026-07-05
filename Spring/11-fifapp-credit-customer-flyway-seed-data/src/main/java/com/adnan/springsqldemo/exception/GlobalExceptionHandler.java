package com.adnan.springsqldemo.exception;

import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;

import com.adnan.springsqldemo.dto.api.ApiResponse;
import com.adnan.springsqldemo.dto.api.FieldErrorResponse;

@ControllerAdvice
public class GlobalExceptionHandler {
  @ExceptionHandler(MethodArgumentNotValidException.class)
  public ResponseEntity<ApiResponse<Void>> errorValidation(MethodArgumentNotValidException exception) {
    List<FieldErrorResponse> errors = exception.getBindingResult()
      .getFieldErrors()
      .stream()
      .map(error -> new FieldErrorResponse(
        toSnakeCase(error.getField()),
        error.getDefaultMessage()))
      .toList();
    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
      .body(ApiResponse.error("VALIDATION_ERROR", "Invalid request", errors));
  }

  @ExceptionHandler(BadRequestException.class)
  public ResponseEntity<ApiResponse<Void>> badRequest(BadRequestException exception) {
    return ResponseEntity.status(HttpStatus.BAD_REQUEST)
      .body(ApiResponse.error("VALIDATION_ERROR",
        exception.getMessage() != null ? exception.getMessage()
          : "Invalid request",
        null));
  }

  @ExceptionHandler(NotFoundException.class)
  public ResponseEntity<ApiResponse<Void>> notFound(NotFoundException exception) {
    return ResponseEntity.status(HttpStatus.NOT_FOUND)
      .body(ApiResponse.error("NOT_FOUND",
        exception.getMessage() != null ? exception.getMessage()
          : "Resource not found",
        null));
  }

  @ExceptionHandler(ForbiddenException.class)
  public ResponseEntity<ApiResponse<Void>> forbidden(ForbiddenException exception) {
    return ResponseEntity.status(HttpStatus.FORBIDDEN)
      .body(ApiResponse.error("FORBIDDEN",
        exception.getMessage() != null ? exception.getMessage()
          : "Access denied",
        null));
  }

  @ExceptionHandler(UnauthorizedException.class)
  public ResponseEntity<ApiResponse<Void>> unauthorized(UnauthorizedException exception) {
    return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
      .body(ApiResponse.error("UNAUTHORIZED",
        exception.getMessage() != null ? exception.getMessage()
          : "Authentication is required",
        null));
  }

  @ExceptionHandler(Exception.class)
  public ResponseEntity<ApiResponse<Void>> internalServerError(Exception exception) {
    return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
      .body(ApiResponse.error("INTERNAL_SERVER_ERROR", "Unexpected error occurred", null));
  }

  public static String toSnakeCase(String value) {
    return value
      .replaceAll("([a-z])([A-Z])", "$1_$2")
      .toLowerCase();
  }
}