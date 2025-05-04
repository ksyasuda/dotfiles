#!/usr/bin/env python
import logging
from argparse import ArgumentParser

from requests import get
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as EC
from selenium.webdriver.support.ui import WebDriverWait

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

AUDIO_BASE_URL = (
    "https://www.heypera.com/listen/nihongo-con-teppei-for-beginners/{}/next"
)
SUB_BASE_URL = "https://storage.googleapis.com/pera-transcripts/nihongo-con-teppei-for-beginners/transcripts/{}.vtt"


def get_audio_url(episode_num: int):
    chrome_options = Options()
    chrome_options.add_argument("--headless")
    chrome_options.add_argument("--disable-gpu")
    chrome_options.add_argument("--no-sandbox")

    driver = webdriver.Chrome(options=chrome_options)

    try:
        driver.get(AUDIO_BASE_URL.format(episode_num))

        # Wait for the audio element to be present
        audio_element = WebDriverWait(driver, 10).until(
            EC.presence_of_element_located((By.TAG_NAME, "audio"))
        )
        audio_url = audio_element.get_attribute("src")
        if audio_url:
            logger.info(f"Audio URL: {audio_url}")
        else:
            logger.error("No audio URL found")
        return audio_url
    except Exception as e:
        logger.error(f"Error: {e}")
        raise e
    finally:
        driver.quit()


def get_sub_url(episode_num: int):
    return SUB_BASE_URL.format(episode_num)


def download_file(url: str, filename: str):
    response = get(url, timeout=10)
    if response.status_code != 200:
        logger.error(f"Failed to download {filename}")
        return
    with open(filename, "wb") as file:
        file.write(response.content)
    logger.info(f"Downloaded {filename}")


def parse_args():
    parser = ArgumentParser(description="Get the audio URL for a given episode number")
    parser.add_argument(
        "episode_num", type=int, help="The episode number to get the audio URL for"
    )
    parser.add_argument(
        "-d", "--download", action="store_true", help="Download the audio file"
    )
    parser.add_argument("-o", "--output", help="Output directory name")
    return parser.parse_args()


if __name__ == "__main__":
    args = parse_args()
    if args.episode_num < 1:
        logger.error("Episode number must be greater than 0")
    episode = args.episode_num
    audio = get_audio_url(episode)
    sub = get_sub_url(episode)
    if args.download:
        if args.output:
            download_file(audio, f"{args.output}/Nihongo-Con-Teppei-E{episode:0>2}.mp3")
            download_file(sub, f"{args.output}/Nihongo-Con-Teppei-E{episode:0>2}.vtt")
        else:
            download_file(audio, f"Nihongo-Con-Teppei-E{episode:0>2}.mp3")
            download_file(sub, f"Nihongo-Con-Teppei-E{episode:0>2}.vtt")
    else:
        print(f"Audio URL: {audio}")
        print(f"Subtitle URL: {sub}")
