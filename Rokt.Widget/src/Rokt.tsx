import 'react-native'
import { NativeModules } from 'react-native';

const RNRoktWidget = NativeModules.RNRoktWidget;

export abstract class Rokt {

    public static initialize(roktTagId: string, appVersion: string, fontPostScriptNames?: string[]): void {
        if (fontPostScriptNames && fontPostScriptNames.length > 0) {
            RNRoktWidget.initializeWithFonts(roktTagId, appVersion, fontPostScriptNames);
        } else {
            RNRoktWidget.initialize(roktTagId, appVersion);
        }
    }

    public static execute(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, fontNames?: Record<string, string>): void {
        if (fontNames) {
            RNRoktWidget.executeWithFonts(viewName, attributes, placeholders, fontNames);
        } else {
            RNRoktWidget.execute(viewName, attributes, placeholders);
        }
    }

    public static execute2Step(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, fontNames?: Record<string, string>): void {
        if (fontNames) {
            RNRoktWidget.execute2StepWithFonts(viewName, attributes, placeholders, fontNames);
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

    public static toggleDebug(enabled: boolean): void {
        RNRoktWidget.toggleDebug(enabled);
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
    execute(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>): void;
    executeWithFonts(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, fontNames?: Record<string, string>): void;
    execute2Step(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>): void;
    execute2StepWithFonts(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, fontNames?: Record<string, string>): void;
    setFulfillmentAttributes(attributes: Record<string, string>): void;
    setEnvironmentToStage(): void;
    setEnvironmentToProd(): void;
    toggleDebug(enabled: boolean): void;
}