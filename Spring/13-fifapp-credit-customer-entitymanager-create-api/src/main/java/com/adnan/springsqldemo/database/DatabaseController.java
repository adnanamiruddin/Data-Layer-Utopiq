package com.adnan.springsqldemo.database;

import com.adnan.springsqldemo.common.DatabaseCustomerRow;
import lombok.RequiredArgsConstructor;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/database")
@RequiredArgsConstructor
public class DatabaseController {
  private final JdbcTemplate jdbcTemplate;

  @GetMapping("/ping")
  public DatabaseStatus pingDatabase() {
    String databaseName = jdbcTemplate.queryForObject("SELECT current_database()", String.class);
    return new DatabaseStatus(
      true,
      databaseName,
      "PostgresSQL connection is OK"
    );
  }

  @GetMapping("/schema")
  public DatabaseSchemaStatus getDatabaseSchema() {
    List<String> tables = jdbcTemplate.queryForList(
      """
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'flyway_training'
        ORDER BY table_name
        """,
      String.class
    );
    return  new DatabaseSchemaStatus(
      "flyway_training",
      tables,
      "Flyway migration has prepared the database schema"
    );
  }

  @GetMapping("/customers")
  public List<DatabaseCustomerRow> getDatabaseCustomers() {
    return jdbcTemplate.query(
      """
        SELECT id, full_name, phone_number, email
        FROM customers
        ORDER BY id
        """,
      (rs, rowNum) -> new DatabaseCustomerRow(
        rs.getLong("id"),
        rs.getString("full_name"),
        rs.getString("phone_number"),
        rs.getString("email")
      )
    );
  }
}
