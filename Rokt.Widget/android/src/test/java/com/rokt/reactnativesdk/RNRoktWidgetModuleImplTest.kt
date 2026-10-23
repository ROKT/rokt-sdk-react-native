package com.rokt.reactnativesdk

import com.facebook.react.bridge.JavaOnlyArray
import com.facebook.react.bridge.JavaOnlyMap
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.UiThreadUtil
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test
import org.mockito.ArgumentMatchers.any
import org.mockito.Mockito.mock
import org.mockito.Mockito.mockStatic

class RNRoktWidgetModuleImplTest {
    private val posted = mutableListOf<Runnable>()
    private val delayed = mutableListOf<Runnable>()
    private lateinit var original: RoktPlaceholderRegistry.Scheduler
    private lateinit var impl: RNRoktWidgetModuleImpl

    @Before
    fun setUp() {
        original = RoktPlaceholderRegistry.scheduler
        RoktPlaceholderRegistry.scheduler = object : RoktPlaceholderRegistry.Scheduler {
            override fun post(runnable: Runnable) {
                posted.add(runnable)
            }
            override fun postDelayed(runnable: Runnable, delayMillis: Long) {
                assertEquals(2000L, delayMillis)
                delayed.add(runnable)
            }
            override fun cancel(runnable: Runnable) {
                delayed.remove(runnable)
            }
        }
        impl = RNRoktWidgetModuleImpl(mock(ReactApplicationContext::class.java))
    }

    @After
    fun tearDown() {
        RoktPlaceholderRegistry.cancelWaits()
        RoktPlaceholderRegistry.scheduler = original
    }

    private fun drain() {
        val tasks = posted.toList()
        posted.clear()
        tasks.forEach { it.run() }
    }

    @Test
    fun `every placeholder waits for its view by name, whatever its value`() {
        impl.whenPlaceholdersMounted("first", mapOf("Location1" to 0.0)) {}
        impl.whenPlaceholdersMounted("second", mapOf("Location2" to null)) {}
        impl.whenPlaceholdersMounted("third", mapOf("Location3" to 42.0)) {}
        assertEquals(3, delayed.size)
        var runs = 0
        impl.whenPlaceholdersMounted("overlay", emptyMap()) { runs++ }
        drain()
        assertEquals(1, runs)
    }

    @Test
    fun `an overlay replaces a pending embedded call for the same identifier`() {
        var old = 0
        var next = 0
        impl.whenPlaceholdersMounted("page", mapOf("Location1" to 0.0)) { old++ }
        impl.whenPlaceholdersMounted("page", emptyMap()) { next++ }
        drain()
        assertEquals(0, old)
        assertEquals(1, next)
        assertEquals(0, delayed.size)
    }

    @Test
    fun `invalidation cancels queued selection and rejects later calls`() {
        mockStatic(UiThreadUtil::class.java).use { uiThread ->
            uiThread.`when`<Boolean> { UiThreadUtil.runOnUiThread(any(Runnable::class.java) ?: Runnable {}) }.thenAnswer {
                (it.arguments[0] as Runnable).run()
                true
            }
            var runs = 0
            impl.whenPlaceholdersMounted("page", emptyMap()) { runs++ }
            impl.invalidate()
            impl.whenPlaceholdersMounted("later", emptyMap()) { runs++ }
            drain()
            assertEquals(0, runs)
        }
    }

    @Test
    fun `cache config keeps only string attributes`() {
        val attributes =
            JavaOnlyMap.of(
                "email", "a@example.com",
                "missing", null,
                "count", 3.0,
                "flag", true,
                "nested", JavaOnlyMap.of("key", "value"),
                "list", JavaOnlyArray.of("value"),
            )
        val config = impl.buildCacheConfig(JavaOnlyMap.of("cacheDurationInSeconds", 60.0, "cacheAttributes", attributes))
        assertEquals(60L, config.cacheDurationInSeconds)
        assertEquals(mapOf("email" to "a@example.com"), config.cacheAttributes)
    }

    @Test
    fun `wrongly typed cache config values are skipped`() {
        val config = impl.buildCacheConfig(JavaOnlyMap.of("cacheDurationInSeconds", null, "cacheAttributes", "a@example.com"))
        assertEquals(0L, config.cacheDurationInSeconds)
        assertNull(config.cacheAttributes)
    }

    @Test
    fun `a cacheConfig that is not an object is skipped`() {
        val config = impl.buildRoktConfig(JavaOnlyMap.of("cacheConfig", "60", "colorMode", 1.0))
        assertNull(config.cacheConfig)
        assertNull(config.colorMode)
    }
}
