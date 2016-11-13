
Steps in reproducing the firmware:

You need gpadm, mplayer/mplayer2, imagemagick and the gcc toolchain for your host. Install these.

The music badge also needs a buzzer or speaker connected between B3 and B5.

First, generate the music. The music already comes pre-packed in the music/songdata.c file. If
you want to have a different song, download Monotone from https://github.com/MobyGamer/MONOTONE ,
modify mksongc.php to point at a different song and run it; it will generate a new songdata.c file.

To generate the music.inc file the assembly needs:

cd music
make
./music > ../music.inc
cd ..

Then, make the music/start badge firmware using 'make main.hex'.

To generate the movie files, you need the original movie. The software can use any movie, but the
img/gen.sh script is tuned for the crop that https://www.youtube.com/watch?v=dQw4w9WgXcQ needs to
get rid of the black borders on the side. Modify this script accordingly (specifically the
crop=920:700:180:10 bit) to work for whatever movie you substitute.

Then, run the following to generate the movie includes:
cd convimg
make
cd ../img
./gen.sh /wherever/you/dropped/your/movie_file.mp4
cd ..

This will generate mov1.inc, mov2.inc and mov3.inc. These contain the movie data for the left, center and
right video badge. These will be needing to be renamed to mov.inc when making the firmware for a badge.

So for example, for the middle badge:
cp mov1.inc mov.inc
make thing.hex
(copy thing.hex to the badge)

Note: After reset, the badges will do nothing at all yet. To start the video, take the music badge
and hold it so the IR receivers on the video badges can see the IR transmitter on the front of the music
badge, then press the 'power' button on the music badge.


