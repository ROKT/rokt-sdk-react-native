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
import { createNativeStackNavigator, NativeStackScreenProps, NativeStackNavigationProp } from '@react-navigation/native-stack';
import {Rokt, RoktEmbeddedView, RoktEventManager} from '@rokt/react-native-sdk';

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

// Navigation types
type RootStackParamList = {
  Home: undefined;
  RoktView: {
    viewName: string;
    email: string;
    firstname: string;
    lastname: string;
    phone?: string;
    placeholderName: string;
  };
  DetailView: {
    email: string;
    firstname: string;
    lastname: string;
    phone?: string;
  };
};

type HomeScreenProps = NativeStackScreenProps<RootStackParamList, 'Home'>;
type RoktViewScreenProps = NativeStackScreenProps<RootStackParamList, 'RoktView'>;
type DetailViewScreenProps = NativeStackScreenProps<RootStackParamList, 'DetailView'>;

const Stack = createNativeStackNavigator<RootStackParamList>();

// Custom Back Button Component
interface CustomBackButtonProps {
  navigation: NativeStackNavigationProp<RootStackParamList, any>;
}

const CustomBackButton: React.FC<CustomBackButtonProps> = ({ navigation }) => {
  return (
    <TouchableOpacity
      onPress={() => navigation.goBack()}
      style={styles.backButton}>
      <Text style={styles.backButtonText}>← Back</Text>
    </TouchableOpacity>
  );
};

// Home Screen Component
interface HomeScreenState {
  tagId: string;
  viewName: string;
  placeholderName: string;
}

class HomeScreen extends Component<HomeScreenProps, HomeScreenState> {
  private subscription: EmitterSubscription;

