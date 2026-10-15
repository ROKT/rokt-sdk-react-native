package com.rokt.reactnativesdk

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.UiThreadUtil
import org.junit.After
import org.junit.Assert.assertEquals
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
    fun `legacy positive tags never wait for mounting`() {
        var runs = 0
        impl.whenPlaceholdersMounted("page", mapOf("Location1" to 42.0)) { runs++ }
        assertEquals(0, delayed.size)
        assertEquals(0, runs)
        drain()
        assertEquals(1, runs)
    }

    @Test
    fun `names and legacy nulls wait while overlays do not`() {
        impl.whenPlaceholdersMounted("first", mapOf("Location1" to 0.0)) {}
        impl.whenPlaceholdersMounted("second", mapOf("Location2" to null)) {}
        assertEquals(2, delayed.size)
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
}
