package com.adnan.springsqldemo.database;

public record DatabaseConnectionHoldResponse(
  String message,
  long durationMs,
  String connectionDescription,
  DatabasePoolStatus poolStatusWhileHeld
) {
}
