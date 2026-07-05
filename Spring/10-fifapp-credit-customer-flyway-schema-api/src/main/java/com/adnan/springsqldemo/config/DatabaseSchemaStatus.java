package com.adnan.springsqldemo.config;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.util.List;

@AllArgsConstructor
@Getter
public class DatabaseSchemaStatus {
  private String schemaName;
  private List<String> tables;
  private String message;
}
