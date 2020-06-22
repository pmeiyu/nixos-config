#!/usr/bin/env python

import argparse
import logging
import time

import periphery


logging.basicConfig()
logger = logging.getLogger("pi-fan-control")
logger.setLevel(logging.INFO)

GPIO_PIN = 17
ON_THRESHOLD = 70
OFF_THRESHOLD = 45
SLEEP_INTERVAL = 10


def get_temperature():
    filename = "/sys/class/thermal/thermal_zone0/temp"
    with open(filename) as f:
        temperature = int(f.read()) / 1000
    return temperature


def main():
    parser = argparse.ArgumentParser(description="Raspberry Pi fan control")
    parser.add_argument("--gpio-pin",
                        dest="gpio_pin",
                        type=int,
                        default=GPIO_PIN,
                        help="GPIO pin to control the fan.")
    parser.add_argument("--on-threshold",
                        dest="on_threshold",
                        type=int,
                        default=ON_THRESHOLD,
                        help="Threshold temperature to turn on the fan.")
    parser.add_argument("--off-threshold",
                        dest="off_threshold",
                        type=int,
                        default=OFF_THRESHOLD,
                        help="Threshold temperature to turn off the fan.")
    parser.add_argument("--sleep-interval",
                        dest="sleep_interval",
                        type=int,
                        default=SLEEP_INTERVAL,
                        help="Check temperature every $x seconds.")
    args = parser.parse_args()

    try:
        fan = periphery.GPIO("/dev/gpiochip0", args.gpio_pin, "out")
    except Exception as e:
        logger.error(e)
        logger.error("Failed to open GPIO device. Exit.")
        return

    try:
        while True:
            temperature = get_temperature()
            logger.info(f"Temperature: {temperature}.")
            if temperature < args.off_threshold:
                if fan.read():
                    logger.info("Turning off Fan.")
                    fan.write(False)
            elif temperature > args.on_threshold:
                if not fan.read():
                    logger.info("Turning on Fan.")
                    fan.write(True)
            time.sleep(args.sleep_interval)
    except KeyboardInterrupt:
        pass
    except Exception as e:
        logger.error(e)
    finally:
        fan.close()
        logger.warning("Exit.")


if __name__ == "__main__":
    main()
