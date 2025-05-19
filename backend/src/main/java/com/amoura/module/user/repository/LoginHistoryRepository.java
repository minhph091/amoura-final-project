package com.amoura.module.user.repository;

import com.amoura.module.user.domain.LoginHistory;
import com.amoura.module.user.domain.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LoginHistoryRepository extends JpaRepository<LoginHistory, Long> {

    Page<LoginHistory> findByUserOrderByLoginTimeDesc(User user, Pageable pageable);
}