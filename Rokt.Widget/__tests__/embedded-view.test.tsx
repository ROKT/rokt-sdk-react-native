const remove = jest.fn();
const addListener = jest.fn(() => ({ remove }));
const emitter = jest.fn(() => ({ addListener }));
let available = true;
jest.mock("react-native", () => ({
  StyleSheet: { create: (styles: unknown) => styles },
  NativeEventEmitter: emitter,
  NativeModules: {},
  TurboModuleRegistry: { get: () => (available ? {} : null) },
}));
jest.mock("../src/RoktNativeWidgetNativeComponent", () => ({
  __esModule: true,
  default: "NativeWidget",
}));

beforeEach(() => {
  jest.resetModules();
  jest.clearAllMocks();
  available = true;
});
test("import and construction create no listeners; mount subscribes and unmount removes", () => {
  const { RoktEmbeddedView } = require("../src/rokt-embedded-view.ios");
  const view = new RoktEmbeddedView({ placeholderName: "Location1" });
  expect(emitter).not.toHaveBeenCalled();
  view.componentDidMount();
  expect(addListener).toHaveBeenCalledTimes(1);
  const callback = (
    addListener.mock.calls as unknown as [string, (event: unknown) => void][]
  )[0][1];
  view.setState = jest.fn();
  view.props = { placeholderName: "Location2" };
  callback({ selectedPlacement: "Location1", height: 100 });
  expect(view.setState).not.toHaveBeenCalled();
  callback({ selectedPlacement: "Location2", height: 200 });
  expect(view.setState).toHaveBeenCalledWith({ height: 200 });
  expect(view.render().props.placeholderName).toBe("Location2");
  view.componentWillUnmount();
  expect(remove).toHaveBeenCalledTimes(1);
});
test("a missing emitter cannot crash import, mount, or unmount", () => {
  available = false;
  const warn = jest.spyOn(console, "warn").mockImplementation(() => {});
  const { RoktEmbeddedView } = require("../src/rokt-embedded-view.ios");
  const view = new RoktEmbeddedView({ placeholderName: "Location1" });
  view.componentDidMount();
  view.componentWillUnmount();
  expect(emitter).not.toHaveBeenCalled();
  expect(warn).toHaveBeenCalled();
  warn.mockRestore();
});
test.each(["ios", "android"])(
  "%s preserves measured height without flex sizing",
  (platform) => {
    const { RoktEmbeddedView } = require(
      `../src/rokt-embedded-view.${platform}`,
    );
    const view = new RoktEmbeddedView({ placeholderName: "Location1" });
    view.state = { ...view.state, height: 240 };
    const style = Object.assign({}, ...view.render().props.style);
    expect(style.height).toBe(240);
    expect(style.alignSelf).toBe("stretch");
    expect(style.flex).toBeUndefined();
    expect(style.flexBasis).toBeUndefined();
  },
);
