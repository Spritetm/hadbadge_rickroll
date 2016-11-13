/*
Player for compressed Monotone songs.
(C) 2012 Jeroen Domburg (jeroen AT spritesmods.com)
Monotone, by Trixter: http://www.oldskool.org/pc/MONOTONE

This program is free software: you can redistribute it and/or modify
t under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
Routines for compiling the player on a PC. This hooks libao for the sound.
*/

#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "config.h"
#include "player.h"
#include "dds.h"

//buffer for audio output
#define AO_BUFF 4096
//define to divert sound to a file called 'music.wav'.
//#define TO_FILE

int main(int argc, char** argv) {
    int d,x;
	int l=0;;
    char *samps;
    
    
    //Libao is opened and initialised now.

    //allocate sample buffer
    samps=malloc(AO_BUFF);
    d=0;
    //reset player
    player_reset();
    while(1) {
	//generate AO_BUFF samples, advance the player 60 times per second
	for (x=0; x<AO_BUFF; x++) {
	    d++;
	    if (d>(DDS_FREQ/PLAYER_FREQ)) {
		l++;
		d=0;
		player_tick();
	    }
	}
	if (l>(100*60)) break;
    }
}
