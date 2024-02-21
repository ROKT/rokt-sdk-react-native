import { NativeModules } from 'react-native';
import {RoktEmbeddedView} from './rokt-embedded-view'
import 'react-native'

export interface RNRoktWidget {
    initialize(roktTagId: string, appVersion: string, fontPostScriptNames: string[]): void;
    execute(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, fontNames: Record<string, string>): void;
    execute2Step(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, fontNames: Record<string, string>): void;
    setFulfillmentAttributes(attributes: Record<string, string>): void;
    setEnvironmentToStage(): void;
    setEnvironmentToProd(): void;
    toggleDebug(enabled: boolean): void;
}

declare module 'react-native' {
    interface NativeModulesStatic {
        RNRoktWidget: RNRoktWidget
    }
}

const RNRoktWidget = NativeModules.RNRoktWidget;
const { RoktEventManager } = NativeModules;

export {RoktEmbeddedView, RNRoktWidget as Rokt, RoktEventManager};