package com.adnan.springsqldemo.dto.api;

import java.util.Collections;
import java.util.List;

import org.slf4j.MDC;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ApiResponse<T> {
  private boolean success;
  private String code;
  private String message;
  private T data;
  private List<FieldErrorResponse> errors;

  public static <T> ApiResponse<T> success(String message, T data) {
    return ApiResponse.<T>builder()
        .success(true)
        .message(message)
        .data(data)
        .errors(Collections.emptyList())
        .build();
  }

  public static <T> ApiResponse<T> error(String code, String message, List<FieldErrorResponse> errors) {
    return ApiResponse.<T>builder()
        .success(false)
        .code(code)
        .message(message)
        .errors(errors == null ? Collections.emptyList() : errors)
        .build();
  }
}