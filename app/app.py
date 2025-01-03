from datetime import datetime
import logging
import time

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()


def main():
    logger.info(f"Starting task at {datetime.now()}")
    # Add sleep to keep container running longer
    time.sleep(30)
    logger.info(f"Finishing task at {datetime.now()}")


if __name__ == "__main__":
    main()
