/**
 * Expo Test App for Rokt React Native SDK
 *
 * This app tests the Expo config plugin integration for the Rokt SDK.
 * It demonstrates SDK initialization and embedded view placement.
 */

import React, { useRef, useState } from "react";
import {
  findNodeHandle,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
  NativeEventEmitter,
} from "react-native";
import {
  Rokt,
  RoktEmbeddedView,
  RoktEventManager,
} from "@rokt/react-native-sdk";

const DEFAULT_TAG_ID = "2754655826098840951";
const DEFAULT_VIEW_NAME = "RoktExperience";
const DEFAULT_PLACEHOLDER = "Location1";

const eventManagerEmitter = new NativeEventEmitter(RoktEventManager);

export default function App() {
  const placeholderRef =
    useRef<React.ComponentRef<typeof RoktEmbeddedView>>(null);

  const [tagId, setTagId] = useState(DEFAULT_TAG_ID);
  const [viewName, setViewName] = useState(DEFAULT_VIEW_NAME);
  const [placeholderName, setPlaceholderName] = useState(DEFAULT_PLACEHOLDER);
  const [isInitialized, setIsInitialized] = useState(false);
  const [status, setStatus] = useState("Not initialized");

  // Listen for Rokt events
  React.useEffect(() => {
    const subscription = eventManagerEmitter.addListener(
      "RoktEvents",
      (data) => {
        console.log("Rokt Event:", JSON.stringify(data));
        if (data.event === "InitComplete") {
          setStatus(`Initialized: ${data.status}`);
        }
      },
    );

    return () => subscription.remove();
  }, []);

  const handleInitialize = () => {
    if (!tagId) {
      setStatus("Error: Tag ID is required");
      return;
    }

    Rokt.setLoggingEnabled(true);
    Rokt.initialize(tagId, "1.0");
    setIsInitialized(true);
    setStatus("Initializing...");
    console.log("Rokt SDK initialized with Tag ID:", tagId);
  };

  const handleExecute = () => {
    if (!isInitialized) {
      setStatus("Error: Initialize SDK first");
      return;
    }

    const attributes = {
      email: "test@example.com",
      firstname: "Test",
      lastname: "User",
      country: "US",
    };

    const placeholders: { [key: string]: number } = {};
    const nodeHandle = findNodeHandle(placeholderRef.current);
    if (nodeHandle !== null) {
      placeholders[placeholderName] = nodeHandle;
    }

    Rokt.execute(viewName, attributes, placeholders);
    setStatus("Executing placement...");
    console.log("Rokt execute called");
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <ScrollView contentContainerStyle={styles.scrollContent}>
        <Text style={styles.title}>Expo Rokt SDK Test</Text>
        <Text style={styles.subtitle}>
          Testing Expo Config Plugin Integration
        </Text>

        <View style={styles.statusContainer}>
          <Text style={styles.statusLabel}>Status:</Text>
          <Text style={styles.statusText}>{status}</Text>
        </View>

        <View style={styles.inputContainer}>
          <Text style={styles.label}>Rokt Tag ID:</Text>
          <TextInput
            style={styles.input}
            value={tagId}
            onChangeText={setTagId}
            placeholder="Enter your Rokt Tag ID"
            autoCapitalize="none"
          />
        </View>

        <View style={styles.inputContainer}>
          <Text style={styles.label}>View Name:</Text>
          <TextInput
            style={styles.input}
            value={viewName}
            onChangeText={setViewName}
            placeholder="Enter view name"
            autoCapitalize="none"
          />
        </View>

        <View style={styles.inputContainer}>
          <Text style={styles.label}>Placeholder Name:</Text>
          <TextInput
            style={styles.input}
            value={placeholderName}
            onChangeText={setPlaceholderName}
            placeholder="Enter placeholder name"
            autoCapitalize="none"
          />
        </View>

        <View style={styles.buttonContainer}>
          <TouchableOpacity
            style={[styles.button, styles.initButton]}
            onPress={handleInitialize}
          >
            <Text style={styles.buttonText}>Initialize SDK</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[
              styles.button,
              styles.executeButton,
              !isInitialized && styles.buttonDisabled,
            ]}
            onPress={handleExecute}
            disabled={!isInitialized}
          >
            <Text style={styles.buttonText}>Execute Placement</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.placeholderContainer}>
          <Text style={styles.label}>Embedded Placement Area:</Text>
          <RoktEmbeddedView
            ref={placeholderRef}
            placeholderName={placeholderName}
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#f5f5f5",
  },
  scrollContent: {
    padding: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 8,
    textAlign: "center",
  },
  subtitle: {
    fontSize: 14,
    color: "#666",
    marginBottom: 24,
    textAlign: "center",
  },
  statusContainer: {
    backgroundColor: "#fff",
    padding: 16,
    borderRadius: 8,
    marginBottom: 20,
    flexDirection: "row",
    alignItems: "center",
  },
  statusLabel: {
    fontWeight: "bold",
    marginRight: 8,
    color: "#333",
  },
  statusText: {
    flex: 1,
    color: "#4ba9c8",
  },
  inputContainer: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: "600",
    color: "#333",
    marginBottom: 6,
  },
  input: {
    backgroundColor: "#fff",
    borderWidth: 1,
    borderColor: "#ddd",
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
  },
  buttonContainer: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 24,
    marginTop: 8,
  },
  button: {
    flex: 1,
    padding: 14,
    borderRadius: 8,
    alignItems: "center",
  },
  initButton: {
    backgroundColor: "#4ba9c8",
    marginRight: 8,
  },
  executeButton: {
    backgroundColor: "#28a745",
    marginLeft: 8,
  },
  buttonDisabled: {
    backgroundColor: "#ccc",
  },
  buttonText: {
    color: "#fff",
    fontSize: 16,
    fontWeight: "bold",
  },
  placeholderContainer: {
    backgroundColor: "#fff",
    padding: 16,
    borderRadius: 8,
    minHeight: 100,
  },
});
