import navio2.pwm
import time

PWM_OUTPUTS = [0, 1, 2, 3]  # Channels 1–4
FREQ_HZ = 50
PULSE_MIN = 1000  # µs
PULSE_MAX = 2000  # µs
PULSE_TEST = 15  # µs (10–15% throttle)

def pulse_to_ns(pulse_us):
    return pulse_us * 1000

def test_motor(channel):
    pwm = navio2.pwm.PWM(channel)
    pwm.initialize()
    pwm.set_period(FREQ_HZ)  # in nanoseconds
    pwm.enable()
    print(f"Motor {channel} → ON")
    pwm.set_duty_cycle(PULSE_TEST)
    time.sleep(2)
    pwm.set_duty_cycle(0)
    pwm.disable()
    print(f"Motor {channel} → OFF\n")
    time.sleep(1)

def main():
    for ch in PWM_OUTPUTS:
        test_motor(ch)

if __name__ == "__main__":
    main()
