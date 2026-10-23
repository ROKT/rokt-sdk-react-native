const native = {
  selectPlacements: jest.fn(),
  selectPlacementsWithConfig: jest.fn(),
  selectShoppableAds: jest.fn(),
  selectShoppableAdsWithConfig: jest.fn(),
};
jest.mock("react-native", () => ({
  NativeModules: { RNRoktWidget: native },
  UIManager: {},
  TurboModuleRegistry: { getEnforcing: () => native },
}));
import { Rokt } from "../src/Rokt";

beforeEach(() => jest.clearAllMocks());

test("name arrays become zero sentinels, without requiring refs", () => {
  Rokt.selectPlacements("embedded", {}, ["Location1", "Location2"]);
  expect(native.selectPlacements).toHaveBeenCalledWith(
    "embedded",
    {},
    { Location1: 0, Location2: 0 },
  );
});
test("the removed map of names to tags logs an error and selects without embedded views", () => {
  const error = jest.spyOn(console, "error").mockImplementation(() => {});
  const placeholders = { Location1: 42, Location2: null };
  // JavaScript callers can still pass the removed form.
  Rokt.selectPlacements("embedded", {}, placeholders as never);
  expect(native.selectPlacements).toHaveBeenCalledWith("embedded", {}, {});
  expect(error).toHaveBeenCalledWith(
    expect.stringContaining("must be an array of placeholder names"),
  );
  expect(placeholders).toEqual({ Location1: 42, Location2: null });
  error.mockRestore();
});
test("entries that are not names are skipped", () => {
  Rokt.selectPlacements("embedded", {}, ["Location1", 42, null] as never);
  expect(native.selectPlacements).toHaveBeenCalledWith(
    "embedded",
    {},
    { Location1: 0 },
  );
});
test("an empty object, the earlier overlay-only form, selects without an error", () => {
  const error = jest.spyOn(console, "error").mockImplementation(() => {});
  Rokt.selectPlacements("overlay", {}, {} as never);
  expect(native.selectPlacements).toHaveBeenCalledWith("overlay", {}, {});
  expect(error).not.toHaveBeenCalled();
  error.mockRestore();
});
test.each([undefined, []])(
  "overlay-only calls send an empty dictionary (%p)",
  (placeholders) => {
    expect(Rokt.selectPlacements("overlay", {}, placeholders)).toBeUndefined();
    expect(native.selectPlacements).toHaveBeenCalledWith("overlay", {}, {});
  },
);
test("placeholder names cannot modify the output prototype", () => {
  Rokt.selectPlacements("embedded", {}, ["__proto__"]);
  const result = native.selectPlacements.mock.calls[0][2];
  expect(Object.prototype.hasOwnProperty.call(result, "__proto__")).toBe(true);
  expect(result.__proto__).toBe(0);
  expect(Object.getPrototypeOf(result)).toBe(Object.prototype);
});
test.each([false, true])(
  "primitive attributes survive both selection routes (config=%p)",
  (configured) => {
    const attrs = {
      email: "test@example.com",
      amount: 23.47,
      zero: 0,
      enabled: false,
      yes: true,
      nothing: null,
      missing: undefined,
      object: {},
      array: [],
    };
    const expected = {
      email: "test@example.com",
      amount: "23.47",
      zero: "0",
      enabled: "false",
      yes: "true",
    };
    const config = configured ? { colorMode: "dark" as const } : undefined;
    // JS integrations may supply values outside the public TypeScript contract.
    Rokt.selectPlacements("embedded", attrs as never, ["Location1"], config);
    Rokt.selectShoppableAds("shop", attrs as never, config);
    const selection = configured
      ? native.selectPlacementsWithConfig
      : native.selectPlacements;
    const shop = configured
      ? native.selectShoppableAdsWithConfig
      : native.selectShoppableAds;
    expect(selection.mock.calls[0][1]).toEqual(expected);
    expect(shop.mock.calls[0][1]).toEqual(expected);
    expect(attrs.zero).toBe(0);
  },
);
test("omitted config uses the no-config native methods on both APIs", () => {
  Rokt.selectPlacements("overlay", {});
  Rokt.selectShoppableAds("shop", {});
  expect(native.selectPlacementsWithConfig).not.toHaveBeenCalled();
  expect(native.selectShoppableAdsWithConfig).not.toHaveBeenCalled();
  expect(native.selectShoppableAds).toHaveBeenCalledWith("shop", {});
});
test.each([
  {},
  { colorMode: "light" as const, cacheConfig: { cacheDurationInSeconds: 30 } },
])("explicit config is forwarded unchanged (%p)", (config) => {
  Rokt.selectPlacements("embedded", {}, ["Location1"], config);
  Rokt.selectShoppableAds("shop", {}, config);
  expect(native.selectPlacementsWithConfig.mock.calls[0][3]).toEqual(config);
  expect(native.selectShoppableAdsWithConfig.mock.calls[0][2]).toEqual(config);
});

test.each([
  [{ colorMode: 1, cacheConfig: "60" }, {}],
  [{ colorMode: "dark", cacheConfig: null }, { colorMode: "dark" }],
  [{ cacheConfig: [] }, {}],
  [
    { cacheConfig: { cacheDurationInSeconds: {}, cacheAttributes: "email" } },
    { cacheConfig: {} },
  ],
  [
    {
      cacheConfig: {
        cacheDurationInSeconds: 30,
        cacheAttributes: { email: "a@example.com", age: 30, missing: null },
      },
    },
    {
      cacheConfig: {
        cacheDurationInSeconds: 30,
        cacheAttributes: { email: "a@example.com", age: "30" },
      },
    },
  ],
  [
    { cacheConfig: { cacheDurationInSeconds: "60" } },
    { cacheConfig: { cacheDurationInSeconds: 60 } },
  ],
  [{ cacheConfig: { cacheDurationInSeconds: " " } }, { cacheConfig: {} }],
  [{ cacheConfig: { cacheDurationInSeconds: "soon" } }, { cacheConfig: {} }],
  [{ cacheConfig: { cacheDurationInSeconds: NaN } }, { cacheConfig: {} }],
  ["dark", {}],
])(
  "only correctly typed config fields reach native (%p)",
  (config, expected) => {
    // JS integrations may supply values outside the public TypeScript contract.
    Rokt.selectPlacements("embedded", {}, ["Location1"], config as never);
    Rokt.selectShoppableAds("shop", {}, config as never);
    expect(native.selectPlacementsWithConfig.mock.calls[0][3]).toEqual(
      expected,
    );
    expect(native.selectShoppableAdsWithConfig.mock.calls[0][2]).toEqual(
      expected,
    );
  },
);

test("untyped null dictionaries retain overlay compatibility", () => {
  Rokt.selectPlacements("overlay", null as never, null as never);
  expect(native.selectPlacements).toHaveBeenCalledWith("overlay", {}, {});
});