  constructor(props: HomeScreenProps) {
    super(props);

    this.state = {
      tagId: '', // Enter your Rokt Tag ID here
      viewName: 'RoktExperience', // Your view name
      placeholderName: 'Location1',
    };

    this.componentDidMount = () => {
      console.log('HomeScreen Component did mount ***************');
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

    // Navigate to checkout screen
    this.props.navigation.navigate('RoktView', {
      viewName: this.state.viewName,
      email: '',
      firstname: '',
      lastname: '',
      phone: '',
      placeholderName: this.state.placeholderName,
    });
  };

  onNavigateOnly = () => {
    // Navigate without executing Rokt (for testing view lifecycle)
    this.props.navigation.navigate('RoktView', {
      viewName: this.state.viewName,
      email: '',
      firstname: '',
      lastname: '',
      phone: '',
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
            <Text style={styles.subtitle}>Checkout Flow Example</Text>
          </View>

          <View style={styles.formContainer}>
            <Text style={styles.sectionTitle}>Configuration</Text>

            <Text style={styles.configLabel}>Rokt Tag ID *</Text>
            <TextInput
              style={styles.input}
              value={this.state.tagId}
              onChangeText={tagId => this.setState({ tagId })}
              placeholder="Enter your Tag ID"
            />

            <Text style={styles.configLabel}>View Name</Text>
            <TextInput
              style={styles.input}
              value={this.state.viewName}
              onChangeText={viewName => this.setState({ viewName })}
              placeholder="RoktExperience"
            />

            <Text style={styles.configLabel}>Placeholder Name</Text>
            <TextInput
              style={styles.input}
              value={this.state.placeholderName}
              onChangeText={placeholderName => this.setState({ placeholderName })}
              placeholder="RoktEmbedded1"
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
                <Text style={styles.buttonText}>Go to Checkout</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.buttonContainer}>
              <TouchableOpacity
                style={[styles.button, styles.buttonTertiary]}
                onPress={this.onNavigateOnly}>
                <Text style={styles.buttonText}>Navigate Only</Text>
              </TouchableOpacity>
            </View>
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }
}

// Rokt View Screen Component
interface RoktViewScreenState {
  email: string;
  firstname: string;
  lastname: string;
  phone: string;
  isEmailValid: boolean;
  hasExecutedRokt: boolean;
}

class RoktViewScreen extends Component<RoktViewScreenProps, RoktViewScreenState> {
  private placeholder = React.createRef<any>();

  constructor(props: RoktViewScreenProps) {
    super(props);
    const { email, firstname, lastname, phone } = props.route.params;
    this.state = {
      email: email || '',
      firstname: firstname || '',
      lastname: lastname || '',
      phone: phone || '',
      isEmailValid: false,
      hasExecutedRokt: false,
    };

    this.componentDidMount = () => {
      console.log('RoktViewScreen Component did mount');
    };
  }

  validateEmail = (email: string): boolean => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
  };

  handleEmailChange = (email: string) => {
    this.setState({ email });
  };

  handleEmailBlur = () => {
    const isValid = this.validateEmail(this.state.email);

    if (isValid && !this.state.isEmailValid) {
      // Email just became valid, trigger Rokt execution
      this.setState({ isEmailValid: true }, () => {
        this.executeRokt();
      });
    } else if (!isValid && this.state.isEmailValid) {
      this.setState({ isEmailValid: false });
    }
  };

  executeRokt = () => {
    const { email, firstname, lastname, phone } = this.state;

    const attributes: { [key: string]: string } = {
      email,
      firstname,
      lastname,
      mobile: phone || '',
      sandbox: 'true',
      country: 'US',
      customertype: 'guest',
      deliverytype: 'carryout',
    };

    const placeholders: { [key: string]: number } = {};
    const nodeHandle = findNodeHandle(this.placeholder.current);
    console.log('Node handle:', nodeHandle);

    if (nodeHandle !== null) {
      placeholders['RoktEmbedded1'] = nodeHandle;
      console.log('Placeholders registered:', placeholders);
    } else {
      console.error('ERROR: Node handle is null! Placeholder not properly registered');
      return;
    }

    console.log('Executing Rokt with attributes:', attributes);

    Rokt.execute("RoktEmbeddedExperience", attributes, placeholders);
    this.setState({ hasExecutedRokt: true });
    console.log('Rokt Execute called');
  };

  onNavigateToDetail = () => {
    const { email, firstname, lastname, phone } = this.state;
    this.props.navigation.navigate('DetailView', {
      email,
      firstname,
      lastname,
      phone,
    });
  };

  render() {
    return (
      <SafeAreaView style={styles.container}>
        <ScrollView
          contentInsetAdjustmentBehavior="automatic"
          style={styles.scrollView}
          keyboardShouldPersistTaps="handled">
          <View style={styles.checkoutContainer}>
            <View style={styles.formSection}>
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

              <Text style={styles.label}>Email Address</Text>
              <TextInput
                style={[
                  styles.input,
                  this.state.email && !this.state.isEmailValid && styles.inputError,
                  this.state.isEmailValid && styles.inputValid
                ]}
                value={this.state.email}
                onChangeText={this.handleEmailChange}
                onBlur={this.handleEmailBlur}
                placeholder="customer@example.com"
                keyboardType="email-address"
                autoCapitalize="none"
              />
              {this.state.email && !this.state.isEmailValid && (
                <Text style={styles.errorText}>Please enter a valid email address</Text>
              )}

              <Text style={styles.label}>Phone Number</Text>
              <TextInput
                style={styles.input}
                value={this.state.phone}
                onChangeText={phone => this.setState({ phone })}
                placeholder="Phone Number"
                keyboardType="phone-pad"
              />

              <TouchableOpacity
                style={[styles.button, styles.buttonTertiary, styles.singleButton]}
                onPress={this.onNavigateToDetail}>
                <Text style={styles.buttonText}>Continue to Details</Text>
              </TouchableOpacity>
            </View>

            <View style={styles.roktPlacementSection}>
              <RoktEmbeddedView
                ref={this.placeholder}
                placeholderName="RoktEmbedded1"
              />
            </View>
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }
}

// Detail View Screen Component
class DetailViewScreen extends Component<DetailViewScreenProps> {
  render() {
    const { email, firstname, lastname, phone } = this.props.route.params;

    return (
      <SafeAreaView style={styles.container}>
        <ScrollView
          contentInsetAdjustmentBehavior="automatic"
          style={styles.scrollView}>
          <View style={styles.formContainer}>
            <Text style={styles.sectionTitle}>User Information</Text>

            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>First Name:</Text>
              <Text style={styles.infoValue}>{firstname}</Text>
            </View>

            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Last Name:</Text>
              <Text style={styles.infoValue}>{lastname}</Text>
            </View>

            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Email:</Text>
              <Text style={styles.infoValue}>{email}</Text>
            </View>

            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Phone:</Text>
              <Text style={styles.infoValue}>{phone || 'Not provided'}</Text>
            </View>

            <View style={styles.detailDescription}>
              <Text style={styles.label}>Additional Information</Text>
              <Text style={styles.descriptionText}>
                This is the detailed view that shows customer information.
                You can customize this screen to display any additional
                details or functionality you need.
              </Text>
            </View>
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
          options={({ navigation }) => ({
            title: 'Checkout',
            headerLeft: () => <CustomBackButton navigation={navigation} />,
          })}
        />
        <Stack.Screen
          name="DetailView"
          component={DetailViewScreen}
          options={({ navigation }) => ({
            title: 'User Details',
            headerLeft: () => <CustomBackButton navigation={navigation} />,
          })}
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
  checkoutContainer: {
    flex: 1,
  },
  formSection: {
    backgroundColor: '#ffffff',
    padding: 20,
    paddingBottom: 30,
  },
  roktPlacementSection: {
    backgroundColor: '#f5f5f5',
    padding: 20,
    minHeight: 200,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#333',
    marginTop: 20,
    marginBottom: 12,
  },
  label: {
    fontSize: 13,
    fontWeight: '400',
    color: '#999',
    marginTop: 16,
    marginBottom: 8,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  configLabel: {
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
  inputError: {
    borderColor: '#ff3b30',
    borderWidth: 2,
  },
  inputValid: {
    borderColor: '#34c759',
    borderWidth: 2,
  },
  errorText: {
    color: '#ff3b30',
    fontSize: 12,
    marginTop: 4,
    marginLeft: 4,
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
  singleButton: {
    marginTop: 24,
  },
  buttonPrimary: {
    backgroundColor: '#4ba9c8',
  },
  buttonSecondary: {
    backgroundColor: '#34c759',
  },
  buttonTertiary: {
    backgroundColor: '#ff9500',
  },
  buttonText: {
    color: '#ffffff',
    fontSize: 16,
    fontWeight: '600',
  },
  detailButton: {
    marginTop: 24,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#f0f0f0',
  },
  infoLabel: {
    fontSize: 16,
    fontWeight: '600',
    color: '#666',
  },
  infoValue: {
    fontSize: 16,
    color: '#333',
  },
  detailDescription: {
    marginTop: 24,
    padding: 16,
    backgroundColor: '#f9f9f9',
    borderRadius: 8,
  },
  descriptionText: {
    fontSize: 14,
    color: '#666',
    lineHeight: 20,
    marginTop: 8,
  },
  backButton: {
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  backButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '600',
  },
});
