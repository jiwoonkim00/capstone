package com.example.cookduck.repository;

import com.example.cookduck.entity.Recipe;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface RecipeRepository extends JpaRepository<Recipe, Long> {
    
    // 제목, 재료, 내용에서 키워드 검색
    @Query("SELECT r FROM Recipe r WHERE " +
           "LOWER(r.title) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(r.ingredients) LIKE LOWER(CONCAT('%', :keyword, '%')) OR " +
           "LOWER(r.content) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    Page<Recipe> findByTitleContainingOrIngredientsContainingOrContentContaining(
        @Param("keyword") String keyword,
        Pageable pageable
    );
    
    // 재료로 검색
    @Query("SELECT r FROM Recipe r WHERE " +
           "LOWER(r.ingredients) LIKE LOWER(CONCAT('%', :ingredients, '%'))")
    Page<Recipe> findByIngredientsContaining(@Param("ingredients") String ingredients, Pageable pageable);
    
    // 제목으로 검색
    @Query("SELECT r FROM Recipe r WHERE LOWER(r.title) LIKE LOWER(CONCAT('%', :title, '%'))")
    Page<Recipe> findByTitleContaining(@Param("title") String title, Pageable pageable);
    
    // 인기 레시피 (ID 기준 정렬)
    @Query("SELECT r FROM Recipe r ORDER BY r.id DESC")
    Page<Recipe> findByOrderByIdDesc(Pageable pageable);
    
    // 최신 레시피 (ID 기준 정렬)
    @Query("SELECT r FROM Recipe r ORDER BY r.id ASC")
    Page<Recipe> findByOrderByIdAsc(Pageable pageable);
    
    // 제목으로 정확히 검색
    List<Recipe> findByTitleContainingIgnoreCase(String title);
    
    // 재료로 정확히 검색
    List<Recipe> findByIngredientsContainingIgnoreCase(String ingredients);
}
