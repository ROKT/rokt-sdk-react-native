import 'react-native'
import { NativeModules } from 'react-native';
import { RoktEmbeddedView } from './rokt-embedded-view'
import { Rokt } from './Rokt'

const { RoktEventManager } = NativeModules;

export {RoktEmbeddedView, Rokt, RoktEventManager};