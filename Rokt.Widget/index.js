
import { NativeModules } from 'react-native';
import RoktEmbeddedView from './RoktEmbeddedView'

const { RNRoktWidget } = NativeModules;

export {RoktEmbeddedView, RNRoktWidget as Rokt};
