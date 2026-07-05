package com.adnan.springsqldemo.database;

public record DatabasePoolStatus(
  String poolName,
  int totalConnections,
  int activeConnections,
  int idleConnections,
  int threadsAwaitingConnection,
  int maximumPoolSize,
  int minimumIdle,
  long connectionTimeoutMs,
  String status
) {
}
