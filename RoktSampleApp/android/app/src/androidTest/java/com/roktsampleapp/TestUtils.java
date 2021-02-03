package com.roktsampleapp;

import androidx.test.espresso.ViewAssertion;
import androidx.test.espresso.ViewInteraction;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isCompletelyDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withText;
import static java.lang.Thread.sleep;
import static org.hamcrest.Matchers.containsString;


public class TestUtils {
    private static final Long WAIT_TIME_TOTAL = 50000L;
    private static final Long WAIT_TIME_TICK = 300L;

    public static void waitUntilDisplayed(String text) throws Throwable {
        waitUntilCondition(onView(withText(text)), matches(isCompletelyDisplayed()));
    }

    public static void waitUntilPartiallyDisplayed(String text) throws Throwable {
        waitUntilCondition(onView(withText(containsString(text))), matches(isDisplayed()));
    }

    public static void waitUntilCondition(ViewInteraction viewInteraction, ViewAssertion viewAssertion) throws Throwable {
        Long startTime = System.currentTimeMillis();

        while (true) {
            try {
                final Throwable[] errorThrowable = new Throwable[1];
                viewInteraction.check(viewAssertion).withFailureHandler((error, viewMatcher) -> {
                    errorThrowable[0] = error;
                });

                if (errorThrowable[0] == null) {
                    return;
                } else if (hasMaximumTimeExceeded(startTime)) {
                    throw errorThrowable[0];
                }
            } catch (Exception e) {
                if (hasMaximumTimeExceeded(startTime)) {
                    throw e;
                }
            }

            sleep(WAIT_TIME_TICK);
        }
    }

    public static Boolean hasMaximumTimeExceeded(Long startTime) {
        return System.currentTimeMillis() - startTime > WAIT_TIME_TOTAL;
    }
}
