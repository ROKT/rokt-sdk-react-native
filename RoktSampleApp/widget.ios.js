// Widget.js
import { requireNativeComponent , StyleSheet, NativeEventEmitter, NativeModules} from 'react-native';
import React, {Component} from 'react';
const { RoktEventManager } = NativeModules;

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

class RoktWidget extends Component {

  subscription = eventManagerEmitter.addListener(
    'WidgetHeightChanges',
    (widgetChanges) => {
      console.log
      if (widgetChanges.selectedPlacement == this.state.palcementName) {
        this.state.height = parseInt(widgetChanges.height);
        this.forceUpdate();
      } 
    }
  );

    constructor(props){
        super(props);

        this.state = { height: 0,  palcementName: this.props.palcementName, marginTop: 0, marginRight: 0, marginLeft: 0, marginBottom: 0};
        this.onWidgetHeightChanged = this.onWidgetHeightChanged.bind(this);
        this.onWidgetMarginChanged = this.onWidgetMarginChanged.bind(this);
    }

    render() {
      return (
          <WidgetNativeComponent style={[styles.widget, {height: this.state.height}]}/>
      );
    }

    // Don't forget to unsubscribe, typically in componentWillUnmount
// subscription.remove();
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
  
  export default RoktWidget;


