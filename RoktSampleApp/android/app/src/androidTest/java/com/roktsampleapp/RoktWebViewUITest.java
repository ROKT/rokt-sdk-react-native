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
import static androidx.test.espresso.matcher.ViewMatchers.withId;
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
    public void checkPlacementsLoadCorrectly() throws Throwable {
        TestUtils.waitUntilDisplayed("Welcome to Rokt Demo ");
        sleep(2000);
        onView(withText("Welcome to Rokt Demo ")).check(matches(isDisplayed()));

        // Setup
        onView(allOf(withContentDescription("input_tag_id"), isDisplayed())).perform(replaceText("2754655826098840951"));
        onView(allOf(withContentDescription("input_view_name"), isDisplayed())).perform(replaceText("testTwoEmbedded"));

        onView(withText("Initialize")).perform(scrollTo(), click());
        sleep(2000);
        onView(withText("Execute")).perform(scrollTo(), click());
        sleep(6000);

        //onView(TestUtils.withIndex(withId(R.id.parentLayout), 0)).perform(scrollTo());
        onView(TestUtils.withIndex(withId(R.id.parentLayout), 0)).check(matches(TestUtils.withMinHeight(100)));
        onView(TestUtils.withIndex(withId(R.id.parentLayout), 1)).check(matches(TestUtils.withMinHeight(100)));
    }
}


