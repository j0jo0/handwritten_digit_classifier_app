# MNIST Handwritten Digit Classifier

<img src="https://raw.githubusercontent.com/j0jo0/handwritten_digit_classifier_app/master/assets/app_demo.png" style="width:400px;">


A Flutter mobile app that recognizes handwritten digits drawn on a canvas in real-time. It uses a custom-trained neural network, converted to TFLite for efficient on-device inference.

This project is part of my portfolio and showcases a full-cycle machine learning implementation, from model training in Python to deployment in a cross-platform mobile app.

---

## Features

- **Real-time Drawing:** Draw digits directly on a responsive canvas.
- **Instant Recognition:** Get instant classification of the drawn digit.
- **Top-3 Probabilities:** See the model's top 3 predictions with their confidence scores.
- **Clean UI:** A modern and intuitive user interface built with Flutter.
- **On-Device Inference:** All calculations happen locally, no internet connection is needed.

---

## Tech Stack & Architecture

This project is split into two main parts: the machine learning model and the Flutter application.

### Machine Learning Model

- **Framework:** **PyTorch** was used for training the neural network.
- **Dataset:** The classic **MNIST** dataset of handwritten digits.
- **Deployment Format:** The trained model was converted to **TensorFlow Lite (`.tflite`)** for fast and efficient inference on mobile devices.

### Flutter Application

- **Framework:** **Flutter** for building a high-performance, cross-platform mobile application from a single codebase.
- **Architecture:** A clean and scalable structure was implemented:
    - **UI Layer:** Composed of separate, reusable widgets (`DrawingCanvas`, `RecognizedDigitCard`, `ActionButtons`).
    - **State Management:** Using `StatefulWidgets` and the **"Lifting State Up"** pattern by passing callbacks from stateless child widgets to a stateful parent.
    - **Service Layer:** The entire TFLite logic is encapsulated in a dedicated `DigitRecognizer` service class, separating ML logic from the UI.
- **Key Libraries:**
    - `tflite_flutter`: To run the TensorFlow Lite model in Flutter.
    - `flutter_screenutil`: To ensure the UI is responsive and adapts to various screen sizes.
    - `image`: For powerful image pre-processing before feeding the data to the model.
    - `CustomPainter`: To create the interactive drawing canvas from scratch.

---

## How It Works

The process from drawing to recognition follows these steps:

1.  **Drawing:** The user draws a digit on the `CustomPainter` canvas.
2.  **Pre-processing:** When "Analyze" is tapped, the list of drawn points is converted into an image. This image is then:
    a.  **Centered & Padded:** The drawing is isolated and centered in a square format.
    b.  **Resized:** The image is downscaled to **28x28 pixels**, the input size required by the model.
    c.  **Normalized & Inverted:** The pixel data is converted to grayscale and normalized. The colors are inverted (black lines become high-value pixels on a low-value background) to match the MNIST training data format.
3.  **Inference:** The resulting `List<double>` of 784 pixels is fed into the TFLite interpreter.
4.  **Output:** The model returns an array of 10 probabilities. The app identifies the index with the highest probability as the recognized digit and displays the top 3 results.

---

## Getting Started

There are two main ways to get this project running on your local machine.

### Option A: With your IDE (Recommended)

This is the easiest way if you are using Android Studio, IntelliJ, or VS Code.

1.  Open your IDE and choose **"Get from VCS"** (Version Control System) or **"Clone Repository"** from the welcome screen.
2.  Paste the following repository URL:
    ```
    https://github.com/j0jo0/handwritten_digit_classifier_app
    ```
3.  The IDE will clone the project and should automatically prompt you to install the Flutter dependencies.
4.  Once the process is complete, select a device and run the app.

### Option B: From the Command Line

This universal method works in any terminal.

1.  **Clone the repository:**
    ```sh
    git clone https://github.com/j0jo0/handwritten_digit_classifier_app
    ```

2.  **Navigate to the project directory:**
    ```sh
    cd handwritten_digit_classifier_app
    ```

3.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

4.  **Run the app:**
    ```sh
    flutter run
    ```

---

*This README and some parts from the codebase was created with assistance from an AI code assistant.*
