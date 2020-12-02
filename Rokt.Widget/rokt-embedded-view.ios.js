// rokt-embedded-view.js
import { requireNativeComponent , StyleSheet, NativeEventEmitter, NativeModules} from 'react-native';
import React, {Component} from 'react';
const { RoktEventManager } = NativeModules;

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

class RoktEmbeddedView extends Component {

  subscription = eventManagerEmitter.addListener(
    'WidgetHeightChanges',
    (widgetChanges) => {
      console.log
      if (widgetChanges.selectedPlacement == this.state.placeholderName) {
        this.state.height = parseInt(widgetChanges.height);
        this.forceUpdate();
      } 
    }
  );

    constructor(props){
        super(props);

         this.state = { height: 0,  placeholderName: this.props.placeholderName};
    }

    render() {
      return (
          <WidgetNativeComponent style={[styles.widget, {height: this.state.height}]}/>
      );
    }

    componentWillUnmount(){
      this.subscription.remove();
    }

  }

  const WidgetNativeComponent = requireNativeComponent('RoktNativeWidget')

  const styles = StyleSheet.create({
    widget: {
        flex: 1,
        backgroundColor: 'white' },
    });
  
  export default RoktEmbeddedView;


