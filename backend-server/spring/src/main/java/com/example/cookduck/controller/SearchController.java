package com.example.cookduck.controller;

import com.example.cookduck.entity.Recipe;
import com.example.cookduck.repository.RecipeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/search")
@CrossOrigin(origins = "*")
public class SearchController {

    @Autowired
    private RecipeRepository recipeRepository;

    // 키워드로 레시피 검색
    @GetMapping("/recipes")
    public List<Recipe> searchRecipes(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        
        // 제목, 재료, 내용에서 키워드 검색
        return recipeRepository.findByTitleContainingOrIngredientsContainingOrContentContaining(
            keyword, pageable
        ).getContent();
    }

    // 재료로 레시피 검색
    @GetMapping("/recipes/by-ingredients")
    public List<Recipe> searchRecipesByIngredients(
            @RequestParam List<String> ingredients,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        
        // 재료 리스트로 검색
        return recipeRepository.findByIngredientsContaining(
            String.join(",", ingredients), pageable
        ).getContent();
    }

    // 제목으로 레시피 검색
    @GetMapping("/recipes/by-title")
    public List<Recipe> searchRecipesByTitle(
            @RequestParam String title,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        
        return recipeRepository.findByTitleContaining(title, pageable).getContent();
    }

    // 레시피 상세 정보
    @GetMapping("/recipes/{id}")
    public Optional<Recipe> getRecipeById(@PathVariable Long id) {
        return recipeRepository.findById(id);
    }

    // 인기 레시피 (ID 기준)
    @GetMapping("/recipes/popular")
    public List<Recipe> getPopularRecipes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        return recipeRepository.findByOrderByIdDesc(pageable).getContent();
    }

    // 최신 레시피 (ID 기준)
    @GetMapping("/recipes/recent")
    public List<Recipe> getRecentRecipes(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size) {
        
        Pageable pageable = PageRequest.of(page, size);
        return recipeRepository.findByOrderByIdAsc(pageable).getContent();
    }
}
