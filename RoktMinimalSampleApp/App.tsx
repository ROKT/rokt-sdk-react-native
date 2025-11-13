/**
 * Minimal Demo Application for Rokt React Native SDK
 * 
 * This app demonstrates basic Rokt SDK integration without any additional dependencies.
 */

import React, {Component} from 'react';
import {
  EmitterSubscription,
  findNodeHandle,
  NativeEventEmitter,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import {Rokt, RoktEmbeddedView, RoktEventManager} from '@rokt/react-native-sdk';

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

type RoktEmbeddedViewRef = React.ComponentRef<typeof RoktEmbeddedView>;

interface Props {}

interface State {
  tagId: string;
  viewName: string;
  placeholderName: string;
  email: string;
  firstname: string;
  lastname: string;
}

export default class App extends Component<Props, State> {
  private placeholder = React.createRef<RoktEmbeddedViewRef>();
  private subscription: EmitterSubscription;

  constructor(props: Props) {
    super(props);

    this.state = {
      tagId: '', // Enter your Rokt Tag ID here
      viewName: 'RoktExperience', // Your view name
      placeholderName: 'Location1',
      email: 'test@example.com',
      firstname: 'John',
      lastname: 'Doe',
    };

    // Listen for Rokt events
    this.subscription = eventManagerEmitter.addListener(
      'RoktEvents',
      data => {
        console.log(`Rokt Event: ${JSON.stringify(data)}`);
      },
    );
  }

  componentWillUnmount() {
    this.subscription.remove();
  }

  onInitialize = () => {
    if (!this.state.tagId) {
      console.error('Please enter a valid Tag ID');
      return;
    }
    
    Rokt.setLoggingEnabled(true);
    Rokt.setEnvironmentToStage(); // Use .setEnvironmentToProd() for production
    Rokt.initialize(this.state.tagId, '1.0');
    console.log('Rokt SDK Initialized');
  };

  onExecute = () => {
    if (!this.state.viewName) {
      console.error('Please enter a valid View Name');
      return;
    }

    const attributes: {[key: string]: string} = {
      email: this.state.email,
      firstname: this.state.firstname,
      lastname: this.state.lastname,
    };

    const placeholders: {[key: string]: number} = {};
    const nodeHandle = findNodeHandle(this.placeholder.current);
    if (nodeHandle !== null) {
      placeholders[this.state.placeholderName] = nodeHandle;
    }

    Rokt.execute(this.state.viewName, attributes, placeholders);
    console.log('Rokt Execute called');
  };

  render() {
    return (
      <>
        <StatusBar barStyle="dark-content" />
        <SafeAreaView style={styles.container}>
          <ScrollView
            contentInsetAdjustmentBehavior="automatic"
            style={styles.scrollView}>
            <View style={styles.header}>
              <Text style={styles.title}>Rokt SDK Demo</Text>
              <Text style={styles.subtitle}>Minimal Integration Example</Text>
            </View>

            <View style={styles.formContainer}>
              <Text style={styles.label}>Rokt Tag ID *</Text>
              <TextInput
                style={styles.input}
                value={this.state.tagId}
                onChangeText={tagId => this.setState({tagId})}
                placeholder="Enter your Tag ID"
              />

              <Text style={styles.label}>View Name</Text>
              <TextInput
                style={styles.input}
                value={this.state.viewName}
                onChangeText={viewName => this.setState({viewName})}
                placeholder="RoktExperience"
              />

              <Text style={styles.label}>Placeholder Name</Text>
              <TextInput
                style={styles.input}
                value={this.state.placeholderName}
                onChangeText={placeholderName => this.setState({placeholderName})}
                placeholder="Location1"
              />

              <Text style={styles.sectionTitle}>Customer Attributes</Text>

              <Text style={styles.label}>Email</Text>
              <TextInput
                style={styles.input}
                value={this.state.email}
                onChangeText={email => this.setState({email})}
                placeholder="customer@example.com"
                keyboardType="email-address"
                autoCapitalize="none"
              />

              <Text style={styles.label}>First Name</Text>
              <TextInput
                style={styles.input}
                value={this.state.firstname}
                onChangeText={firstname => this.setState({firstname})}
                placeholder="First Name"
              />

              <Text style={styles.label}>Last Name</Text>
              <TextInput
                style={styles.input}
                value={this.state.lastname}
                onChangeText={lastname => this.setState({lastname})}
                placeholder="Last Name"
              />

              <View style={styles.buttonContainer}>
                <TouchableOpacity
                  style={[styles.button, styles.buttonPrimary]}
                  onPress={this.onInitialize}>
                  <Text style={styles.buttonText}>Initialize</Text>
                </TouchableOpacity>

                <TouchableOpacity
                  style={[styles.button, styles.buttonSecondary]}
                  onPress={this.onExecute}>
                  <Text style={styles.buttonText}>Execute</Text>
                </TouchableOpacity>
              </View>
            </View>

            <View style={styles.placeholderContainer}>
              <Text style={styles.placeholderLabel}>
                Rokt Placement ({this.state.placeholderName})
              </Text>
              <RoktEmbeddedView
                ref={this.placeholder}
                placeholderName={this.state.placeholderName}
                style={styles.roktPlacement}
              />
            </View>
          </ScrollView>
        </SafeAreaView>
      </>
    );
  }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollView: {
    flex: 1,
  },
  header: {
    backgroundColor: '#4ba9c8',
    padding: 24,
    alignItems: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#ffffff',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#ffffff',
    opacity: 0.9,
  },
  formContainer: {
    backgroundColor: '#ffffff',
    padding: 20,
    margin: 16,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginTop: 20,
    marginBottom: 12,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#666',
    marginTop: 12,
    marginBottom: 6,
  },
  input: {
    height: 44,
    borderColor: '#ddd',
    borderWidth: 1,
    borderRadius: 8,
    paddingHorizontal: 12,
    fontSize: 16,
    backgroundColor: '#fff',
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 24,
    gap: 12,
  },
  button: {
    flex: 1,
    height: 48,
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
  },
  buttonPrimary: {
    backgroundColor: '#4ba9c8',
  },
  buttonSecondary: {
    backgroundColor: '#34c759',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  placeholderContainer: {
    backgroundColor: '#ffffff',
    padding: 20,
    margin: 16,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  placeholderLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 12,
  },
  roktPlacement: {
    minHeight: 100,
  },
});


