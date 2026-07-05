package com.adnan.springsqldemo.dao;

import com.adnan.springsqldemo.entity.Vehicle;
import org.springframework.data.jpa.repository.JpaRepository;

public interface VehicleRepository extends JpaRepository<Vehicle, Long> {
}
