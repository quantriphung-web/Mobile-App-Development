package com.phungtriquan.security.oauth2;

import java.util.Map;

public class FacebookOAuth2UserInfo extends OAuth2UserInfo {

    public FacebookOAuth2UserInfo(Map<String, Object> attributes) {
        super(attributes);
    }

    @Override public String getId()    { return (String) attributes.get("id"); }
    @Override public String getName()  { return (String) attributes.get("name"); }
    @Override public String getEmail() { return (String) attributes.get("email"); }

    @Override
    public String getImageUrl() {
        if (attributes.containsKey("picture")) {
            @SuppressWarnings("unchecked")
            Map<String, Object> pictureObj = (Map<String, Object>) attributes.get("picture");
            if (pictureObj != null && pictureObj.containsKey("data")) {
                @SuppressWarnings("unchecked")
                Map<String, Object> pictureData = (Map<String, Object>) pictureObj.get("data");
                if (pictureData != null) return (String) pictureData.get("url");
            }
        }
        return null;
    }
}
