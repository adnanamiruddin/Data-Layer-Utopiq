package com.adnan.springsqldemo.service;

import com.adnan.springsqldemo.dto.CreateCreditApplicationRequest;
import com.adnan.springsqldemo.dto.CreditApplicationResponse;

import java.util.List;

public interface CreditApplicationService {
  CreditApplicationResponse createCreditApplication(CreateCreditApplicationRequest request);

  CreditApplicationResponse getCreditApplicationById(Long id);
}
