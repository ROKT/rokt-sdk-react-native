import 'react-native'
import { NativeModules } from 'react-native';
import { RoktEmbeddedView } from './rokt-embedded-view'
import { Rokt, IRoktConfig, RoktConfigBuilder, ColorMode } from './Rokt'

const { RoktEventManager } = NativeModules;

export {RoktEmbeddedView, Rokt, RoktEventManager, RoktConfigBuilder, ColorMode};
export type {IRoktConfig};