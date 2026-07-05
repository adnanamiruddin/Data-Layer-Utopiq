package com.adnan.springsqldemo.common;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.time.Duration;

@Component
public class ApiRequestLoggingFilter extends OncePerRequestFilter {

  private static final Logger log = LoggerFactory.getLogger(ApiRequestLoggingFilter.class);

  @Override
  protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
    long startTime = System.nanoTime();

    try {
      filterChain.doFilter(request, response);
    } finally {
      log.info("[HTTP REQUEST] method={} path={} query={} status={} elapsedMs={}", request.getMethod(), request.getRequestURI(), request.getQueryString(), response.getStatus(), elapsedMs(startTime));
    }
  }

  private long elapsedMs(long startTime) {
    return Duration.ofNanos(System.nanoTime() - startTime).toMillis();
  }
}
