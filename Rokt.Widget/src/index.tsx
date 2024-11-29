import 'react-native'
import { NativeModules } from 'react-native';
import { RoktEmbeddedView } from './rokt-embedded-view'
import { Rokt, IRoktConfig, RoktConfigBuilder, ColorMode, CacheConfig } from './Rokt'

const { RoktEventManager } = NativeModules;

export { RoktEmbeddedView, Rokt, RoktEventManager, RoktConfigBuilder, CacheConfig };
export type { IRoktConfig, ColorMode };