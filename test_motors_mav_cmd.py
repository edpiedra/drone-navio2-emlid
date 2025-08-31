#!/usr/bin/env python3
"""
Test Navio2 motors using MAV_CMD_DO_MOTOR_TEST
- Requires ArduPilot running (ArduCopter).
- Props off!
"""

from pymavlink import mavutil
import time

# Connect to ArduPilot
master = mavutil.mavlink_connection('udp:127.0.0.1:14550')

print("Waiting for heartbeat...")
master.wait_heartbeat()
print("Connected to system:", master.target_system, "component:", master.target_component)

# Arm motors
print("Arming...")
master.mav.command_long_send(
    master.target_system,
    master.target_component,
    mavutil.mavlink.MAV_CMD_COMPONENT_ARM_DISARM,
    0,
    1,  # 1 = arm
    0,0,0,0,0,0
)
time.sleep(2)

# MAV_CMD_DO_MOTOR_TEST parameters:
# param1: motor number (1 = first motor, 2 = second, …, or 0 for all)
# param2: test type (0 = throttle PWM, 1 = throttle %, 2 = duration)
# param3: throttle value (PWM or % depending on param2)
# param4: timeout (s)
# param5-7: unused (0)

def motor_test(motor_num, throttle_percent, duration=2):
    print(f"Testing motor {motor_num} at {throttle_percent}% for {duration}s")
    master.mav.command_long_send(
        master.target_system,
        master.target_component,
        mavutil.mavlink.MAV_CMD_DO_MOTOR_TEST,
        0,
        motor_num,     # which motor
        1,             # throttle type: 1 = percentage
        throttle_percent,
        duration,      # test timeout in seconds
        0,0,0
    )
    time.sleep(duration + 1)

# Test motors 1–4 at 20%
for i in range(1, 5):
    motor_test(i, 20, 2)

# Disarm
print("Disarming...")
master.mav.command_long_send(
    master.target_system,
    master.target_component,
    mavutil.mavlink.MAV_CMD_COMPONENT_ARM_DISARM,
    0,
    0,  # disarm
    0,0,0,0,0,0
)

print("Done.")
