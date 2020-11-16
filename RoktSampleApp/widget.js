// Widget.js
import { requireNativeComponent , StyleSheet} from 'react-native';
import React, {Component} from 'react';

class RoktWidget extends Component {

    constructor(props){
        super(props);
        this.state = { height: 0};
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
  }

  const WidgetNativeComponent = requireNativeComponent('RoktNativeWidget')

  const styles = StyleSheet.create({
    widget: {
        flex: 1},
    });
  
  export default RoktWidget;

