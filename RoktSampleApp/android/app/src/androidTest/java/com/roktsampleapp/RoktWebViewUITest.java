/*
 *  Copyright 2020 Rokt Pte Ltd Licensed under the Rokt Software Development Kit (SDK)
 *  Terms of Use Version 2.0 (the "License");
 *
 *  You may not use this file except in compliance with the License.
 *
 *  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
 */

package com.roktsampleapp;


import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.action.ViewActions.replaceText;
import static androidx.test.espresso.action.ViewActions.scrollTo;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withContentDescription;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import static org.hamcrest.Matchers.allOf;
import static java.lang.Thread.sleep;
import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.internal.runner.junit4.AndroidJUnit4ClassRunner;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4ClassRunner.class)
public class RoktWebViewUITest {

    @Rule
    public ActivityScenarioRule rule = new ActivityScenarioRule<>(MainActivity.class);

    @Test
    public void checkEmbeddedPlacementsLoadCorrectly() throws Throwable {
        TestUtils.waitUntilDisplayed("Welcome to Rokt Demo ");
        sleep(2000);
        onView(withText("Welcome to Rokt Demo ")).check(matches(isDisplayed()));

        // Setup
        onView(allOf(withContentDescription("input_tag_id"), isDisplayed())).perform(replaceText("2754655826098840951"));
        onView(allOf(withContentDescription("input_view_name"), isDisplayed())).perform(replaceText("crossPlatformEmbedded"));
        onView(allOf(withContentDescription("input_view_country"), isDisplayed())).perform(replaceText("AU"));
        onView(allOf(withContentDescription("input_target_element"), isDisplayed())).perform(replaceText("RoktEmbedded1"));
        onView(allOf(withContentDescription("input_attributes"), isDisplayed())).perform(replaceText(RAW_ATTRIBUTES));

        onView(withText("Initialize")).perform(scrollTo(), click());
        sleep(2000);
        onView(withText("Execute")).perform(scrollTo(), click());
        sleep(6000);

        onView(withText("This is a test creative. hello world"))
                .perform(scrollTo())
                .check(matches(isDisplayed()));
        onView(withText("Powered by Rokt - Privacy Policy"))
                .perform(scrollTo())
                .check(matches(isDisplayed()));
    }

    @Test
    public void checkOverlayPlacementsLoadCorrectly() throws Throwable {
        TestUtils.waitUntilDisplayed("Welcome to Rokt Demo ");
        sleep(2000);
        onView(withText("Welcome to Rokt Demo ")).check(matches(isDisplayed()));

        // Setup
        onView(allOf(withContentDescription("input_tag_id"), isDisplayed())).perform(replaceText("2754655826098840951"));
        onView(allOf(withContentDescription("input_view_name"), isDisplayed())).perform(replaceText("crossPlatformOverlay"));
        onView(allOf(withContentDescription("input_view_country"), isDisplayed())).perform(replaceText("AU"));
        onView(allOf(withContentDescription("input_attributes"), isDisplayed())).perform(replaceText(RAW_ATTRIBUTES));

        onView(withText("Initialize")).perform(scrollTo(), click());
        sleep(2000);
        onView(withText("Execute")).perform(scrollTo(), click());
        sleep(6000);

        onView(withText("This is a test creative. hello world"))
                .check(matches(isDisplayed()));
        onView(withText("Rokt Privacy Policy"))
                .check(matches(isDisplayed()));
        onView(withText("Partner privacy"))
                .check(matches(isDisplayed()));
    }

    private static final String RAW_ATTRIBUTES  = "{\n" +
            "    \"emai\": \"j.smith@example.com\",\n" +
            "    \"firstname\": \"Jenny\",\n" +
            "    \"lastname\": \"Smith\",\n" +
            "    \"age\": \"101\",\n" +
            "    \"mobile\": \"(323) 867-5309\",\n" +
            "    \"zipcode\": \"7176\",\n" +
            "    \"sandbox\": \"true\",\n" +
            "    \"rokt.mobile.e2etest\": \"true\"\n" +
            "  }";
}


