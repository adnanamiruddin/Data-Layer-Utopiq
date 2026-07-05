package com.adnan.springsqldemo.rest;

import com.adnan.springsqldemo.common.NotFoundException;
import com.adnan.springsqldemo.dto.CreateCreditApplicationRequest;
import com.adnan.springsqldemo.dto.CreditApplicationResponse;
import com.adnan.springsqldemo.service.CreditApplicationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/credit-applications")
@RequiredArgsConstructor
public class CreditApplicationRestController {
  private final CreditApplicationService creditApplicationService;

  @PostMapping
  @ResponseStatus(HttpStatus.CREATED)
  public CreditApplicationResponse createCreditApplication(@RequestBody CreateCreditApplicationRequest request) {
    return creditApplicationService.createCreditApplication(request);
  }

  @GetMapping
  public List<CreditApplicationResponse> getAllCreditApplication() {
    return creditApplicationService.getAllCreditApplications();
  }

  @GetMapping("/{creditApplicationId}")
  public CreditApplicationResponse getCreditApplicationById(@PathVariable Long creditApplicationId) {
    CreditApplicationResponse creditApplication = creditApplicationService.getCreditApplicationById(
      creditApplicationId
    );
    if (creditApplication == null) {
      throw new NotFoundException(String.format("Credit Application not found with id: %s", creditApplicationId));
    }
    return creditApplication;
  }
}

