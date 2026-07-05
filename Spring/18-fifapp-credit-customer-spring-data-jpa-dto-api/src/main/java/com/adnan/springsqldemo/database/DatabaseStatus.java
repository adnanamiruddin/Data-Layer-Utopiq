package com.adnan.springsqldemo.database;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
public class DatabaseStatus {
  private boolean connected;
  @Getter
  private String databaseName;
  @Getter
  private String message;

  private boolean isConnected() {
    return connected;
  }
}
