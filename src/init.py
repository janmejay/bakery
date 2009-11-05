import sys, config, os, logging, pygame
sys.path.append(os.path.join(config.BAKERY_SRC))

logger = logging.getLogger("config")
logger.setLevel(logging.DEBUG)
file_handler = logging.FileHandler(os.path.join(config.BAKERY_TMP, "bakery.log"))
file_handler.setLevel(logging.DEBUG)
formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
file_handler.setFormatter(formatter)
logger.addHandler(file_handler)
logger.info("Logger initialized.")

