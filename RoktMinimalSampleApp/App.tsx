/**
 * Minimal Demo Application for Rokt React Native SDK
 * 
 * This app demonstrates Rokt SDK integration with React Navigation.
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
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator, NativeStackScreenProps } from '@react-navigation/native-stack';
import {Rokt, RoktEmbeddedView, RoktEventManager} from '@rokt/react-native-sdk';

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

type RoktEmbeddedViewRef = React.ComponentRef<typeof RoktEmbeddedView>;

// Navigation types
type RootStackParamList = {
  Home: undefined;
  RoktView: {
    viewName: string;
    email: string;
    firstname: string;
    lastname: string;
    placeholderName: string;
  };
};

type HomeScreenProps = NativeStackScreenProps<RootStackParamList, 'Home'>;
type RoktViewScreenProps = NativeStackScreenProps<RootStackParamList, 'RoktView'>;

const Stack = createNativeStackNavigator<RootStackParamList>();

// Home Screen Component
interface HomeScreenState {
  tagId: string;
  viewName: string;
  placeholderName: string;
  email: string;
  firstname: string;
  lastname: string;
}

class HomeScreen extends Component<HomeScreenProps, HomeScreenState> {
  private subscription: EmitterSubscription;

  constructor(props: HomeScreenProps) {
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
    Rokt.setLoggingEnabled(true);
    Rokt.initialize("2646161524817932499", '1.0');
    console.log('Rokt SDK Initialized');
  };

  onExecute = () => {
    if (!this.state.viewName) {
      console.error('Please enter a valid View Name');
      return;
    }

    // Navigate to Rokt view screen with parameters
    this.props.navigation.navigate('RoktView', {
      viewName: this.state.viewName,
      email: this.state.email,
      firstname: this.state.firstname,
      lastname: this.state.lastname,
      placeholderName: this.state.placeholderName,
    });
  };

  render() {
    return (
      <SafeAreaView style={styles.container}>
        <ScrollView
          contentInsetAdjustmentBehavior="automatic"
          style={styles.scrollView}>
          <View style={styles.header}>
            <Text style={styles.title}>Rokt SDK Demo</Text>
            <Text style={styles.subtitle}>React Navigation Example</Text>
          </View>

          <View style={styles.formContainer}>
            <Text style={styles.label}>Rokt Tag ID *</Text>
            <TextInput
              style={styles.input}
              value={this.state.tagId}
              onChangeText={tagId => this.setState({ tagId })}
              placeholder="Enter your Tag ID"
            />

            <Text style={styles.label}>View Name</Text>
            <TextInput
              style={styles.input}
              value={this.state.viewName}
              onChangeText={viewName => this.setState({ viewName })}
              placeholder="RoktExperience"
            />

            <Text style={styles.label}>Placeholder Name</Text>
            <TextInput
              style={styles.input}
              value={this.state.placeholderName}
              onChangeText={placeholderName => this.setState({ placeholderName })}
              placeholder="RoktEmbedded1"
            />

            <Text style={styles.sectionTitle}>Customer Attributes</Text>

            <Text style={styles.label}>Email</Text>
            <TextInput
              style={styles.input}
              value={this.state.email}
              onChangeText={email => this.setState({ email })}
              placeholder="customer@example.com"
              keyboardType="email-address"
              autoCapitalize="none"
            />

            <Text style={styles.label}>First Name</Text>
            <TextInput
              style={styles.input}
              value={this.state.firstname}
              onChangeText={firstname => this.setState({ firstname })}
              placeholder="First Name"
            />

            <Text style={styles.label}>Last Name</Text>
            <TextInput
              style={styles.input}
              value={this.state.lastname}
              onChangeText={lastname => this.setState({ lastname })}
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
        </ScrollView>
      </SafeAreaView>
    );
  }
}

// Rokt View Screen Component
class RoktViewScreen extends Component<RoktViewScreenProps> {
  private placeholder = React.createRef<RoktEmbeddedViewRef>();

  componentDidMount() {
    // Execute Rokt after the view is mounted
    setTimeout(() => {
      const { email, firstname, lastname } = this.props.route.params;

      const attributes: { [key: string]: string } = {
        email,
        firstname,
        lastname,
        sandbox: 'true',
        country: 'US',
        customertype: 'guest',
        deliverytype: 'carryout',
        mobile: ''
      };

      const placeholders: { [key: string]: number } = {};
      const nodeHandle = findNodeHandle(this.placeholder.current);
      console.log('Node handle:', nodeHandle);

      if (nodeHandle !== null) {
        placeholders['RoktEmbedded1'] = nodeHandle;
        console.log('Placeholders registered:', placeholders);
      } else {
        console.error('ERROR: Node handle is null! Placeholder not properly registered');
      }

      console.log('Executing with viewName:', this.props.route.params.viewName);
      console.log('Attributes:', attributes);

      Rokt.execute("RoktEmbeddedExperience", attributes, placeholders);
      console.log('Rokt Execute called');
    }, 100);
  }

  render() {
    const { placeholderName } = this.props.route.params;

    return (
      <SafeAreaView style={styles.container}>
        <ScrollView
          contentInsetAdjustmentBehavior="automatic"
          style={styles.scrollView}>
          <View style={styles.placeholderContainer}>
            <Text style={styles.placeholderLabel}>
              Rokt Placement ({placeholderName})
            </Text>
            <RoktEmbeddedView
              ref={this.placeholder}
              placeholderName="RoktEmbedded1"
            />
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }
}

// Main App Component
export default function App() {
  return (
    <NavigationContainer>
      <StatusBar barStyle="dark-content" />
      <Stack.Navigator
        initialRouteName="Home"
        screenOptions={{
          headerStyle: {
            backgroundColor: '#4ba9c8',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        }}>
        <Stack.Screen
          name="Home"
          component={HomeScreen}
          options={{
            title: 'Rokt SDK Demo',
          }}
        />
        <Stack.Screen
          name="RoktView"
          component={RoktViewScreen}
          options={{
            title: 'Rokt Offers',
          }}
        />
      </Stack.Navigator>
    </NavigationContainer>
  );
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
    minHeight: 300,
  },
  placeholderLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 12,
  },
});
