package com.adnan.springsqldemo.rest;

import com.adnan.springsqldemo.dto.CreditApplicationResponse;
import com.adnan.springsqldemo.service.CreditApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/demo")
@RequiredArgsConstructor
public class NPlusOneDemoController {
  private final CreditApplicationService creditApplicationService;

  @GetMapping("/n-plus-one/credit-applications")
  public List<CreditApplicationResponse> getAllCreditApplicationsForNPlusOneDemo() {
    return creditApplicationService.getAllCreditApplications(null);
  }
}
