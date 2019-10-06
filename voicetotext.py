from __future__ import division

import re
import sys
import os

import asyncio
import websockets

import random

# Set global Google credentials variable from json file
# Update to match local file structure 
os.environ["GOOGLE_APPLICATION_CREDENTIALS"]="C:\\Users\\cameron.anderson.EAWPHX\\Desktop\\Beethoven-service.json"

from google.cloud import speech
from google.cloud.speech import enums
from google.cloud.speech import types
import pyaudio
from six.moves import queue

# Audio recording parameters
RATE = 16000
CHUNK = int(RATE / 10)  # 100ms

#get random number for room ID 
ROOM_ID = random.randint(1,1001)

class MicrophoneStream(object):
    """Opens a recording stream as a generator yielding the audio chunks."""
    def __init__(self, rate, chunk):
        self._rate = rate
        self._chunk = chunk

        # Create a thread-safe buffer of audio data
        self._buff = queue.Queue()
        self.closed = True

   
    def __enter__(self):
        """Opens audio stream"""
        self._audio_interface = pyaudio.PyAudio()
        self._audio_stream = self._audio_interface.open(
            format=pyaudio.paInt16,
            # The API currently only supports 1-channel (mono) audio
            # https://goo.gl/z757pE
            channels=1, rate=self._rate,
            input=True, frames_per_buffer=self._chunk,
            # Run the audio stream asynchronously to fill the buffer object.
            # This is necessary so that the input device's buffer doesn't
            # overflow while the calling thread makes network requests, etc.
            stream_callback=self._fill_buffer,
        )

        self.closed = False

        return self

    def __exit__(self, type, value, traceback):
        self._audio_stream.stop_stream()
        self._audio_stream.close()
        self.closed = True
        # Signal the generator to terminate so that the client's
        # streaming_recognize method will not block the process termination.
        self._buff.put(None)
        self._audio_interface.terminate()

    def _fill_buffer(self, in_data, frame_count, time_info, status_flags):
        """Continuously collect data from the audio stream, into the buffer."""
        self._buff.put(in_data)
        return None, pyaudio.paContinue

    def generator(self):
        while not self.closed:
            # Use a blocking get() to ensure there's at least one chunk of
            # data, and stop iteration if the chunk is None, indicating the
            # end of the audio stream.
            chunk = self._buff.get()
            if chunk is None:
                return
            data = [chunk]

            # Now consume whatever other data's still buffered.
            while True:
                try:
                    chunk = self._buff.get(block=False)
                    if chunk is None:
                        return
                    data.append(chunk)
                except queue.Empty:
                    break

            yield b''.join(data)


def create_socket():
    '''websocket client side for sending'''
    print("Room ID: " + str(ROOM_ID))
    uri = "ws://c78a5568.ngrok.io/rooms/" + str(ROOM_ID) + "/send"

    return websockets.connect(uri)
        

async def audio_connection():
    # See http://g.co/cloud/speech/docs/languages
    # for a list of supported languages.
    language_code = 'en-US'  # a BCP-47 language tag

    client = speech.SpeechClient()
    config = types.RecognitionConfig(
        encoding=enums.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=RATE,
        language_code=language_code)
    streaming_config = types.StreamingRecognitionConfig(
        config=config,
        interim_results=True)

    with MicrophoneStream(RATE, CHUNK) as stream:
        audio_generator = stream.generator()
        requests = (types.StreamingRecognizeRequest(audio_content=content)
                    for content in audio_generator)

        responses = client.streaming_recognize(streaming_config, requests)

        # Use responses from Google API 
        async with create_socket() as websocket:
            num_chars_printed = 0
            for response in responses:
                if not response.results:
                    continue
                result = response.results[0]
                if not result.alternatives:
                    continue
                transcript = result.alternatives[0].transcript

                overwrite_chars = ' ' * (num_chars_printed - len(transcript))

                if not result.is_final:
                    sys.stdout.write(transcript + overwrite_chars + '\r')
                    sys.stdout.flush()

                    num_chars_printed = len(transcript)

                else:
                    text = transcript + overwrite_chars
                    await websocket.send(text) 
                    #await websocket.send(response.results[0].alternatives[0].transcript)

                    # Use file to output text (commented out to move task to server/database)
                    outputfile = open("C:\\Users\\cameron.anderson.EAWPHX\\Desktop\\" + str(ROOM_ID) + "transcript.txt","a")
                    outputfile.writelines(transcript + overwrite_chars)

                    if re.search(r'\b(exit|quit|thank you)\b', transcript, re.I):
                        print('Exiting..')
                        outputfile.close()
                        break

                    num_chars_printed = 0
                

def main():
    asyncio.get_event_loop().run_until_complete(audio_connection()) 


if __name__ == '__main__':
    main()
