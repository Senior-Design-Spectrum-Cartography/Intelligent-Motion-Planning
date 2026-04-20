# Intelligent-Motion-Planning
UAS software and firmware to track adversarial transmitters.

```mermaid
graph TD
    %% Styling
    classDef power fill:#ffe6e6,stroke:#d63031,stroke-width:2px;
    classDef compute fill:#e8f4f8,stroke:#0984e3,stroke-width:2px;
    classDef vcu fill:#eafaf1,stroke:#00b894,stroke-width:2px;
    classDef sensor fill:#fef9e7,stroke:#fdcb6e,stroke-width:2px;

    %% Power Layer
    subgraph Power_System ["⚡ Power Source"]
        BATT["24x Molicel P30B 18650 Batteries"]:::power
    end

    %% VCU Layer
    subgraph UGV_Chassis ["Waveshare UGV Beast Chassis (VCU)"]
        PDB["Power Distribution Board (Internal)"]:::vcu
        ESP["ESP32 Sub-Controller"]:::vcu
        MOTORS["Drive Motors & Wheel Encoders"]:::vcu
    end

    %% Compute Layer
    subgraph Host_Compute ["🧠 Brain"]
        JETSON["Nvidia Jetson Orin Nano (8GB)"]:::compute
    end

    %% Sensor Layer
    subgraph Perception_Payload ["👁️ Sensors & Receivers"]
        OAK["OAK Stereo Camera"]:::sensor
        LIDAR["D500 LiDAR"]:::sensor
        HACKRF["HackRF One + ANT500 Antenna"]:::sensor
        GPS["SparkFun GNSS (MAX-M10S) + Antenna"]:::sensor
    end

    %% Connections - Power
    BATT ==>|24V DC Array| PDB
    PDB -.->|Internal Power| ESP
    PDB -.->|Motor Voltages| MOTORS
    PDB ==>|Regulated 5V/5A USB-C/DC| JETSON

    %% Connections - Data
    ESP <==>|UART / USB Serial<br>(Twist Cmds & Odometry)| JETSON
    ESP <-->|PWM / PID Control| MOTORS

    %% Connections - Sensors
    OAK <==>|USB 3.0 / USB-C| JETSON
    LIDAR <==>|USB (via UART adapter)| JETSON
    HACKRF <==>|USB 2.0| JETSON
    GPS <==>|I2C (Qwiic to 40-Pin GPIO)| JETSON
```
