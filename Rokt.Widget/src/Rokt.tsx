import 'react-native'
import { NativeModules } from 'react-native';

const RNRoktWidget = NativeModules.RNRoktWidget;

export abstract class Rokt {

    public static initialize(roktTagId: string, appVersion: string, fontFilesMap?: Record<string, string>): void {
        if (fontFilesMap) {
            RNRoktWidget.initializeWithFontFiles(roktTagId, appVersion, fontFilesMap);
        } else {
            RNRoktWidget.initialize(roktTagId, appVersion);
        }
    }

    public static execute(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig?: IRoktConfig): void {
        if (roktConfig) {
            return // TODO implement
        } else {
            RNRoktWidget.execute(viewName, attributes, placeholders);
        }
    }

    public static execute2Step(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig?: IRoktConfig): void {
        if (roktConfig) {
            return // TODO implement
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
    execute(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig?: IRoktConfig): void;
    execute2Step(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, roktConfig?: IRoktConfig): void;
    setFulfillmentAttributes(attributes: Record<string, string>): void;
    setEnvironmentToStage(): void;
    setEnvironmentToProd(): void;
    setLoggingEnabled(enabled: boolean): void;
}

export interface IRoktConfig {
    readonly colorMode?: ColorMode;
}

class RoktConfig implements IRoktConfig {
    constructor(roktConfig: RoktConfig) {
        Object.assign(this, roktConfig);
    }
}

export class RoktConfigBuilder implements Partial<IRoktConfig> {
    readonly colorMode?: ColorMode;

    public withColorMode(value: ColorMode): this & Pick<IRoktConfig, 'colorMode'> {
        return Object.assign(this, {colorMode: value})
    }

    public build(this: IRoktConfig) {
        return new RoktConfig(this);
    }
}

export enum ColorMode {
    LIGHT = "LIGHT",
    DARK = "DARK",
    SYSTEM = "SYSTEM"
}