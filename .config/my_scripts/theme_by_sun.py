#!/usr/bin/env python3

from __future__ import annotations

import argparse
import math
import os
import sys
from datetime import datetime, timedelta, timezone
from typing import NoReturn

DAYLIGHT_ELEVATION_DEGREES = -0.833
SEARCH_STEP = timedelta(minutes=10)
SEARCH_HORIZON = timedelta(hours=48)
SLEEP_FLOOR_SECONDS = 60
SLEEP_CEILING_SECONDS = 6 * 60 * 60
SLEEP_BUFFER_SECONDS = 30


def fail(message: str) -> NoReturn:
    print(message, file=sys.stderr)
    raise SystemExit(1)


def parse_coordinate(name: str, minimum: float, maximum: float) -> float:
    raw = os.environ.get(name, "").strip()
    if not raw:
        fail(f"{name} is not set")

    try:
        value = float(raw)
    except ValueError as exc:
        fail(f"{name} must be a number: {exc}")

    if value < minimum or value > maximum:
        fail(f"{name} must be between {minimum} and {maximum}")

    return value


def julian_day(moment_utc: datetime) -> float:
    return moment_utc.timestamp() / 86400.0 + 2440587.5


def solar_elevation_degrees(moment_utc: datetime, latitude_deg: float, longitude_deg: float) -> float:
    jd = julian_day(moment_utc)
    jc = (jd - 2451545.0) / 36525.0

    geom_mean_long_sun = (280.46646 + jc * (36000.76983 + jc * 0.0003032)) % 360.0
    geom_mean_anom_sun = 357.52911 + jc * (35999.05029 - 0.0001537 * jc)
    eccent_earth_orbit = 0.016708634 - jc * (0.000042037 + 0.0000001267 * jc)

    geom_mean_anom_rad = math.radians(geom_mean_anom_sun)
    sun_eq_of_center = (
        math.sin(geom_mean_anom_rad) * (1.914602 - jc * (0.004817 + 0.000014 * jc))
        + math.sin(2.0 * geom_mean_anom_rad) * (0.019993 - 0.000101 * jc)
        + math.sin(3.0 * geom_mean_anom_rad) * 0.000289
    )

    sun_true_long = geom_mean_long_sun + sun_eq_of_center
    sun_app_long = sun_true_long - 0.00569 - 0.00478 * math.sin(math.radians(125.04 - 1934.136 * jc))

    mean_obliq_ecliptic = 23.0 + (26.0 + ((21.448 - jc * (46.815 + jc * (0.00059 - jc * 0.001813))) / 60.0)) / 60.0
    obliq_corr = mean_obliq_ecliptic + 0.00256 * math.cos(math.radians(125.04 - 1934.136 * jc))

    sun_declination = math.degrees(
        math.asin(
            math.sin(math.radians(obliq_corr)) * math.sin(math.radians(sun_app_long))
        )
    )

    var_y = math.tan(math.radians(obliq_corr / 2.0)) ** 2
    eq_of_time = 4.0 * math.degrees(
        var_y * math.sin(2.0 * math.radians(geom_mean_long_sun))
        - 2.0 * eccent_earth_orbit * math.sin(geom_mean_anom_rad)
        + 4.0
        * eccent_earth_orbit
        * var_y
        * math.sin(geom_mean_anom_rad)
        * math.cos(2.0 * math.radians(geom_mean_long_sun))
        - 0.5 * var_y * var_y * math.sin(4.0 * math.radians(geom_mean_long_sun))
        - 1.25 * eccent_earth_orbit * eccent_earth_orbit * math.sin(2.0 * geom_mean_anom_rad)
    )

    utc_minutes = (
        moment_utc.hour * 60.0
        + moment_utc.minute
        + moment_utc.second / 60.0
        + moment_utc.microsecond / 60000000.0
    )
    true_solar_time = (utc_minutes + eq_of_time + 4.0 * longitude_deg) % 1440.0
    hour_angle = true_solar_time / 4.0 - 180.0
    if hour_angle < -180.0:
        hour_angle += 360.0

    latitude_rad = math.radians(latitude_deg)
    sun_declination_rad = math.radians(sun_declination)
    hour_angle_rad = math.radians(hour_angle)

    cos_zenith = (
        math.sin(latitude_rad) * math.sin(sun_declination_rad)
        + math.cos(latitude_rad) * math.cos(sun_declination_rad) * math.cos(hour_angle_rad)
    )
    cos_zenith = max(-1.0, min(1.0, cos_zenith))

    solar_zenith = math.degrees(math.acos(cos_zenith))
    return 90.0 - solar_zenith


def signed_solar_height(moment_utc: datetime, latitude_deg: float, longitude_deg: float) -> float:
    return solar_elevation_degrees(moment_utc, latitude_deg, longitude_deg) - DAYLIGHT_ELEVATION_DEGREES


def current_mode(moment_utc: datetime, latitude_deg: float, longitude_deg: float) -> str:
    if signed_solar_height(moment_utc, latitude_deg, longitude_deg) >= 0.0:
        return "light"
    return "dark"


def find_next_transition(moment_utc: datetime, latitude_deg: float, longitude_deg: float) -> datetime | None:
    previous_time = moment_utc
    previous_height = signed_solar_height(previous_time, latitude_deg, longitude_deg)

    steps = int(SEARCH_HORIZON / SEARCH_STEP)
    for step_index in range(1, steps + 1):
        current_time = moment_utc + SEARCH_STEP * step_index
        current_height = signed_solar_height(current_time, latitude_deg, longitude_deg)

        if previous_height == 0.0:
            return previous_time
        if current_height == 0.0:
            return current_time
        if previous_height * current_height < 0.0:
            low_time = previous_time
            high_time = current_time
            low_height = previous_height

            for _ in range(50):
                if (high_time - low_time) <= timedelta(seconds=1):
                    break

                midpoint_time = low_time + (high_time - low_time) / 2
                midpoint_height = signed_solar_height(midpoint_time, latitude_deg, longitude_deg)

                if midpoint_height == 0.0:
                    return midpoint_time
                if low_height * midpoint_height <= 0.0:
                    high_time = midpoint_time
                else:
                    low_time = midpoint_time
                    low_height = midpoint_height

            return high_time

        previous_time = current_time
        previous_height = current_height

    return None


def next_check_seconds(moment_utc: datetime, latitude_deg: float, longitude_deg: float) -> int:
    transition = find_next_transition(moment_utc, latitude_deg, longitude_deg)
    if transition is None:
        return SLEEP_CEILING_SECONDS

    seconds = math.ceil((transition - moment_utc).total_seconds()) + SLEEP_BUFFER_SECONDS
    return max(SLEEP_FLOOR_SECONDS, min(SLEEP_CEILING_SECONDS, seconds))


def main() -> int:
    parser = argparse.ArgumentParser(description="Resolve light/dark mode from sun position.")
    parser.add_argument(
        "--next-check-seconds",
        action="store_true",
        help="print the suggested number of seconds until the next recheck",
    )
    args = parser.parse_args()

    latitude = parse_coordinate("THEME_LATITUDE", -90.0, 90.0)
    longitude = parse_coordinate("THEME_LONGITUDE", -180.0, 180.0)
    now_utc = datetime.now(timezone.utc)

    if args.next_check_seconds:
        print(next_check_seconds(now_utc, latitude, longitude))
    else:
        print(current_mode(now_utc, latitude, longitude))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
