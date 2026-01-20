// DISABLED - Using static HTML files instead
/*
package com.example.springbootsecuritythymeleaf.web;

import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@RequiredArgsConstructor
public class WebController {

    @GetMapping("/")
    public String home(@AuthenticationPrincipal UserDetails user, Model model) {
        model.addAttribute("username", user != null ? user.getUsername() : "Guest");
        return "index";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }
}
*/
