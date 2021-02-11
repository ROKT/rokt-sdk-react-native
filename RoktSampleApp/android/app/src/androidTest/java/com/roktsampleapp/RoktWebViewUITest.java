/*
 *  Copyright 2020 Rokt Pte Ltd Licensed under the Rokt Software Development Kit (SDK)
 *  Terms of Use Version 2.0 (the "License");
 *
 *  You may not use this file except in compliance with the License.
 *
 *  You may obtain a copy of the License at https://rokt.com/sdk-license-2-0/
 */

package com.roktsampleapp;


import androidx.test.ext.junit.rules.ActivityScenarioRule;
import androidx.test.internal.runner.junit4.AndroidJUnit4ClassRunner;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.action.ViewActions.replaceText;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withContentDescription;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import static java.lang.Thread.sleep;
import static org.hamcrest.Matchers.allOf;
import static org.hamcrest.Matchers.anyOf;

@RunWith(AndroidJUnit4ClassRunner.class)
public class RoktWebViewUITest {

    @Rule
    public ActivityScenarioRule rule = new ActivityScenarioRule<>(MainActivity.class);

    @Test
    public void checkPlacementsLoadCorrectly() throws Throwable {
        TestUtils.waitUntilDisplayed("Welcome to Rokt Demo ");
        onView(anyOf(withText("Welcome to Rokt Demo "))).check(matches(isDisplayed()));

        // Setup
        onView(allOf(withContentDescription("input_tag_id"), isDisplayed())).perform(replaceText("2731619347947643042"));
        onView(allOf(withContentDescription("input_view_name"), isDisplayed())).perform(replaceText("androidMultipleQA"));
        onView(allOf(withContentDescription("input_stage_env"), isDisplayed())).perform(click());

        onView(anyOf(withText("Initialize"))).perform(click());
        sleep(1000);
        onView(anyOf(withText("Execute"))).perform(click());
        sleep(6000);

        // Check for lightbox placement
        TestUtils.waitUntilPartiallyDisplayed("This is a test widget");
        onView(allOf(withText("No thanks"), isDisplayed())).perform(click());
        onView(allOf(withText("No thanks"), isDisplayed())).perform(click());

        //Check for Embedded placement
        TestUtils.waitUntilPartiallyDisplayed("This is a test widget for automated");
    }
}


