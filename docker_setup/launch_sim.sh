#!/usr/bin/env bash
# launch_sim.sh
# One-shot script to start the full simulation stack inside the container.
# Run from inside the Dev Container terminal.
#
# Usage:
#   bash ~/launch_sim.sh          # headless (recommended for Mac/Windows)
#   bash ~/launch_sim.sh --gui    # attempt Gazebo GUI (Linux native only)

set -e

GUI=false
for arg in "$@"; do
  [[ "$arg" == "--gui" ]] && GUI=true
done

# ── 1. Virtual framebuffer (required for software GL on Mac/Windows) ──
if [[ "$GUI" == false ]]; then
  echo "[sim] Starting Xvfb virtual display on :99 ..."
  sudo mkdir -p /tmp/.X11-unix
  sudo chmod 1777 /tmp/.X11-unix
  Xvfb :99 -screen 0 1280x1024x24 +extension GLX &
  sleep 2
  export DISPLAY=:99
fi

# ── 2. Rendering environment ──────────────────────────────────
export LIBGL_ALWAYS_SOFTWARE=1
export MESA_GL_VERSION_OVERRIDE=3.3
export MESA_LOADER_DRIVER_OVERRIDE=softpipe
export EGL_PLATFORM=surfaceless
export GZ_VERSION=harmonic
export GZ_SIM_RESOURCE_PATH=$GZ_SIM_RESOURCE_PATH:\
$HOME/ros2_ws/install/ardupilot_gz_bringup/share/ardupilot_gz_bringup/worlds:\
$HOME/ros2_ws/install/ardupilot_sitl_models/share/ardupilot_sitl_models/models:\
$HOME/ros2_ws/install/ardupilot_sitl_models/share/ardupilot_sitl_models/worlds
export SDF_PATH=$GZ_SIM_RESOURCE_PATH

# ── 3. Source ROS ─────────────────────────────────────────────
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash

# ── 4. Launch ─────────────────────────────────────────────────
echo "[sim] Launching ArduRover SITL + Gazebo Harmonic + ROS 2 ..."
if [[ "$GUI" == true ]]; then
  ros2 launch ardupilot_gz_bringup wildthumper_playpen.launch.py
else
  ros2 launch ardupilot_gz_bringup wildthumper_playpen.launch.py \
    gui:=false rviz:=false
fi
