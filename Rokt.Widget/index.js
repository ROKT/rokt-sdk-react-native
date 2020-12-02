
import { NativeModules } from 'react-native';
import RoktEmbeddedView from './rokt-embedded-view'

const { RNRoktWidget } = NativeModules;

export {RoktEmbeddedView, RNRoktWidget as Rokt};
