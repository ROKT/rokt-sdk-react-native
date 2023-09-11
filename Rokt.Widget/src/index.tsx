import { NativeModules } from 'react-native';
import {RoktEmbeddedView} from './rokt-embedded-view'
import 'react-native'

export interface RNRoktWidget {
    initialize(roktTagId: string, appVersion: string): void;
    execute(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, callback: () => void): void;
    /** @deprecated execute with type {@link Map} is depreacted, use signature with {@link Record} instead*/
    execute(viewName: string, attributes: Map<string, string>, placeholders: Map<string, number>, callback: () => void): void;
    execute2Step(viewName: string, attributes: Record<string, string>, placeholders: Record<string, number | null>, callback: () => void): void;
    /** @deprecated execute2Step with type {@link Map} is depreacted, use signature with {@link Record} instead*/
    execute2Step(viewName: string, attributes: Map<string, string>, placeholders: Map<string, number>, callback: () => void): void;
    setFulfillmentAttributes(attributes: Record<string, string>): void;
    /** @deprecated setFulfillmentAttributes with type {@link Map} is depreacted, use signature with {@link Record} instead*/
    setFulfillmentAttributes(attributes: Map<string, string>): void;
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