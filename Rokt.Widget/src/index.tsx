import { NativeModules } from 'react-native';
import {RoktEmbeddedView} from './rokt-embedded-view'
import 'react-native'

export interface RNRoktWidget {
    initialize(roktTagId: string, appVersion: string): void;
    execute(viewName: string, attributes: Map<string, string>, placeholders: Map<string, number>, callback: () => void): void;
    execute2Step(viewName: string, attributes: Map<string, string>, placeholders: Map<string, number>, callback: () => void): void;
    setFulfillmentAttributes(attributes: Map<string, string>): void;
    setEnvironmentToStage(): void;
    setEnvironmentToProd(): void;
    toggleDebug(enabled: boolean): void;
    sendUrlFailure(urlId: string, brokenUrl: string, description: string): void;
}

declare module 'react-native' {
    interface NativeModulesStatic {
        RNRoktWidget: RNRoktWidget
    }
}

const RNRoktWidget = NativeModules.RNRoktWidget;
const { RoktEventManager } = NativeModules;

export {RoktEmbeddedView, RNRoktWidget as Rokt, RoktEventManager};