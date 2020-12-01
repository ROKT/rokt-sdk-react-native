
import { NativeModules } from 'react-native';
import RoktEmbeddedView from './widget'

const { RNRoktWidget } = NativeModules;

export {RoktEmbeddedView, RNRoktWidget as Rokt};
