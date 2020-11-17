// Widget.js
import { requireNativeComponent , StyleSheet, NativeEventEmitter, NativeModules} from 'react-native';
import React, {Component} from 'react';
const { RoktEventManager } = NativeModules;

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);



class RoktWidget extends Component {


  subscription = eventManagerEmitter.addListener(
    'WidgetHeightChanges',
    (widgetChanges) => {
      if (widgetChanges.selectedPlacement == this.state.viewName) {
        this.state.height = parseInt(widgetChanges.height);
        this.forceUpdate();
      } 
    }
  );

    constructor(props){
        super(props);
        this.state = { height: 0,
        viewName: this.props.viewName};
        this.onWidgetHeightChanged = this.onWidgetHeightChanged.bind(this);
    }

    onWidgetHeightChanged(event: Event) {   
         this.state.height = parseInt(event.nativeEvent.height);
         this.forceUpdate();
     }
   
    render() {
      return (
          <WidgetNativeComponent style={[styles.widget, {height: this.state.height}]} onWidgetHeightChanged={this.onWidgetHeightChanged}/>
      );
    }

    // Don't forget to unsubscribe, typically in componentWillUnmount
// subscription.remove();
  }

  const WidgetNativeComponent = requireNativeComponent('RoktNativeWidget')

  const styles = StyleSheet.create({
    widget: {
        flex: 1},
    });
  
  export default RoktWidget;


