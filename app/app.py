from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()


def main():
    print(f"Hello, world! The time is {datetime.now()}")
    logger.info(f"Hello, world! The time is {datetime.now()}")


if __name__ == "__main__":
    main()