import * as fs from "fs";
import * as path from "path";

/**
 * The podspec compiles every file under ios/ by glob, but Package.swift lists the Objective-C++
 * target's sources by hand, and CI does not build that manifest. Keep the two in step.
 */
const root = path.join(__dirname, "..");

function nativeSources(directory: string): string[] {
  return fs
    .readdirSync(path.join(root, directory), { withFileTypes: true })
    .flatMap((entry) => {
      const file = path.posix.join(directory, entry.name);
      if (entry.isDirectory()) return nativeSources(file);
      return /\.(h|m|swift|mm)$/.test(entry.name) ? [file] : [];
    });
}

test("Package.swift lists every Objective-C source under ios/", () => {
  const manifest = fs.readFileSync(path.join(root, "Package.swift"), "utf-8");
  const listed = [...manifest.matchAll(/"(ios\/[^"]+\.(?:h|m|mm))"/g)].map(
    (match) => match[1],
  );
  const onDisk = nativeSources("ios").filter(
    (file) => !file.endsWith(".swift"),
  );

  expect([...listed].sort()).toEqual(onDisk.sort());
});

test("Package.swift includes every Swift source under its Swift target path", () => {
  const manifest = fs.readFileSync(path.join(root, "Package.swift"), "utf-8");
  const swiftSources = nativeSources("ios").filter((file) =>
    file.endsWith(".swift"),
  );

  expect(manifest).toContain('path: "ios/Swift"');
  expect(swiftSources.filter((file) => !file.startsWith("ios/Swift/"))).toEqual(
    [],
  );
});

test("the npm package ships Package.swift and react-native.config.js", () => {
  const { files } = JSON.parse(
    fs.readFileSync(path.join(root, "package.json"), "utf-8"),
  ) as { files: string[] };

  expect(files).toEqual(
    expect.arrayContaining(["Package.swift", "react-native.config.js"]),
  );
});

test("Package.swift uses the package name react-native.config.js gives React Native", () => {
  const config = require("../react-native.config.js") as {
    spm: { name: string };
  };
  const manifest = fs.readFileSync(path.join(root, "Package.swift"), "utf-8");

  expect(manifest).toContain(`.library(name: "${config.spm.name}"`);
});
