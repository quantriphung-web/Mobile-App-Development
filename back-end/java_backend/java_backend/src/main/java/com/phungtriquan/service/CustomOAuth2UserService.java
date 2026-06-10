package com.phungtriquan.service;

import com.phungtriquan.config.OAuth2AuthenticationProcessingException;
import com.phungtriquan.model.AuthProvider;
import com.phungtriquan.model.StaffAccount;
import com.phungtriquan.repository.StaffAccountRepository;
import com.phungtriquan.security.oauth2.OAuth2UserInfo;
import com.phungtriquan.security.oauth2.OAuth2UserInfoFactory;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.InternalAuthenticationServiceException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.oauth2.client.userinfo.*;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.DefaultOAuth2User;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.*;

@Service
@RequiredArgsConstructor
public class CustomOAuth2UserService extends DefaultOAuth2UserService {

    private final StaffAccountRepository staffAccountRepository;

    @Override
    public OAuth2User loadUser(OAuth2UserRequest oAuth2UserRequest) throws OAuth2AuthenticationException {
        OAuth2User oAuth2User = super.loadUser(oAuth2UserRequest);
        try {
            return processOAuth2User(oAuth2UserRequest, oAuth2User);
        } catch (AuthenticationException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new InternalAuthenticationServiceException(ex.getMessage(), ex);
        }
    }

    private OAuth2User processOAuth2User(OAuth2UserRequest request, OAuth2User oAuth2User) {
        String registrationId = request.getClientRegistration().getRegistrationId();
        OAuth2UserInfo userInfo = OAuth2UserInfoFactory.getOAuth2UserInfo(
                registrationId, oAuth2User.getAttributes());

        if (!StringUtils.hasText(userInfo.getEmail())) {
            throw new OAuth2AuthenticationProcessingException(
                    "Email not found from OAuth2 provider");
        }

        Optional<StaffAccount> userOptional = staffAccountRepository.findByEmail(userInfo.getEmail());
        StaffAccount user;
        if (userOptional.isPresent()) {
            user = userOptional.get();
            if (!user.getProvider().toString().equalsIgnoreCase(registrationId)) {
                throw new OAuth2AuthenticationProcessingException(
                        "You signed up with " + user.getProvider() +
                        " account. Please use that to login.");
            }
            user = updateExistingUser(user, userInfo);
        } else {
            user = registerNewUser(request, userInfo);
        }

        Map<String, Object> attrs = new HashMap<>(oAuth2User.getAttributes());
        attrs.put("userId", user.getId());
        attrs.put("userEmail", user.getEmail());

        String userNameAttr = request.getClientRegistration()
                .getProviderDetails().getUserInfoEndpoint().getUserNameAttributeName();

        return new DefaultOAuth2User(Collections.emptyList(), attrs, userNameAttr);
    }

    private StaffAccount registerNewUser(OAuth2UserRequest request, OAuth2UserInfo userInfo) {
        AuthProvider provider = AuthProvider.valueOf(
                request.getClientRegistration().getRegistrationId().toUpperCase());
        
        String fullName = userInfo.getName();
        String firstName = "OAuth";
        String lastName = "User";
        if (fullName != null && !fullName.trim().isEmpty()) {
            String[] parts = fullName.trim().split("\\s+", 2);
            if (parts.length > 1) {
                firstName = parts[0];
                lastName = parts[1];
            } else {
                firstName = parts[0];
                lastName = "Account";
            }
        }

        StaffAccount user = StaffAccount.builder()
                .firstName(firstName)
                .lastName(lastName)
                .email(userInfo.getEmail())
                .image(userInfo.getImageUrl())
                .passwordHash("OAUTH_ACCOUNT_NO_PASSWORD")
                .provider(provider)
                .providerId(userInfo.getId())
                .emailVerified(true)
                .active(true)
                .build();

        Optional<StaffAccount> firstAccount = staffAccountRepository.findFirstByOrderByCreatedAtAsc();
        if (firstAccount.isPresent()) {
            user.setCreatedBy(firstAccount.get());
            user.setUpdatedBy(firstAccount.get());
            return staffAccountRepository.save(user);
        } else {
            user = staffAccountRepository.save(user);
            user.setCreatedBy(user);
            user.setUpdatedBy(user);
            return staffAccountRepository.save(user);
        }
    }

    private StaffAccount updateExistingUser(StaffAccount user, OAuth2UserInfo userInfo) {
        String fullName = userInfo.getName();
        if (fullName != null && !fullName.trim().isEmpty()) {
            String[] parts = fullName.trim().split("\\s+", 2);
            if (parts.length > 1) {
                user.setFirstName(parts[0]);
                user.setLastName(parts[1]);
            } else {
                user.setFirstName(parts[0]);
            }
        }
        user.setImage(userInfo.getImageUrl());
        return staffAccountRepository.save(user);
    }
}
