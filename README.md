# Intelligent Dynamic Spectrum Cartography: Motion Planning

[![ROS 2](https://img.shields.io/badge/ROS_2-Humble-blue.svg)](https://docs.ros.org/en/humble/)
[![Python](https://img.shields.io/badge/Python-3.10+-yellow.svg)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

## Overview
This repository contains the autonomous motion planning and hardware control stack for the **Intelligent Dynamic Spectrum Cartography** project, sponsored by the DEVCOM Army Research Laboratory. It coordinates a multi-agent system consisting of a primary Unmanned Ground Vehicle (UGV) and an adversarial OPFOR unit to track, locate, and map RF emitters in dynamic combat environments.

Instead of exhaustive physical sensing, this system utilizes the ROS 2 `Nav2` stack integrated with a custom RF Exploration Node. The UGV autonomously samples sparse RF data, passes it to an onboard neural network for spectrum map reconstruction, and dynamically updates its pathfinding goals to sample regions of highest uncertainty.

## System Architecture

### 1. Primary UGV (Waveshare UGV Beast)
The primary agent utilizes a dual-compute architecture:
* **High-Level Compute (Nvidia Jetson Orin Nano 8GB):** Runs ROS 2, processes sensor point-clouds, handles the HackRF SDR data streams, runs the PartialConvMAE inference, and executes the `Nav2` spatial planning.
* **Low-Level VCU (ESP32):** Receives `cmd_vel` Twist messages via USB Serial. Manages differential drive kinematics, motor PID loops, and streams wheel odometry back to the Jetson.

**Perception Payload:**
* **D500 LiDAR & OAK Stereo Camera:** 2D/3D environmental mapping and obstacle avoidance.
* **HackRF One (w/ ANT500):** Software-defined radio for sparse RF signal collection.
* **SparkFun MAX-M10S GNSS:** Global positioning via I2C to the Jetson GPIO.

### 2. OPFOR Emitter (Hiwonder Tank Chassis)
The OPFOR unit acts as an adversarial, mobile RF emitter

```mermaid
graph TD
    %% Styling
    classDef power fill:#ffe6e6,stroke:#d63031,stroke-width:2px;
    classDef compute fill:#e8f4f8,stroke:#0984e3,stroke-width:2px;
    classDef vcu fill:#eafaf1,stroke:#00b894,stroke-width:2px;
    classDef sensor fill:#fef9e7,stroke:#fdcb6e,stroke-width:2px;

    %% Power Layer
    subgraph Power_System ["Power Source"]
        BATT["24x Molicel P30B 18650 Batteries"]:::power
    end

    %% VCU Layer
    subgraph UGV_Chassis ["Waveshare UGV Beast Chassis (VCU)"]
        PDB["Power Distribution Board (Internal)"]:::vcu
        ESP["ESP32 Sub-Controller"]:::vcu
        MOTORS["Drive Motors & Wheel Encoders"]:::vcu
    end

    %% Compute Layer
    subgraph Host_Compute ["Brain"]
        JETSON["Nvidia Jetson Orin Nano (8GB)"]:::compute
    end

    %% Sensor Layer
    subgraph Perception_Payload ["Sensors & Receivers"]
        OAK["OAK Stereo Camera"]:::sensor
        LIDAR["D500 LiDAR"]:::sensor
        HACKRF["HackRF One + ANT500 Antenna"]:::sensor
        GPS["SparkFun GNSS (MAX-M10S) + Antenna"]:::sensor
    end

    %% Connections - Power
    BATT ==>|"24V DC Array"| PDB
    PDB -.->|"Internal Power"| ESP
    PDB -.->|"Motor Voltages"| MOTORS
    PDB ==>|"Regulated 5V/5A USB-C/DC"| JETSON

    %% Connections - Data
    ESP <==>|"UART / USB Serial<br>(Twist Cmds & Odometry)"| JETSON
    ESP <-->|"PWM / PID Control"| MOTORS

    %% Connections - Sensors
    OAK <==>|"USB 3.0 / USB-C"| JETSON
    LIDAR <==>|"USB (via UART adapter)"| JETSON
    HACKRF <==>|"USB 2.0"| JETSON
    GPS <==>|"I2C (Qwiic to 40-Pin GPIO)"| JETSON
```
