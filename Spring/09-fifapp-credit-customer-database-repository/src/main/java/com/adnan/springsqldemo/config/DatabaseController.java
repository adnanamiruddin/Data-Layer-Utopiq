package com.adnan.springsqldemo.config;

import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class DatabaseController {
  private final JdbcTemplate jdbcTemplate;

  @GetMapping("/api/database/ping")
  public DatabaseStatus pingDatabase() {
    String databaseName = jdbcTemplate.queryForObject("SELECT current_database()", String.class);
    return new DatabaseStatus(
      true,
      databaseName,
      "PostgresSQL connection is OK"
    );
  }
}
