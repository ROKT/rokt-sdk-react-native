import 'react-native'
import { NativeModules } from 'react-native';

//const RNRoktWidget = NativeModules.RNRoktWidget;
const RNRoktWidget = require('./NativeRoktWidget').default;

export abstract class Rokt {

    public static initialize(roktTagId: string, appVersion: string, fontFilesMap?: Record<string, string>): void {
        console.log('Sahil Checking if initialize method exists:', typeof RNRoktWidget.initialize === 'function' ? 'Yes' : 'No');        if (fontFilesMap) {
            RNRoktWidget.initializeWithFontFiles(roktTagId, appVersion, fontFilesMap);
        } else {
            RNRoktWidget.initialize(roktTagId, appVersion);
        }
    }

    public static execute(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig?: IRoktConfig): void {
        if (roktConfig) {
            RNRoktWidget.executeWithConfig(viewName, attributes, placeholders, roktConfig)
        } else {
            RNRoktWidget.execute(viewName, attributes, placeholders);
        }
    }

    public static execute2Step(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig?: IRoktConfig): void {
        if (roktConfig) {
            RNRoktWidget.execute2StepWithConfig(viewName, attributes, placeholders, roktConfig)
        } else {
            RNRoktWidget.execute2Step(viewName, attributes, placeholders);
        }
    }

    public static setFulfillmentAttributes(attributes: Record<string, string>): void {
        RNRoktWidget.setFulfillmentAttributes(attributes);
    }

    public static setEnvironmentToStage(): void {
        RNRoktWidget.setEnvironmentToStage();
    }

    public static setEnvironmentToProd(): void {
        RNRoktWidget.setEnvironmentToProd();
    }

    public static setLoggingEnabled(enabled: boolean): void {
        RNRoktWidget.setLoggingEnabled(enabled);
    }

}


declare module 'react-native' {
    interface NativeModulesStatic {
        RNRoktWidget: RNRoktWidget
    }
}

interface RNRoktWidget {
    initialize(roktTagId: string, appVersion: string): void;
    initializeWithFonts(roktTagId: string, appVersion: string, fontPostScriptNames?: string[]): void;
    initializeWithFontFiles(roktTagId: string, appVersion: string, fontsMap?: Record<string, string>): void;
    execute(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>): void;
    executeWithConfig(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig?: IRoktConfig): void;
    execute2Step(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>): void;
    execute2StepWithConfig(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig?: IRoktConfig): void;
    setFulfillmentAttributes(attributes: Record<string, string>): void;
    setEnvironmentToStage(): void;
    setEnvironmentToProd(): void;
    setLoggingEnabled(enabled: boolean): void;
}

export interface IRoktConfig {
    readonly colorMode?: ColorMode;
    readonly cacheConfig?: CacheConfig;
}

/**
 * Cache configuration for Rokt SDK
 */
export class CacheConfig {
    /**
     * @param cacheDurationInSeconds - The duration in seconds for which the Rokt SDK should cache the experience. Default is 90 minutes
     * @param cacheAttributes - optional attributes to be used as cache key. If null, all the attributes will be used as the cache key
     */
  constructor(
    public readonly cacheDurationInSeconds?: number,
    public readonly cacheAttributes?: Record<string, string>
  ) {}
}

class RoktConfig implements IRoktConfig {
    constructor(roktConfig: RoktConfig) {
        Object.assign(this, roktConfig);
    }
}

export class RoktConfigBuilder implements Partial<IRoktConfig> {
    readonly colorMode?: ColorMode;
    readonly cacheConfig?: CacheConfig;

    public withColorMode(value: ColorMode): this & Pick<IRoktConfig, 'colorMode'> {
        return Object.assign(this, {colorMode: value})
    }

    public withCacheConfig(value: CacheConfig): this & Pick<IRoktConfig, 'cacheConfig'> {
        return Object.assign(this, {cacheConfig: value})
    }

    public build(this: IRoktConfig) {
        return new RoktConfig(this);
    }
}

export type ColorMode = "light" | "dark" | "system"