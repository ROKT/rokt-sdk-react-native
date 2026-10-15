test.each([
  [true, false, "turbo"],
  [true, true, "turbo"],
  [false, true, "legacy"],
  [false, false, null],
])("resolves emitter: turbo=%p legacy=%p", (turbo, legacy, expected) => {
  jest.resetModules();
  jest.doMock("react-native", () => ({
    NativeModules: { RoktEventManager: legacy ? "legacy" : undefined },
    TurboModuleRegistry: { get: () => (turbo ? "turbo" : null) },
  }));
  expect(require("../src/rokt-event-manager").RoktEventManager).toBe(expected);
});
