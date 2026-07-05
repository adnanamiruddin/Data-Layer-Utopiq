package com.adnan.springsqldemo.service;

import com.adnan.springsqldemo.dto.CreateCreditApplicationRequest;
import com.adnan.springsqldemo.dto.CreditApplicationResponse;
import com.adnan.springsqldemo.dto.CreditApplicationSummaryResponse;

import java.util.List;

public interface CreditApplicationService {
  CreditApplicationResponse createCreditApplication(CreateCreditApplicationRequest request);

  List<CreditApplicationResponse> getAllCreditApplications(String status);

  CreditApplicationResponse getCreditApplicationById(Long id);

  CreditApplicationSummaryResponse getCreditApplicationSummary(Long id);
}
