#include <ArduTFLite.h>
#include "gru_model.h"

// ── Model dimensions (must match notebook) ───────────────────────────────────
// no_feature     = 64   (EEG channels / features per time-step)
// segment_length = 16   (time steps per window)
// n_class        = 2    (labels kept: 0 and 1; labels 2-10 removed)
constexpr int NUM_FEATURES    = 64;
constexpr int SEGMENT_LENGTH  = 16;
constexpr int NUM_INPUTS      = NUM_FEATURES * SEGMENT_LENGTH; // 1024
constexpr int NUM_CLASSES     = 2;

// Gesture / class labels (update names to match your dataset)
const char* GESTURES[NUM_CLASSES] = { "Class_0", "Class_1" };

// Arena size: GRU models need more RAM than simple dense nets.
// Increase if modelInit() fails (try 32, 48, 64 KB).
constexpr int tensorArenaSize = 32 * 1024;
alignas(16) byte tensorArena[tensorArenaSize];

// ── Helpers ───────────────────────────────────────────────────────────────────

// Softmax applied in-place to raw logits from the Dense output layer
// (model was trained with from_logits=True, so TFLite outputs raw logits)
void softmax(float* logits, int n) {
  float maxVal = logits[0];
  for (int i = 1; i < n; i++) if (logits[i] > maxVal) maxVal = logits[i];

  float sum = 0.0f;
  for (int i = 0; i < n; i++) {
    logits[i] = exp(logits[i] - maxVal);
    sum += logits[i];
  }
  for (int i = 0; i < n; i++) logits[i] /= sum;
}

// ── Setup ─────────────────────────────────────────────────────────────────────
void setup() {
  Serial.begin(9600);
  while (!Serial);

  Serial.println();
  Serial.println("Initializing GRU model...");

  if (!modelInit(model, tensorArena, tensorArenaSize)) {
    Serial.println("Model initialization failed! Try increasing tensorArenaSize.");
    while (true);
  }

  Serial.println("Model initialization done.");
  Serial.print("Input  shape: [1, ");
  Serial.print(SEGMENT_LENGTH);
  Serial.print(", ");
  Serial.print(NUM_FEATURES);
  Serial.println("]");
  Serial.print("Output classes: ");
  Serial.println(NUM_CLASSES);
}

// ── Loop ──────────────────────────────────────────────────────────────────────
void loop() {
  // ── 1. Fill the input tensor ──────────────────────────────────────────────
  // The model expects a flattened window of shape (segment_length, no_feature)
  // = 16 × 64 = 1024 float values, normalised with StandardScaler.
  //
  // Replace this placeholder loop with your real sensor acquisition +
  // StandardScaler normalisation (subtract mean, divide by std-dev).
  // Input index: time_step * NUM_FEATURES + feature_idx
  for (int t = 0; t < SEGMENT_LENGTH; t++) {
    for (int f = 0; f < NUM_FEATURES; f++) {
      int idx = t * NUM_FEATURES + f;
      // TODO: replace with (raw_sample - scaler_mean[f]) / scaler_std[f]
      float normalised_sample = (float)idx / NUM_INPUTS;
      modelSetInput(normalised_sample, idx);
    }
  }

  // ── 2. Run inference ──────────────────────────────────────────────────────
  if (!modelRunInference()) {
    Serial.println("RunInference Failed!");
    return;
  }

  // ── 3. Read raw logits and apply softmax ──────────────────────────────────
  // The Keras model uses from_logits=True, so TFLite outputs raw logits.
  float logits[NUM_CLASSES];
  for (int i = 0; i < NUM_CLASSES; i++) {
    logits[i] = modelGetOutput(i);
  }
  softmax(logits, NUM_CLASSES);

  // ── 4. Print results ──────────────────────────────────────────────────────
  for (int i = 0; i < NUM_CLASSES; i++) {
    Serial.print(GESTURES[i]);
    Serial.print(": ");
    Serial.print(logits[i] * 100.0f, 2);
    Serial.println("%");
  }

  // Print predicted class
  int predicted = 0;
  for (int i = 1; i < NUM_CLASSES; i++) {
    if (logits[i] > logits[predicted]) predicted = i;
  }
  Serial.print("Prediction: ");
  Serial.println(GESTURES[predicted]);
  Serial.println();

  delay(100); // adjust to your desired inference rate
}
