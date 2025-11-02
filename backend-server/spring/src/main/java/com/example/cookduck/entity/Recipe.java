package com.example.cookduck.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "recipe")
public class Recipe {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(name = "title", columnDefinition = "TEXT")
    private String title;
    
    @Column(name = "ingredients", columnDefinition = "TEXT")
    private String ingredients;
    
    @Column(name = "tools", columnDefinition = "TEXT")
    private String tools;
    
    @Column(name = "content", columnDefinition = "TEXT")
    private String content;
    
    // 기본 생성자
    public Recipe() {}
    
    // 생성자
    public Recipe(String title, String ingredients, String content) {
        this.title = title;
        this.ingredients = ingredients;
        this.content = content;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getIngredients() {
        return ingredients;
    }
    
    public void setIngredients(String ingredients) {
        this.ingredients = ingredients;
    }
    
    public String getContent() {
        return content;
    }
    
    public void setContent(String content) {
        this.content = content;
    }
    
    public String getTools() {
        return tools;
    }
    
    public void setTools(String tools) {
        this.tools = tools;
    }
}
